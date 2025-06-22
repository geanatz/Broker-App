import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'firebase_service.dart';
import 'settings_service.dart';

/// Enum pentru a defini starile/pasii posibili ai ecranului de autentificare.
/// Aceasta va controla ce popup este afisat.
enum AuthStep {
  /// Starea initiala sau nedefinita.
  initial,

  /// Afiseaza popup-ul de login.
  login,

  /// Afiseaza popup-ul de inregistrare.
  registration,
  
  /// Afiseaza popup-ul de confirmare a crearii contului si afisare token.
  accountCreated,

  /// Afiseaza popup-ul pentru introducerea token-ului de resetare a parolei.
  tokenEntry,

  /// Afiseaza popup-ul pentru setarea unei noi parole dupa validarea token-ului.
  passwordReset,
}

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();
  final FirebaseThreadHandler _threadHandler = FirebaseThreadHandler.instance;
  final NewFirebaseService _newFirebaseService = NewFirebaseService();

  // Collection names pentru noua structura
  final String _consultantsCollection = 'consultants';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create email from consultant name (for Firebase Auth)
  String _createEmailFromConsultantName(String consultantName) {
    // Transforma numele consultantului intr-un email valid pentru Firebase Auth
    // Inlocuieste spatiile cu underscore si adauga un domeniu
    return '${consultantName.trim().replaceAll(' ', '_').toLowerCase()}@brokerapp.dev';
  }

  // Register consultant - ACTUALIZAT pentru noua structura
  Future<Map<String, dynamic>> registerConsultant({
    required String consultantName,
    required String password,
    required String confirmPassword,
    required String team,
  }) async {
    try {
      debugPrint('🟨 AUTH_SERVICE: Starting registration for: $consultantName');
      
      // Verifica daca parolele se potrivesc
      if (password != confirmPassword) {
        debugPrint('🔴 AUTH_SERVICE: Passwords do not match');
        return {
          'success': false,
          'message': 'Parolele nu se potrivesc',
        };
      }

      // Genereaza token unic pentru consultant
      final consultantToken = _uuid.v4();
      debugPrint('🟨 AUTH_SERVICE: Generated consultant token: ${consultantToken.substring(0, 8)}...');

      // Verifica daca numele consultantului este unic in noua structura
      final existingConsultant = await _newFirebaseService.getConsultantByToken(consultantToken);
      if (existingConsultant != null) {
        // Genereaza un alt token daca cumva exista unul identic (foarte improbabil)
        final newToken = _uuid.v4();
        debugPrint('🟨 AUTH_SERVICE: Token collision, generating new token: ${newToken.substring(0, 8)}...');
      }

      // Verifica daca numele consultantului este unic
      final consultantSnapshot = await _threadHandler.executeOnPlatformThread(() =>
        _firestore
          .collection(_consultantsCollection)
          .where('name', isEqualTo: consultantName)
          .get()
      );

      if (consultantSnapshot.docs.isNotEmpty) {
        debugPrint('🔴 AUTH_SERVICE: Consultant name already exists');
        return {
          'success': false,
          'message': 'Acest nume de consultant exista deja',
        };
      }
      
      // Creeaza email-ul pentru Firebase Auth
      final email = _createEmailFromConsultantName(consultantName);
      debugPrint('🟨 AUTH_SERVICE: Created email: $email');
      
      debugPrint('🟨 AUTH_SERVICE: Creating Firebase user...');
      // Creeaza utilizator in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('🟨 AUTH_SERVICE: Firebase user created: ${userCredential.user?.uid}');
      debugPrint('🟨 AUTH_SERVICE: User email: ${userCredential.user?.email}');

      // IMPORTANT: Facem signOut imediat pentru a preveni autentificarea automata
      debugPrint('🟨 AUTH_SERVICE: Doing immediate signOut to prevent auto-login');
      await _auth.signOut();
      debugPrint('🟨 AUTH_SERVICE: Immediate signOut completed');

      // Salveaza datele consultantului in noua structura Firebase
      // IMPORTANT: documentul va fi cu UID-ul din Firebase Auth, dar va contine token-ul unic
      await _threadHandler.executeOnPlatformThread(() =>
        _firestore.collection(_consultantsCollection).doc(userCredential.user!.uid).set({
          'name': consultantName,
          'team': team,
          'token': consultantToken, // Token-ul unic al consultantului
          'email': userCredential.user!.email,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastActive': FieldValue.serverTimestamp(),
          'settings': {
            'theme': 'system',
            'notifications': true,
          },
        })
      );

      debugPrint('🟢 AUTH_SERVICE: Registration completed successfully with token structure');
      debugPrint('🟢 AUTH_SERVICE: Returning token: ${consultantToken.substring(0, 8)}...');
      debugPrint('🟢 AUTH_SERVICE: Token length: ${consultantToken.length}');
      return {
        'success': true,
        'token': consultantToken,
        'message': 'Cont creat cu succes',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 AUTH_SERVICE: FirebaseAuthException: ${e.code} - ${e.message}');
      String message;

      switch (e.code) {
        case 'weak-password':
          message = 'Parola este prea slaba';
          break;
        case 'email-already-in-use':
          message = 'Acest consultant exista deja (email asociat)';
          break;
        default:
          message = 'Eroare la crearea contului: ${e.message}';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      debugPrint('🔴 AUTH_SERVICE: General exception: $e');
      return {
        'success': false,
        'message': 'Eroare la crearea contului: $e',
      };
    }
  }

  // Login consultant - ACTUALIZAT pentru noua structura
  Future<Map<String, dynamic>> loginConsultant({
    required String consultantName,
    required String password,
  }) async {
    debugPrint('🔵 AUTH_SERVICE: Starting loginConsultant for: $consultantName');
    try {
      // In primul rand, verificam daca exista un consultant cu acest nume in noua structura
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(() =>
        _firestore
          .collection(_consultantsCollection)
          .where('name', isEqualTo: consultantName)
          .get()
      );
      
      if (consultantsSnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Consultant negasit',
        };
      }
      
      // Luam cel mai recent document (in caz ca exista mai multe cu acelasi nume)
      DocumentSnapshot? mostRecentDoc;
      Timestamp? mostRecentTime;
      
      for (var doc in consultantsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final createdAt = data?['createdAt'] as Timestamp?;
        if (createdAt != null) {
          if (mostRecentTime == null || createdAt.compareTo(mostRecentTime) > 0) {
            mostRecentTime = createdAt;
            mostRecentDoc = doc;
          }
        }
      }

      if (mostRecentDoc == null) {
        return {
          'success': false,
          'message': 'Date consultant invalide',
        };
      }

      final consultantData = mostRecentDoc.data() as Map<String, dynamic>;
      final email = consultantData['email'] as String?;
      final consultantToken = consultantData['token'] as String?;
      
      if (email == null || consultantToken == null) {
        return {
          'success': false,
          'message': 'Date consultant incomplete',
        };
      }

      debugPrint('🔵 AUTH_SERVICE: Found consultant with email: $email');
      debugPrint('🔵 AUTH_SERVICE: Consultant token: ${consultantToken.substring(0, 8)}...');

      // Incearca autentificarea cu Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('🟢 AUTH_SERVICE: Firebase Auth successful for: ${userCredential.user?.uid}');

      // Actualizeaza lastActive timestamp pentru consultant
      await _threadHandler.executeOnPlatformThread(() =>
        _firestore.collection(_consultantsCollection).doc(mostRecentDoc!.id).update({
          'lastActive': FieldValue.serverTimestamp(),
        })
      );

      // Returneaza datele consultantului, inclusiv token-ul pentru identificare
      return {
        'success': true,
        'consultant': {
          'id': mostRecentDoc.id,
          'name': consultantData['name'],
          'email': consultantData['email'],
          'team': consultantData['team'],
          'token': consultantToken,
        },
        'message': 'Autentificare reusita',
      };
    } on FirebaseAuthException catch (e) {
      debugPrint('🔴 AUTH_SERVICE: FirebaseAuthException during login: ${e.code} - ${e.message}');
      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'Consultant negasit';
          break;
        case 'wrong-password':
          message = 'Parola incorecta';
          break;
        case 'too-many-requests':
          message = 'Prea multe incercari. Incearca din nou mai tarziu.';
          break;
        default:
          message = 'Eroare la autentificare: ${e.message}';
      }

      return {
        'success': false,
        'message': message,
      };
    } catch (e) {
      debugPrint('🔴 AUTH_SERVICE: General exception during login: $e');
      return {
        'success': false,
        'message': 'Eroare la autentificare: $e',
      };
    }
  }

  // Obtine datele consultantului curent - ACTUALIZAT pentru noua structura
  Future<Map<String, dynamic>?> getCurrentConsultantData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _threadHandler.executeOnPlatformThread(() =>
        _firestore.collection(_consultantsCollection).doc(user.uid).get()
      );
      
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting current consultant data: $e');
      return null;
    }
  }

  // Obtine token-ul consultantului curent
  Future<String?> getCurrentConsultantToken() async {
    final consultantData = await getCurrentConsultantData();
    return consultantData?['token'] as String?;
  }

  // Obtine echipa consultantului curent
  Future<String?> getCurrentConsultantTeam() async {
    final consultantData = await getCurrentConsultantData();
    return consultantData?['team'] as String?;
  }

  // Obtine lista tuturor consultantilor pentru dropdown
  Future<List<Map<String, String>>> getAllConsultants() async {
    try {
      final snapshot = await _threadHandler.executeOnPlatformThread(() =>
        _firestore.collection(_consultantsCollection)
            .orderBy('name')
            .get()
      );

      return snapshot.docs.map((doc) => {
        'id': doc.id,
        'name': doc.data()['name'] as String,
        'team': doc.data()['team'] as String,
      }).toList();
    } catch (e) {
      debugPrint('❌ Error getting all consultants: $e');
      return [];
    }
  }

  // Verify token and get consultant ID
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      // Cauta token-ul in documentele consultant
      final consultantSnapshot = await _threadHandler.executeOnPlatformThread(() =>
        _firestore
          .collection(_consultantsCollection)
          .where('token', isEqualTo: token)
          .get()
      );

      if (consultantSnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Token invalid',
        };
      }

      // Obtine ID-ul consultantului asociat cu token-ul
      final consultantDoc = consultantSnapshot.docs.first;
      final consultantId = consultantDoc.id;

      return {
        'success': true,
        'consultantId': consultantId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la verificarea token-ului: $e',
      };
    }
  }

  // Reset password using token
  Future<Map<String, dynamic>> resetPasswordWithToken({
    required String consultantId,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      return {
        'success': false,
        'message': 'Parolele nu se potrivesc',
      };
    }

    try {
      // Obtine datele consultantului
      final consultantDoc = await _threadHandler.executeOnPlatformThread(() =>
        _firestore
          .collection(_consultantsCollection)
          .doc(consultantId)
          .get()
      );

      if (!consultantDoc.exists) {
        return {
          'success': false,
          'message': 'Consultant negasit',
        };
      }

      final consultantData = consultantDoc.data() as Map<String, dynamic>;
      final email = consultantData['email'] as String?;

      if (email == null || email.isEmpty) {
        return {
          'success': false,
          'message': 'Email consultant lipsa',
        };
      }

      // Remove token after use by setting to null or removing field
      await _threadHandler.executeOnPlatformThread(() =>
        _firestore.collection(_consultantsCollection).doc(consultantId).update({
          'token': FieldValue.delete(),
        })
      );

      return {
        'success': true,
        'message': 'Token valid. Resetarea parolei necesita implementare backend/cloud function sau flux Firebase standard (email).',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la resetarea parolei: $e',
      };
    }
  }

  // Sterge un consultant dupa nume
  Future<Map<String, dynamic>> deleteConsultantByName(String consultantName) async {
    try {
      // Pasul 1: Gaseste consultantul in Firestore dupa nume
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(() =>
        _firestore
          .collection(_consultantsCollection)
          .where('name', isEqualTo: consultantName)
          .get()
      );
          
      if (consultantsSnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Consultant negasit',
        };
      }
      
      // Luam cel mai recent document cu numele specificat
      DocumentSnapshot? mostRecentDoc;
      Timestamp? mostRecentTime;
      
      for (var doc in consultantsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?;
        final createdAt = data?['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final creationTime = createdAt.toDate();
          if (mostRecentTime == null || creationTime.isAfter(mostRecentTime.toDate())) {
            mostRecentTime = createdAt;
            mostRecentDoc = doc;
          }
        } else {
          mostRecentDoc ??= doc;
        }
      }
      
      mostRecentDoc ??= consultantsSnapshot.docs.first;
      final consultantDoc = mostRecentDoc;
      final consultantId = consultantDoc.id;
      
      // Pasul 2: Sterge setarile temei pentru consultantul respectiv
      try {
        final settingsService = SettingsService();
        await settingsService.clearConsultantSettings(consultantId);
      } catch (e) {
        debugPrint('Error clearing consultant theme settings: $e');
        // Continue with deletion even if settings clearing fails
      }
      
      // Pasul 3: Sterge documentul din Firestore
      await _threadHandler.executeOnPlatformThread(() =>
        _firestore.collection(_consultantsCollection).doc(consultantDoc.id).delete()
      );
      
      // Pasul 4: Sterge utilizatorul din Firebase Auth daca avem email-ul
      final consultantData = consultantDoc.data() as Map<String, dynamic>;
      final email = consultantData['email'] as String?;
      
      if (email != null && email.isNotEmpty) {
        // Salvam email-ul pentru verificari viitoare
        await deleteAuthUserByEmail(email);
        return {
          'success': true,
          'message': 'Consultant sters cu succes',
        };
      } else {
        // Daca nu avem email, folosim email-ul generat
        final generatedEmail = _createEmailFromConsultantName(consultantName);
        await deleteAuthUserByEmail(generatedEmail);
        return {
          'success': true,
          'message': 'Consultant sters, dar nu s-a gasit email-ul in document. S-a incercat stergerea utilizatorului bazat pe email-ul generat.',
        };
      }
    } catch (e) {
      debugPrint("Error deleting consultant: $e");
      return {
        'success': false,
        'message': 'Eroare la stergerea consultantului: $e',
      };
    }
  }
  
  // Metoda ajutatoare pentru a sterge un utilizator din Firebase Auth dupa email
  // Nota: Aceasta metoda este pentru Firebase Admin SDK si NU va functiona direct in aplicatia client
  // Este inclusa ca referinta pentru implementare backend/cloud functions
  Future<void> deleteAuthUserByEmail(String email) async {
    try {
      // In aplicatia client, singura optiune este sa ne autentificam ca acel utilizator si apoi sa-l stergem
      // Aceasta necesita cunoasterea parolei, ceea ce in majoritatea cazurilor nu este posibil
      
      // Inlocuim fetchSignInMethodsForEmail (deprecated) cu o abordare diferita
      // In loc sa verificam daca exista contul, incercam direct operatiunea de stergere
      // sau marcam pentru stergere ulterioara printr-un Cloud Function
      
      debugPrint('Auth user deletion requested for email: $email');
      debugPrint('Note: Cannot delete from client app. Would require Cloud Function or Admin SDK.');
      
      // In realitate, aici ar trebui sa apelam un endpoint backend securizat sau Cloud Function
      // Exemplu pseudocod pentru Cloud Function (implementat in backend):
      // await cloudFunctions.httpsCallable('deleteUserByEmail')({'email': email});
      
      // Pentru logging/debugging, putem incerca sa detectam daca contul exista
      // prin incercarea unei operatiuni benigne, dar nu este necesar pentru functionalitate
      
    } catch (e) {
      debugPrint('Error in auth user deletion process: $e');
      // Transmitem eroarea mai departe pentru a fi gestionata de apelant
      rethrow;
    }
  }

  // Get consultant names for dropdown
  Future<List<String>> getConsultantNames() async {
    try {
      final snapshot = await _threadHandler.executeOnPlatformThread(() =>
        _firestore.collection(_consultantsCollection).get()
      );
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      debugPrint('Error fetching consultant names: $e');
      return [];
    }
  }

  // Sign out
  Future<void> signOut() async {
    debugPrint('🟣 AUTH_SERVICE: signOut called');
    debugPrint('🟣 AUTH_SERVICE: Current user before signOut: ${_auth.currentUser?.email ?? 'null'}');
    
    await _auth.signOut();
    
    debugPrint('🟣 AUTH_SERVICE: signOut completed');
    debugPrint('🟣 AUTH_SERVICE: Current user after signOut: ${_auth.currentUser?.email ?? 'null'}');
  }
}

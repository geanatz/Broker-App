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

  // Collection names
  final String _consultantsCollection = 'consultants';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create email from consultant name (for Firebase Auth)
  String _createEmailFromConsultantName(String consultantName) {
    // Transforma numele consultantului intr-un email valid pentru Firebase Auth
    // Inlocuieste spatiile cu underscore si adauga un domeniu
    return '${consultantName.trim().replaceAll(' ', '_').toLowerCase()}@brokerapp.dev';
  }

  // Register consultant
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
      
      // Verifica daca email-ul este deja folosit
      final email = _createEmailFromConsultantName(consultantName);
      debugPrint('🟨 AUTH_SERVICE: Created email: $email');
      
      try {
        // Incearca sa creezi utilizatorul direct - Firebase va returna eroare daca email-ul exista
        // Aceasta este abordarea recomandata in loc de fetchSignInMethodsForEmail
        // Vom gestiona eroarea 'email-already-in-use' mai jos in catch block
      } catch (e) {
        // Ignoram eroarea de verificare, vom lasa Firebase sa gestioneze duplicatele
        debugPrint('Proceeding with user creation, Firebase will handle duplicates: $e');
      }

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

      // Genereaza token unic pentru resetarea parolei
      final token = _uuid.v4();
      debugPrint('🟨 AUTH_SERVICE: Generated token: ${token.substring(0, 8)}...');

      // Salveaza datele consultantului in Firestore, including token
      await _threadHandler.executeOnPlatformThread(() =>
        _firestore.collection(_consultantsCollection).doc(userCredential.user!.uid).set({
          'name': consultantName,
          'team': team,
          'createdAt': FieldValue.serverTimestamp(),
          'email': userCredential.user!.email,
          'token': token, // Store token directly in consultant document
        })
      );

      debugPrint('🟢 AUTH_SERVICE: Registration completed successfully');
      return {
        'success': true,
        'token': token,
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

  // Login consultant
  Future<Map<String, dynamic>> loginConsultant({
    required String consultantName,
    required String password,
  }) async {
    debugPrint('🔵 AUTH_SERVICE: Starting loginConsultant for: $consultantName');
    try {
      // In primul rand, verificam daca exista un consultant cu acest nume
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
          final creationTime = createdAt.toDate();
          if (mostRecentTime == null || creationTime.isAfter(mostRecentTime.toDate())) {
            mostRecentTime = createdAt;
            mostRecentDoc = doc;
          }
        } else {
            // Fallback if createdAt is missing, just take the first one
            mostRecentDoc ??= doc;
        }
      }
      
      // If loop didn't find any with timestamp, use the first doc as fallback
      mostRecentDoc ??= consultantsSnapshot.docs.first;
      
      // Obtinem ID-ul consultantului si alte date utile
      final consultantData = mostRecentDoc.data() as Map<String, dynamic>;
      
      // Incercam sa extragem email-ul stocat, daca exista
      String? storedEmail = consultantData['email'] as String?;
      String emailToUse;
      
      if (storedEmail != null && storedEmail.isNotEmpty) {
        // Folosim email-ul stocat explicit in document
        emailToUse = storedEmail;
      } else {
        // Generam email-ul standard (fallback if email wasn't stored during registration)
        debugPrint("Warning: Email not found in consultant document, generating from name.");
        emailToUse = _createEmailFromConsultantName(consultantName);
      }
      
      // Incercam autentificarea cu acest email si parola in Firebase Auth
      debugPrint('🔵 AUTH_SERVICE: Attempting Firebase signIn with email: $emailToUse');
      try {
        await _auth.signInWithEmailAndPassword(
          email: emailToUse,
          password: password,
        );
        
        debugPrint('🟢 AUTH_SERVICE: Firebase signIn successful for: $consultantName');
        debugPrint('🟢 AUTH_SERVICE: Current user after signIn: ${_auth.currentUser?.email ?? 'null'}');
        
        // Autentificare reusita - Nu returnam mesaj de succes pentru ca utilizatorul va fi navigat automat
        // AuthWrapper va detecta schimbarea si va naviga la MainScreen
        return {
          'success': true,
          'consultantData': consultantData,
        };
      } catch (authError) {
        debugPrint('🔴 AUTH_SERVICE: Firebase signIn failed: $authError');
        // Daca esueaza cu email-ul specific, verificam daca exista token pentru resetare
        if (authError is FirebaseAuthException) {
          debugPrint('🔴 AUTH_SERVICE: FirebaseAuthException code: ${authError.code}');
          if (authError.code == 'user-not-found' || authError.code == 'wrong-password') {
            // Check if consultant document has token
            if (consultantData.containsKey('token')) {
              return {
                'success': false,
                'message': 'Parola incorecta sau cont resetat. Verifica credentialele sau foloseste token-ul pentru a reseta parola.',
                'resetEnabled': true,
              };
            } else {
              return {
                'success': false,
                'message': 'Credentiale invalide. Verifica numele si parola.',
              };
            }
          }
        }
        
        debugPrint("Firebase Auth Error during login: ${authError is FirebaseAuthException ? authError.message : authError}");
        return {
          'success': false,
          'message': 'Eroare la autentificare. Parola gresita.',
          'details': authError.toString(),
        };
      }
    } catch (e) {
      debugPrint("General Error during login: $e");
      return {
        'success': false,
        'message': 'Eroare la autentificare: $e',
      };
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

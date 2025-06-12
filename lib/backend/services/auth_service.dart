import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';
import 'firebase_service.dart';
import 'settings_service.dart';

/// Enum pentru a defini stările/pașii posibili ai ecranului de autentificare.
/// Aceasta va controla ce popup este afișat.
enum AuthStep {
  /// Starea inițială sau nedefinită.
  initial,

  /// Afișează popup-ul de login.
  login,

  /// Afișează popup-ul de înregistrare.
  registration,
  
  /// Afișează popup-ul de confirmare a creării contului și afișare token.
  accountCreated,

  /// Afișează popup-ul pentru introducerea token-ului de resetare a parolei.
  tokenEntry,

  /// Afișează popup-ul pentru setarea unei noi parole după validarea token-ului.
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
    // Transformă numele consultantului într-un email valid pentru Firebase Auth
    // Înlocuiește spațiile cu underscore și adaugă un domeniu
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
      
      // Verifică dacă parolele se potrivesc
      if (password != confirmPassword) {
        debugPrint('🔴 AUTH_SERVICE: Passwords do not match');
        return {
          'success': false,
          'message': 'Parolele nu se potrivesc',
        };
      }

      // Verifică dacă numele consultantului este unic
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
          'message': 'Acest nume de consultant există deja',
        };
      }
      
      // Verifică dacă email-ul este deja folosit
      final email = _createEmailFromConsultantName(consultantName);
      debugPrint('🟨 AUTH_SERVICE: Created email: $email');
      
      try {
        // Încearcă să creezi utilizatorul direct - Firebase va returna eroare dacă email-ul există
        // Aceasta este abordarea recomandată în loc de fetchSignInMethodsForEmail
        // Vom gestiona eroarea 'email-already-in-use' mai jos în catch block
      } catch (e) {
        // Ignorăm eroarea de verificare, vom lăsa Firebase să gestioneze duplicatele
        debugPrint('Proceeding with user creation, Firebase will handle duplicates: $e');
      }

      debugPrint('🟨 AUTH_SERVICE: Creating Firebase user...');
      // Creează utilizator în Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('🟨 AUTH_SERVICE: Firebase user created: ${userCredential.user?.uid}');
      debugPrint('🟨 AUTH_SERVICE: User email: ${userCredential.user?.email}');

      // IMPORTANT: Facem signOut imediat pentru a preveni autentificarea automată
      debugPrint('🟨 AUTH_SERVICE: Doing immediate signOut to prevent auto-login');
      await _auth.signOut();
      debugPrint('🟨 AUTH_SERVICE: Immediate signOut completed');

      // Generează token unic pentru resetarea parolei
      final token = _uuid.v4();
      debugPrint('🟨 AUTH_SERVICE: Generated token: ${token.substring(0, 8)}...');

      // Salvează datele consultantului în Firestore, including token
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
          message = 'Parola este prea slabă';
          break;
        case 'email-already-in-use':
          message = 'Acest consultant există deja (email asociat)';
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
    try {
      // În primul rând, verificăm dacă există un consultant cu acest nume
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(() =>
        _firestore
          .collection(_consultantsCollection)
          .where('name', isEqualTo: consultantName)
          .get()
      );
      
      if (consultantsSnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Consultant negăsit',
        };
      }
      
      // Luăm cel mai recent document (în caz că există mai multe cu același nume)
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
      
      // Obținem ID-ul consultantului și alte date utile
      final consultantData = mostRecentDoc.data() as Map<String, dynamic>;
      
      // Încercăm să extragem email-ul stocat, dacă există
      String? storedEmail = consultantData['email'] as String?;
      String emailToUse;
      
      if (storedEmail != null && storedEmail.isNotEmpty) {
        // Folosim email-ul stocat explicit în document
        emailToUse = storedEmail;
      } else {
        // Generăm email-ul standard (fallback if email wasn't stored during registration)
        debugPrint("Warning: Email not found in consultant document, generating from name.");
        emailToUse = _createEmailFromConsultantName(consultantName);
      }
      
      // Încercăm autentificarea cu acest email și parolă în Firebase Auth
      try {
        await _auth.signInWithEmailAndPassword(
          email: emailToUse,
          password: password,
        );
        
        // Autentificare reușită - Nu returnăm mesaj de succes pentru că utilizatorul va fi navigat automat
        // AuthWrapper va detecta schimbarea și va naviga la MainScreen
        return {
          'success': true,
          'consultantData': consultantData,
        };
      } catch (authError) {
        // Dacă eșuează cu email-ul specific, verificăm dacă există token pentru resetare
        if (authError is FirebaseAuthException) {
          if (authError.code == 'user-not-found' || authError.code == 'wrong-password') {
            // Check if consultant document has token
            if (consultantData.containsKey('token')) {
              return {
                'success': false,
                'message': 'Parolă incorectă sau cont resetat. Verifică credențialele sau folosește token-ul pentru a reseta parola.',
                'resetEnabled': true,
              };
            } else {
              return {
                'success': false,
                'message': 'Credențiale invalide. Verifică numele și parola.',
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
      // Caută token-ul în documentele consultant
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

      // Obține ID-ul consultantului asociat cu token-ul
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
      // Obține datele consultantului
      final consultantDoc = await _threadHandler.executeOnPlatformThread(() =>
        _firestore
          .collection(_consultantsCollection)
          .doc(consultantId)
          .get()
      );

      if (!consultantDoc.exists) {
        return {
          'success': false,
          'message': 'Consultant negăsit',
        };
      }

      final consultantData = consultantDoc.data() as Map<String, dynamic>;
      final email = consultantData['email'] as String?;

      if (email == null || email.isEmpty) {
        return {
          'success': false,
          'message': 'Email consultant lipsă',
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
        'message': 'Token valid. Resetarea parolei necesită implementare backend/cloud function sau flux Firebase standard (email).',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la resetarea parolei: $e',
      };
    }
  }

  // Șterge un consultant după nume
  Future<Map<String, dynamic>> deleteConsultantByName(String consultantName) async {
    try {
      // Pasul 1: Găsește consultantul în Firestore după nume
      final consultantsSnapshot = await _threadHandler.executeOnPlatformThread(() =>
        _firestore
          .collection(_consultantsCollection)
          .where('name', isEqualTo: consultantName)
          .get()
      );
          
      if (consultantsSnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Consultant negăsit',
        };
      }
      
      // Luăm cel mai recent document cu numele specificat
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
      
      // Pasul 2: Șterge setările temei pentru consultantul respectiv
      try {
        final settingsService = SettingsService();
        await settingsService.clearConsultantSettings(consultantId);
      } catch (e) {
        debugPrint('Error clearing consultant theme settings: $e');
        // Continue with deletion even if settings clearing fails
      }
      
      // Pasul 3: Șterge documentul din Firestore
      await _threadHandler.executeOnPlatformThread(() =>
        _firestore.collection(_consultantsCollection).doc(consultantDoc.id).delete()
      );
      
      // Pasul 4: Șterge utilizatorul din Firebase Auth dacă avem email-ul
      final consultantData = consultantDoc.data() as Map<String, dynamic>;
      final email = consultantData['email'] as String?;
      
      if (email != null && email.isNotEmpty) {
        // Salvăm email-ul pentru verificări viitoare
        await deleteAuthUserByEmail(email);
        return {
          'success': true,
          'message': 'Consultant șters cu succes',
        };
      } else {
        // Dacă nu avem email, folosim email-ul generat
        final generatedEmail = _createEmailFromConsultantName(consultantName);
        await deleteAuthUserByEmail(generatedEmail);
        return {
          'success': true,
          'message': 'Consultant șters, dar nu s-a găsit email-ul în document. S-a încercat ștergerea utilizatorului bazat pe email-ul generat.',
        };
      }
    } catch (e) {
      debugPrint("Error deleting consultant: $e");
      return {
        'success': false,
        'message': 'Eroare la ștergerea consultantului: $e',
      };
    }
  }
  
  // Metodă ajutătoare pentru a șterge un utilizator din Firebase Auth după email
  // Notă: Această metodă este pentru Firebase Admin SDK și NU va funcționa direct în aplicația client
  // Este inclusă ca referință pentru implementare backend/cloud functions
  Future<void> deleteAuthUserByEmail(String email) async {
    try {
      // În aplicația client, singura opțiune este să ne autentificăm ca acel utilizator și apoi să-l ștergem
      // Aceasta necesită cunoașterea parolei, ceea ce în majoritatea cazurilor nu este posibil
      
      // Înlocuim fetchSignInMethodsForEmail (deprecated) cu o abordare diferită
      // În loc să verificăm dacă există contul, încercăm direct operațiunea de ștergere
      // sau marcăm pentru ștergere ulterioară printr-un Cloud Function
      
      debugPrint('Auth user deletion requested for email: $email');
      debugPrint('Note: Cannot delete from client app. Would require Cloud Function or Admin SDK.');
      
      // În realitate, aici ar trebui să apelăm un endpoint backend securizat sau Cloud Function
      // Exemplu pseudocod pentru Cloud Function (implementat în backend):
      // await cloudFunctions.httpsCallable('deleteUserByEmail')({'email': email});
      
      // Pentru logging/debugging, putem încerca să detectăm dacă contul există
      // prin încercarea unei operațiuni benigne, dar nu este necesar pentru funcționalitate
      
    } catch (e) {
      debugPrint('Error in auth user deletion process: $e');
      // Transmitem eroarea mai departe pentru a fi gestionată de apelant
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

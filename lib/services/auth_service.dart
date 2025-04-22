import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Collection names
  final String _consultantsCollection = 'consultants';
  final String _tokensCollection = 'tokens';

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
      // Verifică dacă parolele se potrivesc
      if (password != confirmPassword) {
        return {
          'success': false,
          'message': 'Parolele nu se potrivesc',
        };
      }

      // Verifică dacă numele consultantului este unic
      final consultantSnapshot = await _firestore
          .collection(_consultantsCollection)
          .where('name', isEqualTo: consultantName)
          .get();

      if (consultantSnapshot.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Acest nume de consultant există deja',
        };
      }

      // Creează utilizator în Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _createEmailFromConsultantName(consultantName),
        password: password,
      );

      // Generează token unic pentru resetarea parolei
      final token = _uuid.v4();

      // Salvează datele consultantului în Firestore
      await _firestore.collection(_consultantsCollection).doc(userCredential.user!.uid).set({
        'name': consultantName,
        'team': team,
        'createdAt': FieldValue.serverTimestamp(),
        'email': userCredential.user!.email,
      });

      // Salvează token-ul în Firestore
      await _firestore.collection(_tokensCollection).doc(userCredential.user!.uid).set({
        'token': token,
        'consultantId': userCredential.user!.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'token': token,
        'message': 'Cont creat cu succes',
      };
    } on FirebaseAuthException catch (e) {
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
      final consultantsSnapshot = await _firestore
          .collection(_consultantsCollection)
          .where('name', isEqualTo: consultantName)
          .get();
      
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
            if (mostRecentDoc == null) mostRecentDoc = doc;
        }
      }
      
      // If loop didn't find any with timestamp, use the first doc as fallback
      mostRecentDoc ??= consultantsSnapshot.docs.first;
      
      // Obținem ID-ul consultantului și alte date utile
      final consultantId = mostRecentDoc.id;
      final consultantData = mostRecentDoc.data() as Map<String, dynamic>;
      
      // Încercăm să extragem email-ul stocat, dacă există
      String? storedEmail = consultantData['email'] as String?;
      String emailToUse;
      
      if (storedEmail != null && storedEmail.isNotEmpty) {
        // Folosim email-ul stocat explicit în document
        emailToUse = storedEmail;
      } else {
        // Generăm email-ul standard (fallback if email wasn't stored during registration)
        print("Warning: Email not found in consultant document, generating from name.");
        emailToUse = _createEmailFromConsultantName(consultantName);
      }
      
      // Încercăm autentificarea cu acest email
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: emailToUse,
          password: password,
        );
        
        // Autentificare reușită
        return {
          'success': true,
          'message': 'Autentificare reușită',
          'consultantData': consultantData,
        };
      } catch (authError) {
        // Dacă eșuează cu email-ul specific, verificăm dacă există token pentru resetare
        if (authError is FirebaseAuthException) {
          if (authError.code == 'user-not-found' || authError.code == 'wrong-password') {
            final tokenDoc = await _firestore
                .collection(_tokensCollection)
                .doc(consultantId)
                .get();
            
            if (tokenDoc.exists) {
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
        
        print("Firebase Auth Error during login: ${authError is FirebaseAuthException ? authError.message : authError}");
        return {
          'success': false,
          'message': 'Eroare la autentificare. Verificați email-ul ($emailToUse) și parola.',
          'details': authError.toString(),
        };
      }
    } catch (e) {
      print("General Error during login: $e");
      return {
        'success': false,
        'message': 'Eroare la autentificare: $e',
      };
    }
  }

  // Verify token and get consultant ID
  Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      // Caută token-ul în Firestore
      final tokenSnapshot = await _firestore
          .collection(_tokensCollection)
          .where('token', isEqualTo: token)
          .get();

      if (tokenSnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Token invalid',
        };
      }

      // Obține ID-ul consultantului asociat cu token-ul
      final tokenData = tokenSnapshot.docs.first.data();
      final consultantId = tokenData['consultantId'];

      if (consultantId == null) {
         return {
          'success': false,
          'message': 'Token invalid (lipsește ID consultant).',
        };
      }

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
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        return {
          'success': false,
          'message': 'Parolele nu se potrivesc',
        };
      }

      // Verifică token-ul și obține consultantId
      final tokenVerificationResult = await verifyToken(token);
      if (!tokenVerificationResult['success']) {
        return tokenVerificationResult;
      }
      final consultantId = tokenVerificationResult['consultantId'];

      // Găsește documentul consultantului pentru a obține email-ul
      final consultantDoc = await _firestore
          .collection(_consultantsCollection)
          .doc(consultantId)
          .get();

      if (!consultantDoc.exists) {
        return {
          'success': false,
          'message': 'Consultant asociat token-ului nu a fost găsit.',
        };
      }

      final consultantData = consultantDoc.data() as Map<String, dynamic>;
      final email = consultantData['email'] as String?;

      if (email == null || email.isEmpty) {
        return {
          'success': false,
          'message': 'Email-ul consultantului lipsește. Contactați administratorul.',
        };
      }

      // Firebase Auth nu permite direct resetarea parolei cu token custom și email/parola veche.
      // Abordare: Actualizăm parola direct în Firebase Auth pentru utilizatorul găsit.
      // ATENȚIE: Această abordare necesită ca admin-ul (sau o funcție cloud) să aibă drepturi de a actualiza parole.
      // O alternativă mai sigură este folosirea fluxului standard Firebase Auth de resetare parolă (trimite email).
      // Pentru moment, simulăm actualizarea (presupunând că avem drepturi, ceea ce NU este cazul pe client)
      // În realitate, acest pas ar trebui făcut printr-un backend securizat sau Cloud Function.

      // Căutăm utilizatorul în Firebase Auth după email
      // Acest pas poate eșua dacă email-ul nu e unic sau nu corespunde.
      // String uid = _auth.getUserByEmail(email); // Needs Admin SDK

      // --- ÎNLOCUIRE CU FLUX STANDARD FIREBASE AUTH --- 
      // Fluxul standard trimite un email utilizatorului cu un link de resetare.
      // Nu putem actualiza parola direct din aplicația client în acest mod securizat.
      // await _auth.sendPasswordResetEmail(email: email);

      // --- SOLUȚIE TEMPORARĂ (NESIGURĂ/INCOMPLETĂ PENTRU PRODUCȚIE) ---
      // Re-autentificăm utilizatorul temporar cu email-ul și o parolă fictivă (dacă am avea-o)
      // Apoi actualizăm parola.
      // SAU: stocăm parola direct în Firestore (NESIGUR!) și o actualizăm aici.
      // Vom alege să actualizăm doar parola stocată în Firestore (DACĂ ar fi stocată acolo)
      // și să ștergem token-ul.
      
      // Șterge token-ul după utilizare
      await _firestore.collection(_tokensCollection).doc(consultantId).delete();

      return {
        'success': true,
        'message': 'Token valid. Resetarea parolei necesită implementare backend/cloud function sau flux Firebase standard (email).',
      };

    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': 'Eroare Firebase la resetarea parolei: ${e.message}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la resetarea parolei: $e',
      };
    }
  }

  // Get consultant names for dropdown
  Future<List<String>> getConsultantNames() async {
    try {
      final snapshot = await _firestore.collection(_consultantsCollection).get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      print('Error fetching consultant names: $e');
      return [];
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
} 
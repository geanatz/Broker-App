import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // Collection names
  final String _agentsCollection = 'agents';
  final String _tokensCollection = 'tokens';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create email from agent name (for Firebase Auth)
  String _createEmailFromAgentName(String agentName) {
    // Transformă numele agentului într-un email valid pentru Firebase Auth
    // Înlocuiește spațiile cu underscore și adaugă un domeniu
    return '${agentName.trim().replaceAll(' ', '_').toLowerCase()}@brokerapp.dev';
  }

  // Register agent
  Future<Map<String, dynamic>> registerAgent({
    required String agentName,
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

      // Verifică dacă numele agentului este unic
      final agentSnapshot = await _firestore
          .collection(_agentsCollection)
          .where('name', isEqualTo: agentName)
          .get();

      if (agentSnapshot.docs.isNotEmpty) {
        return {
          'success': false,
          'message': 'Acest nume de agent există deja',
        };
      }

      // Creează utilizator în Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _createEmailFromAgentName(agentName),
        password: password,
      );

      // Generează token unic pentru resetarea parolei
      final token = _uuid.v4();

      // Salvează datele agentului în Firestore
      await _firestore.collection(_agentsCollection).doc(userCredential.user!.uid).set({
        'name': agentName,
        'team': team,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Salvează token-ul în Firestore
      await _firestore.collection(_tokensCollection).doc(userCredential.user!.uid).set({
        'token': token,
        'agentId': userCredential.user!.uid,
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
          message = 'Acest agent există deja';
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

  // Login agent
  Future<Map<String, dynamic>> loginAgent({
    required String agentName,
    required String password,
  }) async {
    try {
      // În primul rând, verificăm dacă există un agent cu acest nume
      final agentsSnapshot = await _firestore
          .collection(_agentsCollection)
          .where('name', isEqualTo: agentName)
          .get();
      
      if (agentsSnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Agent negăsit',
        };
      }
      
      // Luăm cel mai recent document (în caz că există mai multe cu același nume)
      DocumentSnapshot? mostRecentDoc;
      DateTime? mostRecentTime;
      
      for (var doc in agentsSnapshot.docs) {
        final createdAt = doc.data()?['createdAt'] as Timestamp?;
        if (createdAt != null) {
          final creationTime = createdAt.toDate();
          if (mostRecentTime == null || creationTime.isAfter(mostRecentTime)) {
            mostRecentTime = creationTime;
            mostRecentDoc = doc;
          }
        }
      }
      
      if (mostRecentDoc == null) {
        mostRecentDoc = agentsSnapshot.docs.first; // Fallback
      }
      
      // Obținem ID-ul agentului și alte date utile
      final agentId = mostRecentDoc.id;
      final agentData = mostRecentDoc.data() as Map<String, dynamic>;
      
      // Încercăm să extragem email-ul stocat, dacă există
      String? storedEmail = agentData['email'] as String?;
      String emailToUse;
      
      if (storedEmail != null) {
        // Folosim email-ul stocat explicit în document
        emailToUse = storedEmail;
      } else {
        // Generăm email-ul standard
        emailToUse = _createEmailFromAgentName(agentName);
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
          'agentData': agentData,
        };
      } catch (authError) {
        // Dacă eșuează cu email-ul specific, verificăm dacă există token pentru resetare
        if (authError is FirebaseAuthException) {
          if (authError.code == 'user-not-found' || authError.code == 'wrong-password') {
            final tokenDoc = await _firestore
                .collection(_tokensCollection)
                .doc(agentId)
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
        
        return {
          'success': false,
          'message': 'Eroare la autentificare: ${authError is FirebaseAuthException ? authError.message : authError}',
          'details': authError.toString(),
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la autentificare: $e',
      };
    }
  }

  // Verify token and get agent ID
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

      // Obține ID-ul agentului asociat cu token-ul
      final tokenData = tokenSnapshot.docs.first.data();
      final agentId = tokenData['agentId'];

      return {
        'success': true,
        'agentId': agentId,
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
      // Verifică dacă parolele se potrivesc
      if (newPassword != confirmPassword) {
        return {
          'success': false,
          'message': 'Parolele nu se potrivesc',
        };
      }

      // Verifică token-ul și obține ID-ul agentului
      final verifyResult = await verifyToken(token);
      
      if (!verifyResult['success']) {
        return verifyResult;
      }

      final agentId = verifyResult['agentId'];

      // Obține datele agentului
      final agentDoc = await _firestore
          .collection(_agentsCollection)
          .doc(agentId)
          .get();

      if (!agentDoc.exists) {
        return {
          'success': false,
          'message': 'Agent negăsit',
        };
      }

      // Obține numele agentului
      final agentName = agentDoc.data()?['name'];
      final teamName = agentDoc.data()?['team'];
      
      if (agentName == null) {
        return {
          'success': false,
          'message': 'Date agent invalide',
        };
      }

      // Generăm un token nou pentru resetări viitoare
      final newToken = _uuid.v4();
      
      // Încercăm să ștergem contul vechi, dar doar dacă știm parola veche
      // Deoarece nu avem parola veche, nu putem șterge contul vechi direct
      
      // În schimb, vom crea un cont nou cu un alt email și vom transfera datele
      
      // Generăm un email nou unic cu timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newEmail = '${agentName.trim().replaceAll(' ', '_').toLowerCase()}_reset_$timestamp@brokerapp.dev';
      
      // Creăm contul nou
      try {
        final newUserCredential = await _auth.createUserWithEmailAndPassword(
          email: newEmail,
          password: newPassword,
        );
        
        final newUserId = newUserCredential.user!.uid;
        
        // Transferăm datele către contul nou
        await _firestore.collection(_agentsCollection).doc(newUserId).set({
          'name': agentName,
          'team': teamName,
          'createdAt': FieldValue.serverTimestamp(),
          'previousId': agentId, // Referință către ID-ul vechi
          'email': newEmail, // Stocăm explicit email-ul pentru referință ulterioară
        });
        
        // Actualizăm token-ul
        await _firestore.collection(_tokensCollection).doc(newUserId).set({
          'token': newToken,
          'agentId': newUserId,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Marcăm documentele vechi ca fiind înlocuite
        await _firestore.collection(_agentsCollection).doc(agentId).update({
          'replaced': true,
          'replacedBy': newUserId,
        });
        
        // Ne asigurăm că suntem delogați
        await _auth.signOut();
        
        return {
          'success': true,
          'message': 'Parola a fost resetată cu succes. Te poți conecta acum cu noua parolă.',
          'newToken': newToken,
          'username': agentName,
          'newEmail': newEmail, // Includem și email-ul nou pentru debugging
        };
      } catch (authError) {
        if (authError is FirebaseAuthException && authError.code == 'email-already-in-use') {
          // Acest email este deja folosit, generăm altul
          final timestampRetry = DateTime.now().millisecondsSinceEpoch + 1;
          final newEmailRetry = '${agentName.trim().replaceAll(' ', '_').toLowerCase()}_retry_$timestampRetry@brokerapp.dev';
          
          try {
            final newUserCredential = await _auth.createUserWithEmailAndPassword(
              email: newEmailRetry,
              password: newPassword,
            );
            
            final newUserId = newUserCredential.user!.uid;
            
            // Transferăm datele către contul nou
            await _firestore.collection(_agentsCollection).doc(newUserId).set({
              'name': agentName,
              'team': teamName,
              'createdAt': FieldValue.serverTimestamp(),
              'previousId': agentId,
              'email': newEmailRetry,
            });
            
            // Actualizăm token-ul
            await _firestore.collection(_tokensCollection).doc(newUserId).set({
              'token': newToken,
              'agentId': newUserId,
              'createdAt': FieldValue.serverTimestamp(),
            });
            
            // Marcăm documentele vechi ca fiind înlocuite
            await _firestore.collection(_agentsCollection).doc(agentId).update({
              'replaced': true,
              'replacedBy': newUserId,
            });
            
            // Ne asigurăm că suntem delogați
            await _auth.signOut();
            
            return {
              'success': true,
              'message': 'Parola a fost resetată cu succes. Te poți conecta acum cu noua parolă.',
              'newToken': newToken,
              'username': agentName,
              'newEmail': newEmailRetry,
            };
          } catch (e) {
            return {
              'success': false,
              'message': 'Eroare la resetarea parolei (încercare #2): $e',
            };
          }
        }
        
        return {
          'success': false,
          'message': 'Eroare la resetarea parolei: $authError',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la resetarea parolei: $e',
      };
    }
  }

  // Get available agent names (for dropdown)
  Future<List<String>> getAgentNames() async {
    try {
      final agentsSnapshot = await _firestore.collection(_agentsCollection).get();
      
      // Extragem toate numele și eliminăm duplicatele
      final Set<String> uniqueNames = {};
      for (var doc in agentsSnapshot.docs) {
        final name = doc.data()['name'] as String?;
        if (name != null) {
          uniqueNames.add(name);
        }
      }
      
      return uniqueNames.toList();
    } catch (e) {
      print('Eroare la obținerea numelor agenților: $e');
      return [];
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Metodă ajutătoare pentru a face sign in și a obține datele agentului
  Future<Map<String, dynamic>> getAgentDataByName(String agentName) async {
    try {
      final agentsSnapshot = await _firestore
          .collection(_agentsCollection)
          .where('name', isEqualTo: agentName)
          .get();
      
      if (agentsSnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Agent negăsit',
        };
      }
      
      return {
        'success': true,
        'agentData': agentsSnapshot.docs.first.data(),
        'agentId': agentsSnapshot.docs.first.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Eroare la obținerea datelor agentului: $e',
      };
    }
  }
} 
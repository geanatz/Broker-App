import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// User roles supported by the app
enum UserRole {
  supervisor,
  consultant,
}

extension UserRoleString on UserRole {
  String get asString {
    switch (this) {
      case UserRole.supervisor:
        return 'Supervisor';
      case UserRole.consultant:
        return 'Consultant';
    }
  }

  static UserRole fromString(String? raw) {
    switch ((raw ?? '').toLowerCase()) {
      case 'supervisor':
        return UserRole.supervisor;
      case 'consultant':
      default:
        return UserRole.consultant;
    }
  }
}

/// Centralized role management with lightweight caching
class RoleService {
  // Singleton
  static final RoleService _instance = RoleService._internal();
  factory RoleService() => _instance;
  RoleService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache
  UserRole _currentRole = UserRole.consultant;
  String? _cachedUid;
  DateTime? _lastLoadTime;

  // TTL for cache to avoid frequent reads
  static const Duration _cacheTtl = Duration(minutes: 5);

  UserRole get currentRole => _currentRole;
  bool get isSupervisor => _currentRole == UserRole.supervisor;
  bool get isConsultant => _currentRole == UserRole.consultant;

  /// Refresh role from Firestore if cache expired or user changed
  Future<UserRole> refreshRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      _currentRole = UserRole.consultant;
      _cachedUid = null;
      _lastLoadTime = null;
      return _currentRole;
    }

    final now = DateTime.now();
    if (_cachedUid == user.uid &&
        _lastLoadTime != null &&
        now.difference(_lastLoadTime!) < _cacheTtl) {
      return _currentRole;
    }

    try {
      final doc = await _firestore.collection('consultants').doc(user.uid).get();
      String? roleString;
      if (doc.exists) {
        final data = doc.data();
        roleString = data?['role'] as String?;
      }

      _currentRole = UserRoleString.fromString(roleString);
      _cachedUid = user.uid;
      _lastLoadTime = now;
    } catch (_) {
      // Keep default consultant on error
      _currentRole = UserRole.consultant;
      _cachedUid = user.uid;
      _lastLoadTime = now;
    }
    return _currentRole;
  }
}






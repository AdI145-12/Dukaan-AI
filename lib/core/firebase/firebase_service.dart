import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Single entry point for all Firebase services.
class FirebaseService {
  FirebaseService._();

  static dynamic _dbOverride;
  static dynamic _authOverride;
  static dynamic _storeOverride;

  /// Firestore database handle.
  static dynamic get db => _dbOverride ?? FirebaseFirestore.instance;

  /// FirebaseAuth handle.
  static dynamic get auth => _authOverride ?? FirebaseAuth.instance;

  /// FirebaseStorage handle.
  static dynamic get store => _storeOverride ?? FirebaseStorage.instance;

  /// Sets a temporary Firestore handle for tests.
  static void setDbOverride(dynamic value) {
    _dbOverride = value;
  }

  /// Sets a temporary FirebaseAuth handle for tests.
  static void setAuthOverride(dynamic value) {
    _authOverride = value;
  }

  /// Sets a temporary FirebaseStorage handle for tests.
  static void setStoreOverride(dynamic value) {
    _storeOverride = value;
  }

  /// Clears all temporary Firebase handle overrides.
  static void clearOverrides() {
    _dbOverride = null;
    _authOverride = null;
    _storeOverride = null;
  }

  /// Current authenticated user's UID. Null when signed out.
  static String? get currentUserId {
    try {
      final dynamic currentUser = auth.currentUser;
      final dynamic uid = currentUser?.uid;
      return uid is String ? uid : null;
    } catch (_) {
      return null;
    }
  }

  /// Current authenticated user's phone number when available.
  static String? get currentUserPhone {
    try {
      final dynamic currentUser = auth.currentUser;
      final dynamic phone = currentUser?.phoneNumber;
      if (phone is String && phone.isNotEmpty) {
        return phone;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Returns a best-effort Firebase ID token for Authorization header.
  static Future<String?> currentIdToken() async {
    try {
      final dynamic currentUser = auth.currentUser;
      if (currentUser == null) {
        return null;
      }
      final dynamic token = await currentUser.getIdToken();
      return token is String ? token : null;
    } catch (_) {
      return null;
    }
  }

  /// Firestore server timestamp token.
  static Object serverTimestamp() => FieldValue.serverTimestamp();
}

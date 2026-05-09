import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_providers.g.dart';

/// Shared Firestore instance provider.
@riverpod
FirebaseFirestore firestore(Ref ref) {
  return FirebaseFirestore.instance;
}

/// Current authenticated user id (empty when signed out).
@riverpod
String currentUserId(Ref ref) {
  return FirebaseService.currentUserId ?? '';
}

// FIREBASE SETUP REQUIRED:
// 1. Firebase Console → Authentication → Sign-in method → Google → Enable
// 2. Project Settings → Android App → Add SHA-1 fingerprint
//    Run: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android
// 3. Re-download google-services.json → replace android/app/google-services.json
// 4. pubspec.yaml: add google_sign_in: ^6.2.1 under dependencies

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dukaan_ai/core/errors/app_exception.dart';
import 'package:dukaan_ai/core/errors/error_handler.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/auth/domain/models/user_profile.dart';
import 'package:dukaan_ai/features/auth/domain/repositories/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
	AuthRepositoryImpl({
		FirebaseAuth? auth,
		FirebaseFirestore? firestore,
		GoogleSignIn? googleSignIn,
	}) : _auth = auth ?? FirebaseAuth.instance,
		 _firestore = firestore ?? FirebaseFirestore.instance,
		 _googleSignIn = googleSignIn ?? GoogleSignIn(
			 scopes: const <String>['email', 'profile'],
		 );

	final FirebaseAuth _auth;
	final FirebaseFirestore _firestore;
	final GoogleSignIn _googleSignIn;
	String? _verificationId;

	@override
	Future<void> sendPhoneOtp(String phoneNumber) async {
		final String normalizedPhone = _normalizePhoneNumber(phoneNumber);
		try {
			final Completer<void> completer = Completer<void>();
			await _auth.verifyPhoneNumber(
				phoneNumber: normalizedPhone,
				verificationCompleted: (PhoneAuthCredential credential) async {
					await _auth.signInWithCredential(credential);
					if (!completer.isCompleted) {
						completer.complete();
					}
				},
				verificationFailed: (FirebaseAuthException error) {
					if (!completer.isCompleted) {
						completer.completeError(ErrorHandler.fromFirebaseAuth(error));
					}
				},
				codeSent: (String verificationId, int? resendToken) {
					_verificationId = verificationId;
					if (!completer.isCompleted) {
						completer.complete();
					}
				},
				codeAutoRetrievalTimeout: (String verificationId) {
					_verificationId = verificationId;
					if (!completer.isCompleted) {
						completer.complete();
					}
				},
			);
			await completer.future;
		} on FirebaseAuthException catch (error) {
			throw ErrorHandler.fromFirebaseAuth(error);
		}
	}

	@override
	Future<UserProfile?> verifyPhoneOtp(String smsCode) async {
		final String? verificationId = _verificationId;
		if (verificationId == null || verificationId.isEmpty) {
			throw const AppException.unknown('Phone OTP verification id is missing');
		}

		try {
			final PhoneAuthCredential credential = PhoneAuthProvider.credential(
				verificationId: verificationId,
				smsCode: smsCode,
			);
			final UserCredential userCredential = await _auth.signInWithCredential(credential);
			return _loadOrCreateProfile(userCredential.user);
		} on FirebaseAuthException catch (error) {
			throw ErrorHandler.fromFirebaseAuth(error);
		} on FirebaseException catch (error) {
			throw ErrorHandler.fromFirestore(error);
		}
	}

	@override
	Future<UserProfile?> signInWithGoogle() async {
		try {
			final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
			if (googleUser == null) {
				throw const AppException.cancelled('Sign in cancelled');
			}

			final GoogleSignInAuthentication googleAuth =
					await googleUser.authentication;
			final AuthCredential credential = GoogleAuthProvider.credential(
				idToken: googleAuth.idToken,
				accessToken: googleAuth.accessToken,
			);
			final UserCredential userCredential =
					await _auth.signInWithCredential(credential);
			return _loadOrCreateProfile(userCredential.user,
				fallbackEmail: googleUser.email,
				fallbackDisplayName: googleUser.displayName,
				fallbackPhotoUrl: googleUser.photoUrl,
			);
		} on FirebaseAuthException catch (error) {
			throw ErrorHandler.fromFirebaseAuth(error);
		} on FirebaseException catch (error) {
			throw ErrorHandler.fromFirestore(error);
		}
	}

	@override
	Future<UserProfile?> getProfile(String userId) async {
		try {
			final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
					.collection('profiles')
					.doc(userId)
					.get();
			if (!snapshot.exists) {
				return null;
			}
			final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
			return UserProfile.fromJson(<String, dynamic>{
				...data,
				'id': snapshot.id,
			});
		} on FirebaseException catch (error) {
			throw ErrorHandler.fromFirestore(error);
		}
	}

	@override
	Future<void> signOut() async {
		await Future.wait<void>(<Future<void>>[
			_auth.signOut(),
			_googleSignIn.signOut(),
		]);
		_verificationId = null;
	}

	Future<UserProfile?> _loadOrCreateProfile(
		User? firebaseUser, {
		String? fallbackEmail,
		String? fallbackDisplayName,
		String? fallbackPhotoUrl,
	}) async {
		final User? currentUser = firebaseUser;
		if (currentUser == null) {
			throw const AppException.unknown('Firebase user missing');
		}

		try {
			final DocumentReference<Map<String, dynamic>> docRef = _firestore
					.collection('profiles')
					.doc(currentUser.uid);
			final DocumentSnapshot<Map<String, dynamic>> snapshot = await docRef.get();
			if (snapshot.exists) {
				final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
				return UserProfile.fromJson(<String, dynamic>{
					...data,
					'id': snapshot.id,
				});
			}

			await docRef.set(<String, dynamic>{
				'id': currentUser.uid,
				'email': currentUser.email ?? fallbackEmail,
				'displayName': currentUser.displayName ?? fallbackDisplayName,
				'photoUrl': currentUser.photoURL ?? fallbackPhotoUrl,
				'createdAt': FirebaseService.serverTimestamp(),
				'onboardingComplete': false,
			}, SetOptions(merge: true));
			return null;
		} on FirebaseException catch (error) {
			throw ErrorHandler.fromFirestore(error);
		}
	}

	String _normalizePhoneNumber(String phoneNumber) {
		final String digitsOnly = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
		if (digitsOnly.startsWith('+')) {
			return digitsOnly;
		}
		return '+91$digitsOnly';
	}
}

@riverpod
AuthRepository authRepository(Ref ref) {
	return AuthRepositoryImpl();
}
import '../models/user_profile.dart';

/// Repository contract for auth flows.
abstract class AuthRepository {
	/// Starts Firebase phone verification and stores the verification id.
	Future<void> sendPhoneOtp(String phoneNumber);

	/// Completes Firebase phone sign-in with the entered SMS code.
	Future<UserProfile?> verifyPhoneOtp(String smsCode);

	/// Signs in with Google and returns the loaded profile, or null for a new user.
	Future<UserProfile?> signInWithGoogle();

	/// Loads the user's profile document from Firestore.
	Future<UserProfile?> getProfile(String userId);

	/// Signs out of Firebase and Google sessions.
	Future<void> signOut();
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
	const NotificationService._();

	/// Registers the current device FCM token and subscribes to token refresh.
	static Future<void> init() async {
		try {
			final String? userId = FirebaseService.currentUserId;
			if (userId == null || userId.isEmpty) {
				return;
			}

			final String? fcmToken = await FirebaseMessaging.instance.getToken();
			if (fcmToken != null && fcmToken.isNotEmpty) {
				await _saveToken(userId: userId, token: fcmToken);
			}

			FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) async {
				final String? refreshedUserId = FirebaseService.currentUserId;
				if (refreshedUserId == null || refreshedUserId.isEmpty) {
					return;
				}

				await _saveToken(userId: refreshedUserId, token: newToken);
			});
		} catch (error) {
			debugPrint('[NotificationService] init failed: $error');
		}
	}

	static Future<void> _saveToken({
		required String userId,
		required String token,
	}) async {
		try {
			// ASSUMPTION: merge options are passed dynamically until cloud_firestore is wired.
			await FirebaseService.db.collection('users').doc(userId).set(
				<String, dynamic>{'fcmToken': token},
				SetOptions(merge: true),
			);
		} catch (error) {
			debugPrint('[NotificationService] token sync failed: $error');
		}
	}
}
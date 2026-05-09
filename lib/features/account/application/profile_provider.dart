import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/account/domain/pricing_plans.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolves current user's tier from Firestore.
final FutureProvider<PlanTier> accountTierProvider =
		FutureProvider<PlanTier>((Ref ref) async {
	final String? userId = FirebaseService.currentUserId;
	if (userId == null || userId.trim().isEmpty) {
		return PlanTier.free;
	}

	try {
		final dynamic doc = await FirebaseService.db.collection('users').doc(userId).get();
		final bool exists = doc.exists as bool? ?? false;
		if (!exists) {
			return PlanTier.free;
		}

		final dynamic rawData = doc.data();
		if (rawData is Map<String, dynamic>) {
			final String tier = rawData['tier'] as String? ?? 'free';
			return planTierFromId(tier);
		}

		return PlanTier.free;
	} catch (_) {
		return PlanTier.free;
	}
});
import 'dart:async';

import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/khata/domain/khata_entry.dart';
import 'package:dukaan_ai/features/khata/domain/repositories/khata_repository.dart';
import 'package:dukaan_ai/features/khata/infrastructure/khata_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'khata_provider.g.dart';

@riverpod
Stream<List<KhataEntry>> khataEntries(Ref ref) {
	final KhataRepository repo = ref.watch(khataRepositoryProvider);
	// ASSUMPTION: Firebase auth is the source of truth for current user identity.
	final String userId = FirebaseService.currentUserId ?? '';
	if (userId.isEmpty) {
		return Stream<List<KhataEntry>>.value(const <KhataEntry>[]);
	}
	return repo.watchEntries(userId: userId);
}

@riverpod
class Khata extends _$Khata {
	@override
	FutureOr<void> build() async {}

	Future<void> addEntry({
		required String customerName,
		String? customerPhone,
		required double amount,
		String type = 'credit',
		String? note,
	}) async {
		final String userId = FirebaseService.currentUserId ?? '';
		if (userId.isEmpty) {
			return;
		}

		state = const AsyncLoading();
		state = await AsyncValue.guard(() async {
			await ref.read(khataRepositoryProvider).addEntry(
						userId: userId,
						customerName: customerName,
						customerPhone: customerPhone,
						amount: amount,
						type: type,
						note: note,
					);
		});
	}

	Future<void> updateAmount({required String id, required double newAmount}) async {
		state = const AsyncLoading();
		state = await AsyncValue.guard(() async {
			await ref.read(khataRepositoryProvider).updateAmount(
						id: id,
						newAmount: newAmount,
					);
		});
	}

	Future<void> markPaid({required String id}) async {
		state = const AsyncLoading();
		state = await AsyncValue.guard(() async {
			await ref.read(khataRepositoryProvider).markPaid(id: id);
		});
	}

	Future<void> deleteEntry({required String id}) async {
		state = const AsyncLoading();
		state = await AsyncValue.guard(() async {
			await ref.read(khataRepositoryProvider).deleteEntry(id: id);
		});
	}

	Future<void> sendReminderTracked({
		required String userId,
		required String entryId,
	}) async {
		unawaited(
			ref.read(khataRepositoryProvider).trackEvent(
						userId: userId,
						eventType: 'remindersent',
						metadata: <String, dynamic>{'entryId': entryId},
					),
		);
	}
}
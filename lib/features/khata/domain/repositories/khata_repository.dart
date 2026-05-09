import 'package:dukaan_ai/features/khata/domain/khata_entry.dart';

abstract class KhataRepository {
	/// Realtime stream for khata entries scoped to [userId].
	Stream<List<KhataEntry>> watchEntries({required String userId});

	/// Inserts a new khata entry.
	Future<void> addEntry({
		required String userId,
		required String customerName,
		String? customerPhone,
		required double amount,
		String type = 'credit',
		String? note,
	});

	/// Updates the pending amount for one entry.
	Future<void> updateAmount({required String id, required double newAmount});

	/// Marks one entry as paid.
	Future<void> markPaid({required String id});

	/// Deletes one entry permanently.
	Future<void> deleteEntry({required String id});

	/// Tracks analytics event for khata actions. Non-fatal usage.
	Future<void> trackEvent({
		required String userId,
		required String eventType,
		Map<String, dynamic>? metadata,
	});
}
import 'package:dukaan_ai/core/firebase/firebase_service.dart';
import 'package:dukaan_ai/features/inquiry/domain/inquiry_status.dart';
import 'package:dukaan_ai/features/inquiry/infrastructure/inquiry_repository_impl.dart';
import 'package:dukaan_ai/features/khata/infrastructure/khata_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'order_slip_actions_provider.g.dart';

/// Shared cross-feature actions used by the order slip module.
class InquiryOrderActions {
  const InquiryOrderActions(this._ref);

  final Ref _ref;

  /// Marks one inquiry as ordered.
  Future<void> markInquiryOrdered(String inquiryId) async {
    await _ref
        .read(inquiryRepositoryProvider)
        .updateStatus(inquiryId, InquiryStatus.ordered);
  }
}

/// Shared cross-feature actions used by the order slip module.
class KhataOrderActions {
  const KhataOrderActions(this._ref);

  final Ref _ref;

  /// Creates one khata debit entry for an order.
  Future<void> addOrderDebitEntry({
    required String customerName,
    String? customerPhone,
    required double amount,
    required String note,
  }) async {
    final String userId = FirebaseService.currentUserId ?? '';
    if (userId.trim().isEmpty) {
      return;
    }

    await _ref.read(khataRepositoryProvider).addEntry(
          userId: userId,
          customerName: customerName,
          customerPhone: customerPhone,
          amount: amount,
          type: 'debit',
          note: note,
        );
  }
}

@riverpod
InquiryOrderActions inquiryOrderActions(Ref ref) {
  return InquiryOrderActions(ref);
}

@riverpod
KhataOrderActions khataOrderActions(Ref ref) {
  return KhataOrderActions(ref);
}

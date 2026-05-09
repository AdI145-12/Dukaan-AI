import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';

/// Firestore contract for Order Slip persistence.
abstract class OrderSlipRepository {
  /// Returns all slips for one user, newest first.
  Future<List<OrderSlip>> getSlips(String userId);

  /// Creates a slip document and returns the saved slip with generated id.
  Future<OrderSlip> createSlip(OrderSlip slip);

  /// Updates only the screenshot/image url for one slip.
  Future<void> updateSlipImageUrl(String slipId, String imageUrl);

  /// Deletes one slip document.
  Future<void> deleteSlip(String slipId);

  /// Returns total slip count for one user.
  Future<int> getSlipCount(String userId);
}

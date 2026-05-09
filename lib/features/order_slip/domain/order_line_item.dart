import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_line_item.freezed.dart';

@freezed
abstract class OrderLineItem with _$OrderLineItem {
  const factory OrderLineItem({
    String? productId,
    required String productName,
    String? productImageUrl,
    required double unitPrice,
    @Default(1) int quantity,
    String? variantLabel,
  }) = _OrderLineItem;

  const OrderLineItem._();

  /// Returns quantity x unitPrice for this row.
  double get subtotal => unitPrice * quantity;

  /// Deserializes one Firestore nested map into an [OrderLineItem].
  factory OrderLineItem.fromMap(Map<String, dynamic> map) {
    return OrderLineItem(
      productId: _readNullableString(map[FirestoreFields.lineItemProductId]),
      productName: _readString(map[FirestoreFields.lineItemProductName]),
      productImageUrl: _readNullableString(
        map[FirestoreFields.lineItemProductImageUrl],
      ),
      unitPrice: _readDouble(map[FirestoreFields.lineItemUnitPrice]),
      quantity: _readInt(map[FirestoreFields.lineItemQuantity], fallback: 1),
      variantLabel: _readNullableString(map[FirestoreFields.lineItemVariantLabel]),
    );
  }

  /// Serializes one [OrderLineItem] into a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      FirestoreFields.lineItemProductId: productId,
      FirestoreFields.lineItemProductName: productName,
      FirestoreFields.lineItemProductImageUrl: productImageUrl,
      FirestoreFields.lineItemUnitPrice: unitPrice,
      FirestoreFields.lineItemQuantity: quantity,
      FirestoreFields.lineItemVariantLabel: variantLabel,
    };
  }
}

String _readString(Object? raw) {
  if (raw is String && raw.trim().isNotEmpty) {
    return raw.trim();
  }
  return '';
}

String? _readNullableString(Object? raw) {
  if (raw is String && raw.trim().isNotEmpty) {
    return raw.trim();
  }
  return null;
}

double _readDouble(Object? raw, {double fallback = 0}) {
  if (raw is num) {
    return raw.toDouble();
  }
  if (raw is String) {
    return double.tryParse(raw.trim()) ?? fallback;
  }
  return fallback;
}

int _readInt(Object? raw, {int fallback = 0}) {
  if (raw is num) {
    final int value = raw.toInt();
    return value < 1 ? fallback : value;
  }
  if (raw is String) {
    final int? parsed = int.tryParse(raw.trim());
    if (parsed == null) {
      return fallback;
    }
    return parsed < 1 ? fallback : parsed;
  }
  return fallback;
}

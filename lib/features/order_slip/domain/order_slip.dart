import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dukaan_ai/core/constants/app_strings.dart';
import 'package:dukaan_ai/core/constants/firestore_constants.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_slip.freezed.dart';

enum PaymentMode {
  upi,
  cash,
  cod,
  pending,
}

@freezed
abstract class OrderSlip with _$OrderSlip {
  const factory OrderSlip({
    required String id,
    required String userId,
    String? inquiryId,
    required String slipNumber,
    required String customerName,
    String? customerPhone,
    required List<OrderLineItem> lineItems,
    required double subtotal,
    @Default(0) double discountAmount,
    @Default(0) double deliveryCharge,
    required double total,
    @Default(PaymentMode.pending) PaymentMode paymentMode,
    String? upiId,
    String? deliveryNote,
    DateTime? expectedDeliveryDate,
    String? slipImageUrl,
    @Default(false) bool gstEnabled,
    required DateTime createdAt,
  }) = _OrderSlip;

  const OrderSlip._();

  /// Creates one [OrderSlip] model from a Firestore document snapshot.
  factory OrderSlip.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data() ?? <String, dynamic>{};
    final List<OrderLineItem> parsedLineItems = _readLineItems(
      data[FirestoreFields.orderSlipLineItems],
    );

    final double computedSubtotal = parsedLineItems.fold<double>(
      0,
      (double running, OrderLineItem item) => running + item.subtotal,
    );

    final double subtotal = _readDouble(
      data[FirestoreFields.orderSlipSubtotal],
      fallback: computedSubtotal,
    );
    final double discountAmount = _readDouble(
      data[FirestoreFields.orderSlipDiscountAmount],
      fallback: 0,
    );
    final double deliveryCharge = _readDouble(
      data[FirestoreFields.orderSlipDeliveryCharge],
      fallback: 0,
    );
    final double total = _readDouble(
      data[FirestoreFields.orderSlipTotal],
      fallback: subtotal - discountAmount + deliveryCharge,
    );

    return OrderSlip(
      id: doc.id,
      userId: _readString(data[FirestoreFields.orderSlipUserId]),
      inquiryId: _readNullableString(data[FirestoreFields.orderSlipInquiryId]),
      slipNumber: _readString(data[FirestoreFields.orderSlipNumber]),
      customerName: _readString(data[FirestoreFields.orderSlipCustomerName]),
      customerPhone: _readNullableString(
        data[FirestoreFields.orderSlipCustomerPhone],
      ),
      lineItems: parsedLineItems,
      subtotal: subtotal,
      discountAmount: discountAmount,
      deliveryCharge: deliveryCharge,
      total: total,
      paymentMode: paymentModeFromString(
        _readNullableString(data[FirestoreFields.orderSlipPaymentMode]),
      ),
      upiId: _readNullableString(data[FirestoreFields.orderSlipUpiId]),
      deliveryNote: _readNullableString(
        data[FirestoreFields.orderSlipDeliveryNote],
      ),
      expectedDeliveryDate: _readNullableDateTime(
        data[FirestoreFields.orderSlipExpectedDeliveryDate],
      ),
      slipImageUrl: _readNullableString(
        data[FirestoreFields.orderSlipSlipImageUrl],
      ),
      gstEnabled: data[FirestoreFields.orderSlipGstEnabled] as bool? ?? false,
      createdAt: _readDateTime(data[FirestoreFields.orderSlipCreatedAt]),
    );
  }

  /// Converts this model to Firestore write map, excluding [id].
  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      FirestoreFields.orderSlipUserId: userId,
      FirestoreFields.orderSlipInquiryId: inquiryId,
      FirestoreFields.orderSlipNumber: slipNumber,
      FirestoreFields.orderSlipCustomerName: customerName,
      FirestoreFields.orderSlipCustomerPhone: customerPhone,
      FirestoreFields.orderSlipLineItems: lineItems
          .map((OrderLineItem item) => item.toMap())
          .toList(growable: false),
      FirestoreFields.orderSlipSubtotal: subtotal,
      FirestoreFields.orderSlipDiscountAmount: discountAmount,
      FirestoreFields.orderSlipDeliveryCharge: deliveryCharge,
      FirestoreFields.orderSlipTotal: total,
      FirestoreFields.orderSlipPaymentMode: paymentModeToString(paymentMode),
      FirestoreFields.orderSlipUpiId: upiId,
      FirestoreFields.orderSlipDeliveryNote: deliveryNote,
      FirestoreFields.orderSlipExpectedDeliveryDate: expectedDeliveryDate,
      FirestoreFields.orderSlipSlipImageUrl: slipImageUrl,
      FirestoreFields.orderSlipGstEnabled: gstEnabled,
      FirestoreFields.orderSlipCreatedAt: createdAt,
    };
  }

  /// Returns rounded rupee amount for UI labels.
  String get formattedTotal => '₹${total.toStringAsFixed(0)}';

  /// WhatsApp-friendly summary message for one slip.
  String get whatsAppSummary {
    final StringBuffer buffer = StringBuffer()
      ..writeln('Namaste $customerName ji! 🙏')
      ..writeln('Aapka order confirm ho gaya hai:')
      ..writeln('');

    for (final OrderLineItem item in lineItems) {
      buffer.writeln(
        '${item.productName} x ${item.quantity} - ₹${item.subtotal.toStringAsFixed(0)}',
      );
    }

    buffer
      ..writeln('─────────────────')
      ..writeln('Subtotal: ₹${subtotal.toStringAsFixed(0)}');

    if (discountAmount > 0) {
      buffer.writeln('Discount: -₹${discountAmount.toStringAsFixed(0)}');
    }

    if (deliveryCharge > 0) {
      buffer.writeln('Delivery: ₹${deliveryCharge.toStringAsFixed(0)}');
    }

    buffer
      ..writeln('Total: ₹${total.toStringAsFixed(0)}')
      ..writeln('')
      ..writeln('Payment: ${paymentModeLabel(paymentMode)}');

    if (paymentMode == PaymentMode.upi && (upiId ?? '').trim().isNotEmpty) {
      buffer.writeln('UPI ID: ${upiId!.trim()}');
    }

    if ((deliveryNote ?? '').trim().isNotEmpty) {
      buffer.writeln('Note: ${deliveryNote!.trim()}');
    }

    return buffer.toString().trimRight();
  }

  /// Converts persisted string value to enum.
  static PaymentMode paymentModeFromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'upi':
        return PaymentMode.upi;
      case 'cash':
        return PaymentMode.cash;
      case 'cod':
        return PaymentMode.cod;
      case 'pending':
      default:
        return PaymentMode.pending;
    }
  }

  /// Converts enum value to Firestore string.
  static String paymentModeToString(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.upi:
        return 'upi';
      case PaymentMode.cash:
        return 'cash';
      case PaymentMode.cod:
        return 'cod';
      case PaymentMode.pending:
        return 'pending';
    }
  }

  /// User-facing Hinglish label for payment mode.
  static String paymentModeLabel(PaymentMode mode) {
    switch (mode) {
      case PaymentMode.upi:
        return AppStrings.paymentModeUpi;
      case PaymentMode.cash:
        return AppStrings.paymentModeCash;
      case PaymentMode.cod:
        return AppStrings.paymentModeCod;
      case PaymentMode.pending:
        return AppStrings.paymentModePending;
    }
  }
}

List<OrderLineItem> _readLineItems(Object? raw) {
  if (raw is! List<Object?>) {
    return const <OrderLineItem>[];
  }

  final List<OrderLineItem> items = <OrderLineItem>[];
  for (final Object? value in raw) {
    if (value is Map<String, dynamic>) {
      items.add(OrderLineItem.fromMap(value));
      continue;
    }
    if (value is Map<Object?, Object?>) {
      final Map<String, dynamic> mapped = value.map<String, dynamic>(
        (Object? key, Object? val) => MapEntry(key.toString(), val),
      );
      items.add(OrderLineItem.fromMap(mapped));
    }
  }
  return items;
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

DateTime _readDateTime(Object? raw) {
  if (raw is DateTime) {
    return raw;
  }
  if (raw is Timestamp) {
    return raw.toDate();
  }
  if (raw is String) {
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
  try {
    final dynamic maybeDate = (raw as dynamic)?.toDate();
    if (maybeDate is DateTime) {
      return maybeDate;
    }
  } catch (_) {
    // Ignore and fallback.
  }
  return DateTime.now();
}

DateTime? _readNullableDateTime(Object? raw) {
  if (raw == null) {
    return null;
  }
  if (raw is DateTime) {
    return raw;
  }
  if (raw is Timestamp) {
    return raw.toDate();
  }
  if (raw is String) {
    return DateTime.tryParse(raw);
  }
  try {
    final dynamic maybeDate = (raw as dynamic)?.toDate();
    if (maybeDate is DateTime) {
      return maybeDate;
    }
  } catch (_) {
    // Ignore and fallback.
  }
  return null;
}

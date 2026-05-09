import 'package:dukaan_ai/features/order_slip/domain/order_line_item.dart';
import 'package:dukaan_ai/features/order_slip/domain/order_slip.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order_slip_state.freezed.dart';

@freezed
abstract class OrderSlipState with _$OrderSlipState {
  const factory OrderSlipState({
    @Default(<OrderSlip>[]) List<OrderSlip> slips,
    @Default(false) bool isGeneratingImage,
    @Default(<OrderLineItem>[]) List<OrderLineItem> draftLineItems,
    @Default('') String draftCustomerName,
    String? draftCustomerPhone,
    @Default(0) double draftDiscount,
    @Default(0) double draftDeliveryCharge,
    @Default(PaymentMode.pending) PaymentMode draftPaymentMode,
    String? draftDeliveryNote,
    @Default(false) bool draftGstEnabled,
    String? prefillInquiryId,
    String? draftUpiId,
    String? errorMessage,
    OrderSlip? latestCreatedSlip,
    String? stockNudgeProductId,
    String? stockNudgeProductName,
  }) = _OrderSlipState;
}

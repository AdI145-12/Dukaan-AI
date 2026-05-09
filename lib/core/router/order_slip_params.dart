class OrderSlipParams {
  const OrderSlipParams({
    required this.inquiryId,
    required this.customerName,
    this.customerPhone,
    this.linkedProductId,
    this.linkedProductName,
  });

  final String inquiryId;
  final String customerName;
  final String? customerPhone;
  final String? linkedProductId;
  final String? linkedProductName;
}

enum InquiryStatus {
  newInquiry,
  interested,
  paymentPending,
  ordered,
  delivered,
  followUpNeeded;

  /// Firestore-safe string value.
  String get value => switch (this) {
        InquiryStatus.newInquiry => 'new',
        InquiryStatus.interested => 'interested',
        InquiryStatus.paymentPending => 'paymentPending',
        InquiryStatus.ordered => 'ordered',
        InquiryStatus.delivered => 'delivered',
        InquiryStatus.followUpNeeded => 'followUpNeeded',
      };

  static InquiryStatus fromValue(String value) => switch (value) {
        'new' => InquiryStatus.newInquiry,
        'interested' => InquiryStatus.interested,
        'paymentPending' => InquiryStatus.paymentPending,
        'ordered' => InquiryStatus.ordered,
        'delivered' => InquiryStatus.delivered,
        'followUpNeeded' => InquiryStatus.followUpNeeded,
        _ => InquiryStatus.newInquiry,
      };

  /// Display label (Hinglish).
  String get label => switch (this) {
        InquiryStatus.newInquiry => 'Naya',
        InquiryStatus.interested => 'Interested',
        InquiryStatus.paymentPending => 'Payment Pending',
        InquiryStatus.ordered => 'Order Ho Gaya',
        InquiryStatus.delivered => 'Deliver Ho Gaya',
        InquiryStatus.followUpNeeded => 'Follow-Up Karo',
      };

  /// Pipeline order for status progression.
  int get pipelineIndex => switch (this) {
        InquiryStatus.newInquiry => 0,
        InquiryStatus.interested => 1,
        InquiryStatus.paymentPending => 2,
        InquiryStatus.ordered => 3,
        InquiryStatus.delivered => 4,
        InquiryStatus.followUpNeeded => 5,
      };

  InquiryStatus? get next => switch (this) {
        InquiryStatus.newInquiry => InquiryStatus.interested,
        InquiryStatus.interested => InquiryStatus.paymentPending,
        InquiryStatus.paymentPending => InquiryStatus.ordered,
        InquiryStatus.ordered => InquiryStatus.delivered,
        InquiryStatus.delivered => null,
        InquiryStatus.followUpNeeded => InquiryStatus.interested,
      };
}

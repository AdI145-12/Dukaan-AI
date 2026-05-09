enum InquirySource {
  whatsapp,
  instagram,
  offline,
  other;

  String get value => name;

  String get label => switch (this) {
        InquirySource.whatsapp => 'WhatsApp',
        InquirySource.instagram => 'Instagram',
        InquirySource.offline => 'Seedha / Offline',
        InquirySource.other => 'Aur Kahin',
      };

  static InquirySource fromValue(String value) {
    return InquirySource.values.firstWhere(
      (InquirySource source) => source.value == value,
      orElse: () => InquirySource.other,
    );
  }
}

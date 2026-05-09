class GeneratedCaption {
  const GeneratedCaption({
    required this.caption,
    required this.hashtags,
    required this.language,
  });

  final String caption;
  final List<String> hashtags;
  final String language;

  /// Full caption text with hashtags for sharing/copying.
  String get fullText => '$caption\n\n${hashtags.map((String h) => '#$h').join(' ')}';
}
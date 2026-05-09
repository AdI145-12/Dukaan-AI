class DailyContentPlan {
  const DailyContentPlan({
    required this.title,
    required this.reason,
    required this.captionIdea,
    required this.callToAction,
    required this.date,
    this.suggestedProductName,
    this.suggestedProductImageUrl,
    this.festivalTag,
    this.cached = false,
    this.fallback = false,
  });

  final String title;
  final String reason;
  final String captionIdea;
  final String callToAction;
  final DateTime date;
  final String? suggestedProductName;
  final String? suggestedProductImageUrl;
  final String? festivalTag;
  final bool cached;
  final bool fallback;

  /// Builds [DailyContentPlan] from worker response payload.
  factory DailyContentPlan.fromMap(Map<String, dynamic> data) {
    final String dateRaw = data['date'] as String? ?? '';

    return DailyContentPlan(
      title: (data['title'] as String? ?? '').trim(),
      reason: (data['reason'] as String? ?? '').trim(),
      captionIdea: (data['captionIdea'] as String? ?? '').trim(),
      callToAction: (data['callToAction'] as String? ?? '').trim(),
      date: DateTime.tryParse(dateRaw) ?? DateTime.now(),
      suggestedProductName: _readOptionalString(data['suggestedProductName']),
      suggestedProductImageUrl: _readOptionalString(data['suggestedProductImageUrl']),
      festivalTag: _readOptionalString(data['festivalTag']),
      cached: data['cached'] as bool? ?? false,
      fallback: data['fallback'] as bool? ?? false,
    );
  }
}

String? _readOptionalString(Object? raw) {
  if (raw is! String) {
    return null;
  }

  final String value = raw.trim();
  if (value.isEmpty) {
    return null;
  }

  return value;
}

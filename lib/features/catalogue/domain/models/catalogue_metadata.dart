class CatalogueMetadata {
  const CatalogueMetadata({
    required this.description,
    required this.tags,
    required this.suggestedCaptions,
  });

  final String description;
  final List<String> tags;
  final List<String> suggestedCaptions;

  /// Creates metadata model from Worker response payload.
  factory CatalogueMetadata.fromMap(Map<String, dynamic> data) {
    final List<String> tags = _toStringList(data['tags']);
    final List<String> captions = _toStringList(data['suggestedCaptions']);
    final String caption = (data['caption'] as String?)?.trim() ?? '';

    final List<String> mergedCaptions = <String>[
      if (caption.isNotEmpty) caption,
      ...captions,
    ];

    final List<String> dedupedCaptions = <String>[];
    for (final String value in mergedCaptions) {
      if (dedupedCaptions.contains(value)) {
        continue;
      }
      dedupedCaptions.add(value);
    }

    return CatalogueMetadata(
      description: (data['description'] as String?)?.trim() ?? '',
      tags: tags,
      suggestedCaptions: dedupedCaptions,
    );
  }
}

List<String> _toStringList(Object? raw) {
  if (raw is! List<Object?>) {
    return const <String>[];
  }

  final List<String> values = <String>[];
  for (final Object? item in raw) {
    final String value = item?.toString().trim() ?? '';
    if (value.isEmpty || values.contains(value)) {
      continue;
    }
    values.add(value);
  }
  return values;
}

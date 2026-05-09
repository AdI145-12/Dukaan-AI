import 'package:flutter/material.dart';

class BackgroundStyle {
  const BackgroundStyle({
    required this.id,
    required this.displayName,
    required this.previewColor,
  });

  final String id;
  final String displayName;
  final Color previewColor;

  static const List<BackgroundStyle> all = <BackgroundStyle>[
    BackgroundStyle(
      id: 'white',
      displayName: 'Safed',
      previewColor: Color(0xFFFFFFFF),
    ),
    BackgroundStyle(
      id: 'gradient_orange',
      displayName: 'Narangi',
      previewColor: Color(0xFFFF6F00),
    ),
    BackgroundStyle(
      id: 'diwali',
      displayName: 'Diwali',
      previewColor: Color(0xFFFFB300),
    ),
    BackgroundStyle(
      id: 'holi',
      displayName: 'Holi',
      previewColor: Color(0xFF9C27B0),
    ),
    BackgroundStyle(
      id: 'independence_day',
      displayName: 'Tiranga',
      previewColor: Color(0xFF1565C0),
    ),
    BackgroundStyle(
      id: 'wooden',
      displayName: 'Lakdi',
      previewColor: Color(0xFF795548),
    ),
    BackgroundStyle(
      id: 'bokeh',
      displayName: 'Soft Blur',
      previewColor: Color(0xFF90CAF9),
    ),
    BackgroundStyle(
      id: 'studio',
      displayName: 'Studio',
      previewColor: Color(0xFF37474F),
    ),
    BackgroundStyle(
      id: 'bazaar',
      displayName: 'Bazaar',
      previewColor: Color(0xFF388E3C),
    ),
    BackgroundStyle(
      id: 'festive_red',
      displayName: 'Laal Utsav',
      previewColor: Color(0xFFC62828),
    ),
  ];
}

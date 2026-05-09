import 'package:flutter/material.dart';

class AppShadows {
  const AppShadows._();

  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> modal = <BoxShadow>[
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> banner = <BoxShadow>[
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> elevated = <BoxShadow>[
    BoxShadow(
      color: Color(0x26000000),
      blurRadius: 16,
      offset: Offset(0, -2),
    ),
  ];
}

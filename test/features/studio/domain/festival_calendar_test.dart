import 'package:dukaan_ai/shared/utils/festival_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('getTodayFestival returns null for a date with no festival', () {
    final String? festival =
        FestivalCalendar.getTodayFestival(testDate: DateTime(2026, 2, 1));

    expect(festival, isNull);
  });

  test("for date '2026-11-17' the result contains 'Diwali'", () {
    final String? festival =
        FestivalCalendar.getTodayFestival(testDate: DateTime(2026, 11, 17));

    expect(festival, isNotNull);
    expect(festival, contains('Diwali'));
  });

  test('all returned strings include an emoji character', () {
    final List<DateTime> dates = <DateTime>[
      DateTime(2026, 3, 29),
      DateTime(2026, 4, 6),
      DateTime(2026, 4, 14),
      DateTime(2026, 6, 19),
      DateTime(2026, 8, 9),
      DateTime(2026, 8, 20),
      DateTime(2026, 10, 2),
      DateTime(2026, 10, 20),
      DateTime(2026, 10, 29),
      DateTime(2026, 11, 15),
      DateTime(2026, 11, 17),
      DateTime(2026, 11, 19),
      DateTime(2026, 12, 25),
      DateTime(2027, 1, 1),
    ];

    final RegExp emojiPattern = RegExp(r'[^\x00-\x7F]');

    for (final DateTime date in dates) {
      final String? festival = FestivalCalendar.getTodayFestival(testDate: date);
      expect(festival, isNotNull);
      expect(emojiPattern.hasMatch(festival!), isTrue);
    }
  });
}

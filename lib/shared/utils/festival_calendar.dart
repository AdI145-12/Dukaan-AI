class FestivalCalendar {
  FestivalCalendar._();

  static const Map<String, String> _festivals = <String, String>{
    '2026-03-29': 'Holi 🎨',
    '2026-04-06': 'Ram Navami 🙏',
    '2026-04-14': 'Baisakhi 🌾',
    '2026-06-19': 'Eid ul-Adha 🌙',
    '2026-08-09': 'Raksha Bandhan 🪢',
    '2026-08-20': 'Janmashtami 🪈',
    '2026-10-02': 'Gandhi Jayanti 🇮🇳',
    '2026-10-20': 'Navratri 🔱',
    '2026-10-29': 'Dussehra 🏹',
    '2026-11-15': 'Dhanteras 💰',
    '2026-11-17': 'Diwali 🪔',
    '2026-11-19': 'Bhai Dooj 💝',
    '2026-12-25': 'Christmas 🎄',
    '2027-01-01': 'New Year 🎆',
  };

  /// Returns today's festival name+emoji, or null if no festival today.
  static String? getTodayFestival({DateTime? testDate}) {
    final DateTime today = testDate ?? DateTime.now();
    final String key =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return _festivals[key];
  }
}

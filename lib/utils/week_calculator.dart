class WeekCalculator {
  static DateTime getBaseDate() {
    return DateTime(2024, 9);
  }

  static int getCurrentWeekNumber() {
    final baseDate = getBaseDate();
    final now = DateTime.now();
    final difference = now.difference(baseDate).inDays;
    return (difference ~/ 7) + 1;
  }

  static String calculateWeekType({bool isReversed = false}) {
    final weekNumber = getCurrentWeekNumber();

    String weekType;
    if (isReversed) {
      weekType = weekNumber.isEven ? 'chys' : 'znam';
    } else {
      weekType = weekNumber.isEven ? 'znam' : 'chys';
    }

    return weekType;
  }

  static bool hasWeekChanged(String savedWeekType, bool isReversed) {
    return savedWeekType != calculateWeekType(isReversed: isReversed);
  }
}

class ApiConstants {
  static const String baseUrl = 'https://student.lpnu.ua';
  static const String scheduleEndpoint = '/students_schedule';

  static String getScheduleUrl(String group) {
    return '''
$baseUrl$scheduleEndpoint?studygroup_abbrname=${Uri.encodeComponent(group)}&semestr=1&semestrduration=1''';
  }
}

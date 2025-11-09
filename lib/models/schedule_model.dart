class Schedule {
  final String time;
  final String subject;
  final String teacher;
  final String classroom;
  final String type;
  final String day;
  final String
  weekType; // 'chys' (чисельник), 'znam' (знаменник), 'full' (кожен тиждень)
  final String
  subgroup; // '0' - основна група, '1' - перша підгрупа, '2' - друга підгрупа

  const Schedule({
    required this.time,
    required this.subject,
    required this.teacher,
    required this.classroom,
    required this.type,
    required this.day,
    required this.weekType,
    this.subgroup = '0', // За замовчуванням основна група
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'subject': subject,
      'teacher': teacher,
      'classroom': classroom,
      'type': type,
      'day': day,
      'weekType': weekType,
      'subgroup': subgroup,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      time: json['time']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      classroom: json['classroom']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      day: json['day']?.toString() ?? '',
      weekType: json['weekType']?.toString() ?? 'full',
      subgroup: json['subgroup']?.toString() ?? '0',
    );
  }

  Schedule copyWith({
    String? time,
    String? subject,
    String? teacher,
    String? classroom,
    String? type,
    String? day,
    String? weekType,
    String? subgroup,
  }) {
    return Schedule(
      time: time ?? this.time,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      classroom: classroom ?? this.classroom,
      type: type ?? this.type,
      day: day ?? this.day,
      weekType: weekType ?? this.weekType,
      subgroup: subgroup ?? this.subgroup,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Schedule &&
        other.time == time &&
        other.subject == subject &&
        other.teacher == teacher &&
        other.classroom == classroom &&
        other.type == type &&
        other.day == day &&
        other.weekType == weekType &&
        other.subgroup == subgroup;
  }

  @override
  int get hashCode {
    return Object.hash(
      time,
      subject,
      teacher,
      classroom,
      type,
      day,
      weekType,
      subgroup,
    );
  }
}

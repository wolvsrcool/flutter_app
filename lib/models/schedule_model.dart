class Schedule {
  final String time;
  final String subject;
  final String teacher;
  final String classroom;
  final String type;

  const Schedule({
    required this.time,
    required this.subject,
    required this.teacher,
    required this.classroom,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'subject': subject,
      'teacher': teacher,
      'classroom': classroom,
      'type': type,
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      time: json['time']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      teacher: json['teacher']?.toString() ?? '',
      classroom: json['classroom']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }

  Schedule copyWith({
    String? time,
    String? subject,
    String? teacher,
    String? classroom,
    String? type,
  }) {
    return Schedule(
      time: time ?? this.time,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
      classroom: classroom ?? this.classroom,
      type: type ?? this.type,
    );
  }
}

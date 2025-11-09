class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String group;
  final String password;
  final String subgroup; // '1' або '2'
  final String weekType; // 'chys' або 'znam'

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.group,
    required this.password,
    this.subgroup = '1',
    this.weekType = 'chys',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'group': group,
      'password': password,
      'subgroup': subgroup,
      'weekType': weekType,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      subgroup: json['subgroup']?.toString() ?? '1',
      weekType: json['weekType']?.toString() ?? 'chys',
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? group,
    String? password,
    String? subgroup,
    String? weekType,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      group: group ?? this.group,
      password: password ?? this.password,
      subgroup: subgroup ?? this.subgroup,
      weekType: weekType ?? this.weekType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.group == group &&
        other.password == password &&
        other.subgroup == subgroup &&
        other.weekType == weekType;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      fullName,
      group,
      password,
      subgroup,
      weekType,
    );
  }
}

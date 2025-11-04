class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String group;
  final String password;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.group,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'group': group,
      'password': password,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      group: json['group']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? group,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      group: group ?? this.group,
      password: password ?? this.password,
    );
  }
}

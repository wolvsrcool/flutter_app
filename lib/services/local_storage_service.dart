import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/models/schedule_model.dart';
import 'package:my_project/models/user_model.dart';

abstract class LocalStorageService {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getCurrentUser();
  Future<void> deleteCurrentUser();
  Future<void> saveSchedules(List<Schedule> schedules);
  Future<List<Schedule>> getSchedules();
  Future<bool> checkUserExists(String email);
  Future<void> registerUser(UserModel user);
  Future<UserModel?> findUserByEmail(String email);
  Future<void> updateRegisteredUser(UserModel user);
}

class HiveStorageService implements LocalStorageService {
  final Box<dynamic> userBox;
  final Box<dynamic> scheduleBox;

  HiveStorageService({required this.userBox, required this.scheduleBox});

  @override
  Future<void> saveUser(UserModel user) async {
    await userBox.put('current_user', user.toJson());
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final userData = userBox.get('current_user');
      if (userData == null) return null;
      final Map<dynamic, dynamic> userMap = userData as Map<dynamic, dynamic>;
      return UserModel(
        id: userMap['id']?.toString() ?? '',
        email: userMap['email']?.toString() ?? '',
        fullName: userMap['fullName']?.toString() ?? '',
        group: userMap['group']?.toString() ?? '',
        password: userMap['password']?.toString() ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteCurrentUser() async {
    await userBox.delete('current_user');
  }

  Future<Map<dynamic, dynamic>> _getAllUsers() async {
    final dynamic usersData = userBox.get('registered_users');
    if (usersData != null && usersData is Map) {
      return Map<dynamic, dynamic>.from(usersData);
    }
    return <dynamic, dynamic>{};
  }

  @override
  Future<void> updateRegisteredUser(UserModel user) async {
    final Map<dynamic, dynamic> users = await _getAllUsers();
    users[user.email] = user.toJson();
    await userBox.put('registered_users', users);
  }

  @override
  Future<void> registerUser(UserModel user) async {
    final Map<dynamic, dynamic> users = await _getAllUsers();
    users[user.email] = user.toJson();
    await userBox.put('registered_users', users);
  }

  @override
  Future<UserModel?> findUserByEmail(String email) async {
    final Map<dynamic, dynamic> users = await _getAllUsers();
    final dynamic userData = users[email];
    if (userData != null && userData is Map) {
      try {
        final Map<dynamic, dynamic> userMap = Map<dynamic, dynamic>.from(
          userData,
        );
        return UserModel(
          id: userMap['id']?.toString() ?? '',
          email: userMap['email']?.toString() ?? '',
          fullName: userMap['fullName']?.toString() ?? '',
          group: userMap['group']?.toString() ?? '',
          password: userMap['password']?.toString() ?? '',
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<bool> checkUserExists(String email) async {
    final user = await findUserByEmail(email);
    return user != null;
  }

  @override
  Future<void> saveSchedules(List<Schedule> schedules) async {
    final schedulesJson = schedules
        .map((schedule) => schedule.toJson())
        .toList();
    await scheduleBox.put('schedules', schedulesJson);
  }

  @override
  Future<List<Schedule>> getSchedules() async {
    try {
      final schedulesData = scheduleBox.get('schedules');
      if (schedulesData == null) return [];
      final List<dynamic> schedulesList = schedulesData as List<dynamic>;
      return schedulesList.map((item) {
        final Map<dynamic, dynamic> scheduleMap = item as Map<dynamic, dynamic>;
        return Schedule(
          time: scheduleMap['time']?.toString() ?? '',
          subject: scheduleMap['subject']?.toString() ?? '',
          teacher: scheduleMap['teacher']?.toString() ?? '',
          classroom: scheduleMap['classroom']?.toString() ?? '',
          type: scheduleMap['type']?.toString() ?? '',
          day: scheduleMap['day']?.toString() ?? '',
          weekType: scheduleMap['weekType']?.toString() ?? 'full',
          subgroup: scheduleMap['subgroup']?.toString() ?? '0',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}

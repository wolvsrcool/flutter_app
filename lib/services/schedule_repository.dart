import 'package:my_project/models/schedule_model.dart';
import 'package:my_project/services/api_service.dart';
import 'package:my_project/services/local_storage_service.dart';

class ScheduleRepository {
  final ApiService apiService;
  final LocalStorageService localStorageService;

  ScheduleRepository({
    required this.apiService,
    required this.localStorageService,
  });

  Future<List<Schedule>> getSchedule(String group) async {
    try {
      final onlineSchedules = await apiService.fetchSchedule(group);
      await localStorageService.saveSchedules(onlineSchedules);
      return onlineSchedules;
    } catch (e) {
      final offlineSchedules = await localStorageService.getSchedules();
      if (offlineSchedules.isNotEmpty) {
        return offlineSchedules;
      }
      rethrow;
    }
  }

  Future<List<Schedule>> getOfflineSchedule() async {
    return await localStorageService.getSchedules();
  }
}

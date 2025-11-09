import 'package:http/http.dart' as http;
import 'package:my_project/models/schedule_model.dart';
import 'package:my_project/utils/api_constants.dart';
import 'package:my_project/utils/parse_utils.dart';

abstract class ApiService {
  Future<List<Schedule>> fetchSchedule(String group);
}

class LpnuApiService implements ApiService {
  final http.Client client;

  LpnuApiService({required this.client});

  @override
  Future<List<Schedule>> fetchSchedule(String group) async {
    try {
      final originalUrl = ApiConstants.getScheduleUrl(group);

      final url = Uri.parse(
        'https://corsproxy.io/?${Uri.encodeComponent(originalUrl)}',
      );

      final response = await client
          .get(
            url,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
              'Accept':
                  'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final schedules = ParseUtils.parseSchedule(response.body, group);
        return schedules;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}

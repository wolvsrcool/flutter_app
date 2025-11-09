import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:my_project/models/user_model.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/services/api_service.dart';
import 'package:my_project/services/local_storage_service.dart';
import 'package:my_project/services/schedule_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox<dynamic>('userBox');
  await Hive.openBox<dynamic>('scheduleBox');

  runApp(const UniversityScheduleApp());
}

class UniversityScheduleApp extends StatelessWidget {
  const UniversityScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'University Schedule',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final LocalStorageService _storageService = HiveStorageService(
    userBox: Hive.box('userBox'),
    scheduleBox: Hive.box('scheduleBox'),
  );

  late final ScheduleRepository _scheduleRepository;

  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  void _initializeServices() {
    final apiService = LpnuApiService(client: http.Client());
    _scheduleRepository = ScheduleRepository(
      apiService: apiService,
      localStorageService: _storageService,
    );
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    try {
      final user = await _storageService.getCurrentUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return _currentUser != null
        ? HomeScreen(
            currentUser: _currentUser!,
            scheduleRepository: _scheduleRepository,
          )
        : LoginScreen(scheduleRepository: _scheduleRepository);
  }
}

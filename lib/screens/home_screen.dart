import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/models/schedule_model.dart';
import 'package:my_project/models/user_model.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/services/schedule_repository.dart';
import 'package:my_project/utils/week_calculator.dart';
import 'package:my_project/widgets/navigation_bar.dart';
import 'package:my_project/widgets/schedule_card.dart';

class HomeScreen extends StatefulWidget {
  final UserModel currentUser;
  final ScheduleRepository scheduleRepository;

  const HomeScreen({
    required this.currentUser,
    required this.scheduleRepository,
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _selectedDayIndex = 0;
  late Future<List<Schedule>> _scheduleFuture;

  late UserModel _currentUser;
  bool _isWeekReversed = false;

  final List<String> _daysOfWeek = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser;
    _scheduleFuture = widget.scheduleRepository.getSchedule(_currentUser.group);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.blue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    _loadWeekSettings();

    _checkAndUpdateWeek();
  }

  void _loadWeekSettings() async {
    final userBox = Hive.box<dynamic>('userBox');
    final isReversed =
        userBox.get('isWeekReversed', defaultValue: false) as bool;
    setState(() {
      _isWeekReversed = isReversed;
    });
  }

  @override
  void dispose() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  void _checkAndUpdateWeek() async {
    try {
      final hasChanged = WeekCalculator.hasWeekChanged(
        _currentUser.weekType,
        _isWeekReversed,
      );

      if (hasChanged) {
        final newWeekType = WeekCalculator.calculateWeekType(
          isReversed: _isWeekReversed,
        );
        final updatedUser = _currentUser.copyWith(weekType: newWeekType);

        final userBox = Hive.box<dynamic>('userBox');
        await userBox.put('currentUser', updatedUser);

        setState(() {
          _currentUser = updatedUser;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('''
Тиждень оновлено: ${newWeekType == 'chys' ? 'Чисельник' : 'Знаменник'}'''),
              backgroundColor: Colors.blue,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      return;
    }
  }

  void _refreshSchedule() {
    setState(() {
      _scheduleFuture = widget.scheduleRepository.getSchedule(
        _currentUser.group,
      );
    });
    _checkAndUpdateWeek();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 290),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Вихід',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ви впевнені, що хочете вийти?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IntrinsicWidth(
                      child: SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: Colors.grey),
                          ),
                          child: const Text(
                            'Скасувати',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    IntrinsicWidth(
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _logout();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Вийти',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout() async {
    try {
      final userBox = Hive.box<dynamic>('userBox');

      await userBox.delete('currentUser');

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (context) =>
                LoginScreen(scheduleRepository: widget.scheduleRepository),
          ),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Помилка при виході: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleProfileUpdated(UserModel updatedUser, bool isWeekReversed) {
    setState(() {
      _currentUser = updatedUser;
      _isWeekReversed = isWeekReversed;
    });

    _refreshSchedule();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Розклад | НУЛП',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Група: ${_currentUser.group}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Підгрупа: ${_currentUser.subgroup}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.blue,
        elevation: 2,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshSchedule,
              tooltip: 'Оновити розклад',
            ),
          if (_currentIndex == 1)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SizedBox(
                height: 36,
                child: ElevatedButton(
                  onPressed: () => _showLogoutDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text(
                    'Вийти',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _currentIndex == 0
          ? _buildHomeContent()
          : ProfileScreen(
              currentUser: _currentUser,
              isWeekReversed: _isWeekReversed,
              onProfileUpdated: _handleProfileUpdated,
            ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: List.generate(_daysOfWeek.length, (index) {
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _selectedDayIndex == index
                          ? Colors.blue
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _daysOfWeek[index],
                          style: TextStyle(
                            color: _selectedDayIndex == index
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getDateForDay(index),
                          style: TextStyle(
                            color: _selectedDayIndex == index
                                ? Colors.white
                                : Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                _getFullDayName(_selectedDayIndex),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getFullDateForDay(_selectedDayIndex),
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _currentUser.weekType == 'chys'
                      ? Colors.blue[100]
                      : Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _currentUser.weekType == 'chys' ? 'Чисельник' : 'Знаменник',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _currentUser.weekType == 'chys'
                        ? Colors.blue[800]
                        : Colors.orange[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FutureBuilder<List<Schedule>>(
              future: _scheduleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return _buildErrorWidget(
                    snapshot.error.toString(),
                    'Можливо, неправильно вказано групу: ${_currentUser.group}',
                  );
                } else if (snapshot.hasData) {
                  final schedules = snapshot.data!;
                  if (schedules.isEmpty) {
                    return _buildNoDataWidget();
                  }
                  return _buildScheduleList(schedules);
                } else {
                  return _buildNoDataWidget();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleList(List<Schedule> schedules) {
    final daySchedules = _filterSchedulesByDayAndSubgroup(
      schedules,
      _selectedDayIndex,
      _currentUser.subgroup,
      _currentUser.weekType,
    );

    if (daySchedules.isEmpty) {
      return const Center(
        child: Text(
          'Пар немає 🎉',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: daySchedules.length,
      itemBuilder: (context, index) {
        return ScheduleCard(schedule: daySchedules[index]);
      },
    );
  }

  Widget _buildNoDataWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.schedule, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Не вдалося завантажити розклад',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          'Група: ${_currentUser.group}',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        const Text(
          'Можливо, неправильно вказано групу або відсутній інтернет',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: 200,
          height: 44,
          child: ElevatedButton(
            onPressed: _refreshSchedule,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Спробувати знову',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String error, String additionalInfo) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Помилка завантаження розкладу',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  additionalInfo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Помилка: $error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            height: 44,
            child: ElevatedButton(
              onPressed: _refreshSchedule,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Спробувати знову',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 200,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Змінити групу',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Schedule> _filterSchedulesByDayAndSubgroup(
    List<Schedule> schedules,
    int dayIndex,
    String subgroup,
    String weekType,
  ) {
    final dayNames = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];
    final currentDayName = dayNames[dayIndex];

    return schedules.where((schedule) {
      if (schedule.day != currentDayName) return false;

      if (schedule.subgroup != '0' && schedule.subgroup != subgroup) {
        return false;
      }

      return schedule.weekType == 'full' || schedule.weekType == weekType;
    }).toList();
  }

  String _getDateForDay(int dayIndex) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final daysToAdd = dayIndex + 1 - currentWeekday;
    final targetDate = now.add(Duration(days: daysToAdd));
    return '${targetDate.day}.${targetDate.month}';
  }

  String _getFullDateForDay(int dayIndex) {
    final now = DateTime.now();
    final currentWeekday = now.weekday;
    final daysToAdd = dayIndex + 1 - currentWeekday;
    final targetDate = now.add(Duration(days: daysToAdd));
    return '${targetDate.day}.${targetDate.month}.${targetDate.year}';
  }

  String _getFullDayName(int dayIndex) {
    final fullDays = ['Понеділок', 'Вівторок', 'Середа', 'Четвер', 'П\'ятниця'];
    return fullDays[dayIndex];
  }
}

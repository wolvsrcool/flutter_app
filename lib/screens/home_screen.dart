import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/models/schedule_model.dart';
import 'package:my_project/models/user_model.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/widgets/navigation_bar.dart';
import 'package:my_project/widgets/schedule_card.dart';

class HomeScreen extends StatefulWidget {
  final UserModel currentUser;

  const HomeScreen({required this.currentUser, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _selectedDayIndex = 0;

  final List<String> _daysOfWeek = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];

  final Map<int, List<Schedule>> _weeklySchedules = {
    0: [
      const Schedule(
        time: '08:30 - 10:05',
        subject: 'Математичний аналіз',
        teacher: 'Проф. Іваненко І.І.',
        classroom: '101',
        type: 'Лекція',
      ),
      const Schedule(
        time: '10:25 - 12:00',
        subject: 'Програмування',
        teacher: 'Доц. Петренко П.П.',
        classroom: '203',
        type: 'Практична',
      ),
    ],
    1: [
      const Schedule(
        time: '09:00 - 10:35',
        subject: 'Фізика',
        teacher: 'Проф. Сидоренко С.С.',
        classroom: '305',
        type: 'Лекція',
      ),
      const Schedule(
        time: '12:20 - 13:55',
        subject: 'Іноземна мова',
        teacher: 'Доц. Ковальчук К.К.',
        classroom: '415',
        type: 'Практична',
      ),
    ],
    2: [
      const Schedule(
        time: '08:30 - 10:05',
        subject: 'Програмування',
        teacher: 'Доц. Петренко П.П.',
        classroom: '203',
        type: 'Лабораторна',
      ),
      const Schedule(
        time: '14:15 - 15:50',
        subject: 'Математичний аналіз',
        teacher: 'Проф. Іваненко І.І.',
        classroom: '102',
        type: 'Практична',
      ),
    ],
    3: [
      const Schedule(
        time: '10:25 - 12:00',
        subject: 'Фізика',
        teacher: 'Проф. Сидоренко С.С.',
        classroom: '306',
        type: 'Лабораторна',
      ),
    ],
    4: [
      const Schedule(
        time: '09:00 - 10:35',
        subject: 'Іноземна мова',
        teacher: 'Доц. Ковальчук К.К.',
        classroom: '416',
        type: 'Практична',
      ),
      const Schedule(
        time: '12:20 - 13:55',
        subject: 'Фізкультура',
        teacher: 'Вик. Мельник М.М.',
        classroom: 'Спортзал',
        type: 'Практична',
      ),
    ],
  };

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
                            _logout(context);
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

  void _logout(BuildContext context) {
    Hive.box<dynamic>('userBox').delete('current_user');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Розклад | НУЛП'),
            Text(
              'Група: ${widget.currentUser.group}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
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
              currentUser: widget.currentUser,
              onProfileUpdated: () => setState(() {}),
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
    final daySchedules = _weeklySchedules[_selectedDayIndex] ?? [];

    return Column(
      children: [
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
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
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDaySchedule(daySchedules),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySchedule(List<Schedule> daySchedules) {
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

import 'package:flutter/material.dart';
import 'package:my_project/models/schedule_model.dart';
import 'package:my_project/screens/profile_screen.dart';
import 'package:my_project/widgets/navigation_bar.dart';
import 'package:my_project/widgets/schedule_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _selectedDayIndex = 0;

  final List<String> _daysOfWeek = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];

  final Map<int, List<Schedule>> _weeklySchedules = {
    0: [
      // Понеділок
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
      // Вівторок
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
      // Середа
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
      // Четвер
      const Schedule(
        time: '10:25 - 12:00',
        subject: 'Фізика',
        teacher: 'Проф. Сидоренко С.С.',
        classroom: '306',
        type: 'Лабораторна',
      ),
    ],
    4: [
      // П'ятниця
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Розклад | НУЛП'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: () {}),
        ],
      ),
      body: _currentIndex == 0 ? _buildHomeContent() : const ProfileScreen(),
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
        // Flex Tab Bar for days of week
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
        // Selected day title
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
        // Schedule list for selected day
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildDaySchedule(_selectedDayIndex),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySchedule(int dayIndex) {
    final daySchedules = _weeklySchedules[dayIndex] ?? [];

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

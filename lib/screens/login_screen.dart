import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/screens/register_screen.dart';
import 'package:my_project/services/local_storage_service.dart';
import 'package:my_project/services/schedule_repository.dart';
import 'package:my_project/utils/validators.dart';
import 'package:my_project/widgets/custom_button.dart';
import 'package:my_project/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  final ScheduleRepository scheduleRepository;

  const LoginScreen({required this.scheduleRepository, super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final LocalStorageService _storageService;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storageService = HiveStorageService(
      userBox: Hive.box('userBox'),
      scheduleBox: Hive.box('scheduleBox'),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final userBox = Hive.box<dynamic>('userBox');
        if (!userBox.isOpen) {
          await Hive.openBox<dynamic>('userBox');
        }

        final email = _emailController.text.trim();
        final password = _passwordController.text;

        final user = await _storageService.findUserByEmail(email);

        if (user == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Користувача з таким email не знайдено'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (user.password == password) {
          await _storageService.saveUser(user);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute<void>(
                builder: (context) => HomeScreen(
                  currentUser: user,
                  scheduleRepository: widget.scheduleRepository,
                ),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Невірний пароль'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Помилка входу: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.8;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Розклад',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Національний університет "Львівська Політехніка"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 48),
                  SizedBox(
                    width: contentWidth,
                    child: Column(
                      children: [
                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Електронна пошта',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.validateEmail,
                          width: contentWidth,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          hintText: 'Пароль',
                          prefixIcon: Icons.lock,
                          obscureText: true,
                          validator: Validators.validatePassword,
                          width: contentWidth,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: _isLoading ? 'Вхід...' : 'Увійти',
                          onPressed: _isLoading ? () {} : _login,
                          width: contentWidth,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: contentWidth,
                          child: TextButton(
                            onPressed: _isLoading
                                ? () {}
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (context) => RegisterScreen(
                                          scheduleRepository:
                                              widget.scheduleRepository,
                                        ),
                                      ),
                                    );
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Немає акаунту? Зареєструватися'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

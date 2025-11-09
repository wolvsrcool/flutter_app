import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/models/user_model.dart';
import 'package:my_project/screens/home_screen.dart';
import 'package:my_project/services/local_storage_service.dart';
import 'package:my_project/services/schedule_repository.dart';
import 'package:my_project/utils/validators.dart';
import 'package:my_project/widgets/custom_button.dart';
import 'package:my_project/widgets/custom_text_field.dart';
import 'package:uuid/uuid.dart';

class RegisterScreen extends StatefulWidget {
  final ScheduleRepository scheduleRepository;

  const RegisterScreen({required this.scheduleRepository, super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final LocalStorageService _storageService;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _storageService = HiveStorageService(
      userBox: Hive.box('userBox'),
      scheduleBox: Hive.box('scheduleBox'),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final email = _emailController.text.trim();

      final userExists = await _storageService.checkUserExists(email);

      if (userExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Користувач з таким email вже існує'),
              backgroundColor: Colors.red,
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final newUser = UserModel(
        id: const Uuid().v4(),
        email: email,
        fullName: _fullNameController.text.trim(),
        group: _groupController.text.trim().toUpperCase(),
        password: _passwordController.text,
      );

      try {
        await _storageService.registerUser(newUser);

        await _storageService.saveUser(newUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Реєстрація успішна!'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute<void>(
              builder: (context) => HomeScreen(
                currentUser: newUser,
                scheduleRepository: widget.scheduleRepository,
              ),
            ),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Помилка реєстрації: $e'),
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
    _fullNameController.dispose();
    _emailController.dispose();
    _groupController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Реєстрація'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context);
                },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  SizedBox(
                    width: contentWidth,
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        CustomTextField(
                          controller: _fullNameController,
                          hintText: 'Повне ім\'я',
                          prefixIcon: Icons.person,
                          validator: Validators.validateFullName,
                          width: contentWidth,
                        ),
                        const SizedBox(height: 16),
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
                          controller: _groupController,
                          hintText: 'Група (наприклад: КБ-101)',
                          prefixIcon: Icons.school,
                          validator: Validators.validateGroup,
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
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          hintText: 'Підтвердження пароля',
                          prefixIcon: Icons.lock_outline,
                          obscureText: true,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                                value,
                                _passwordController.text,
                              ),
                          width: contentWidth,
                        ),
                        const SizedBox(height: 24),
                        CustomButton(
                          text: _isLoading
                              ? 'Реєстрація...'
                              : 'Зареєструватися',
                          onPressed: _isLoading ? () {} : _register,
                          width: contentWidth,
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

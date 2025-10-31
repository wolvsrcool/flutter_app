import 'package:flutter/material.dart';
import 'package:my_project/screens/login_screen.dart';
import 'package:my_project/widgets/custom_button.dart';
import 'package:my_project/widgets/custom_text_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.8;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Реєстрація'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SizedBox(
                  width: contentWidth,
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      CustomTextField(
                        hintText: 'Повне ім\'я',
                        prefixIcon: Icons.person,
                        width: contentWidth,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: 'Електронна пошта',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        width: contentWidth,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: 'Група',
                        prefixIcon: Icons.school,
                        width: contentWidth,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: 'Пароль',
                        prefixIcon: Icons.lock,
                        obscureText: true,
                        width: contentWidth,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        hintText: 'Підтвердження пароля',
                        prefixIcon: Icons.lock_outline,
                        obscureText: true,
                        width: contentWidth,
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Зареєструватися',
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
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
    );
  }
}

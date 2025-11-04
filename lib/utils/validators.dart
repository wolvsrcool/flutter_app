class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Будь ласка, введіть email';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Введіть коректний email';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Будь ласка, введіть пароль';
    }

    if (value.length < 6) {
      return 'Пароль має містити мінімум 6 символів';
    }

    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Будь ласка, введіть повне ім\'я';
    }

    final nameRegex = RegExp(r'^[a-zA-Zа-яА-ЯїЇіІєЄ\s]+$');
    if (!nameRegex.hasMatch(value)) {
      return 'Ім\'я не може містити цифри або спеціальні символи';
    }

    if (value.length < 2) {
      return 'Ім\'я має містити мінімум 2 символи';
    }

    return null;
  }

  static String? validateGroup(String? value) {
    if (value == null || value.isEmpty) {
      return 'Будь ласка, введіть групу';
    }

    final groupRegex = RegExp(r'^[A-ZА-ЯЇІЄ]{2}-\d{3}$');
    if (!groupRegex.hasMatch(value.toUpperCase())) {
      return 'Формат групи: XX-XXX (наприклад: КІ-105)';
    }

    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Будь ласка, підтвердіть пароль';
    }

    if (value != password) {
      return 'Паролі не співпадають';
    }

    return null;
  }
}

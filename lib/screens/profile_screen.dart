import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/models/user_model.dart';
import 'package:my_project/services/connectivity_service.dart';
import 'package:my_project/services/local_storage_service.dart';
import 'package:my_project/services/mqtt_service.dart';
import 'package:my_project/utils/validators.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel currentUser;
  final VoidCallback onProfileUpdated;

  const ProfileScreen({
    required this.currentUser,
    required this.onProfileUpdated,
    super.key,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final LocalStorageService _storageService = HiveStorageService(
    userBox: Hive.box('userBox'),
    scheduleBox: Hive.box('scheduleBox'),
  );

  late final dynamic _mqttService;
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isEditingName = false;
  bool _isEditingGroup = false;
  final _nameFormKey = GlobalKey<FormState>();
  final _groupFormKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _groupController = TextEditingController();

  double _currentTemperature = 0;
  bool _isConnectedToMQTT = false;
  String _statusMessage = 'Ініціалізація...';

  UserModel _currentUserData = UserModel(
    id: '',
    email: '',
    fullName: '',
    group: '',
    password: '',
  );

  @override
  void initState() {
    super.initState();
    _currentUserData = widget.currentUser;
    _fullNameController.text = _currentUserData.fullName;
    _groupController.text = _currentUserData.group;

    _mqttService = MQTTService();

    _initMQTT();
    _initConnectivity();
  }

  void _initMQTT() async {
    final hasConnection = await _connectivityService.hasInternetConnection();

    if (mounted) {
      setState(() {
        _statusMessage = hasConnection
            ? 'Підключення...'
            : 'Немає мережевого з\'єднання';
      });
    }

    if (hasConnection) {
      await _mqttService.connectAndListen();
    }

    _mqttService.temperatureStream.listen((dynamic temperatureData) {
      if (!mounted) return;

      final double temperature = temperatureData is double
          ? temperatureData
          : double.tryParse(temperatureData.toString()) ?? 0.0;

      setState(() {
        _currentTemperature = temperature;
      });
    });

    _mqttService.connectionStatusStream.listen((bool isConnected) {
      if (!mounted) return;

      setState(() {
        _isConnectedToMQTT = isConnected;
      });
    });

    _mqttService.statusMessageStream.listen((String message) {
      if (!mounted) return;

      setState(() {
        _statusMessage = message;
      });
    });
  }

  void _initConnectivity() {
    if (kIsWeb) return;

    _connectivityService.connectionStream.listen((hasConnection) {
      if (!mounted) return;

      final bool connectionStatus = hasConnection;

      if (connectionStatus && !_isConnectedToMQTT) {
        _mqttService.connectAndListen();
      } else if (!connectionStatus) {
        setState(() {
          _statusMessage = 'Немає мережевого з\'єднання';
        });
      }
    });
  }

  String _getInitials(String fullName) {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (fullName.isNotEmpty) {
      return fullName.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  void _startEditingName() {
    setState(() {
      _isEditingName = true;
    });
  }

  void _startEditingGroup() {
    setState(() {
      _isEditingGroup = true;
    });
  }

  void _cancelEditingName() {
    setState(() {
      _isEditingName = false;
      _fullNameController.text = _currentUserData.fullName;
    });
  }

  void _cancelEditingGroup() {
    setState(() {
      _isEditingGroup = false;
      _groupController.text = _currentUserData.group;
    });
  }

  void _saveName() async {
    if (_nameFormKey.currentState!.validate()) {
      final updatedUser = UserModel(
        id: _currentUserData.id,
        email: _currentUserData.email,
        fullName: _fullNameController.text.trim(),
        group: _currentUserData.group,
        password: _currentUserData.password,
      );

      try {
        await _storageService.saveUser(updatedUser);
        await _storageService.registerUser(updatedUser);

        setState(() {
          _isEditingName = false;
          _currentUserData = updatedUser;
        });
        widget.onProfileUpdated();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ім\'я оновлено успішно!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Помилка оновлення: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _saveGroup() async {
    if (_groupFormKey.currentState!.validate()) {
      final updatedUser = UserModel(
        id: _currentUserData.id,
        email: _currentUserData.email,
        fullName: _currentUserData.fullName,
        group: _groupController.text.trim().toUpperCase(),
        password: _currentUserData.password,
      );

      try {
        await _storageService.saveUser(updatedUser);
        await _storageService.registerUser(updatedUser);

        setState(() {
          _isEditingGroup = false;
          _currentUserData = updatedUser;
        });
        widget.onProfileUpdated();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Групу оновлено успішно!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Помилка оновлення: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _groupController.dispose();
    _mqttService.dispose();
    if (!kIsWeb) {
      _connectivityService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final contentWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.8;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: contentWidth,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blue,
                        child: Text(
                          _getInitials(_currentUserData.fullName),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        _currentUserData.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildEditableField(
                        title: 'Повне ім\'я',
                        value: _currentUserData.fullName,
                        isEditing: _isEditingName,
                        controller: _fullNameController,
                        formKey: _nameFormKey,
                        validator: Validators.validateFullName,
                        onEdit: _startEditingName,
                        onCancel: _cancelEditingName,
                        onSave: _saveName,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 16),

                      _buildEditableField(
                        title: 'Група',
                        value: _currentUserData.group,
                        isEditing: _isEditingGroup,
                        controller: _groupController,
                        formKey: _groupFormKey,
                        validator: Validators.validateGroup,
                        onEdit: _startEditingGroup,
                        onCancel: _cancelEditingGroup,
                        onSave: _saveGroup,
                        icon: Icons.school_outlined,
                      ),

                      if (!kIsWeb) const SizedBox(height: 48),
                      if (!kIsWeb) _buildWeatherCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              const Text(
                'Погода у Львові',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.thermostat, color: Colors.orange[600], size: 32),
              const SizedBox(width: 12),
              Text(
                '${_currentTemperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isConnectedToMQTT ? Icons.cloud_done : Icons.cloud_off,
                color: _isConnectedToMQTT ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _statusMessage,
                style: TextStyle(
                  fontSize: 12,
                  color: _isConnectedToMQTT ? Colors.green : Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String title,
    required String value,
    required bool isEditing,
    required TextEditingController controller,
    required GlobalKey<FormState> formKey,
    required String? Function(String?)? validator,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
    required VoidCallback onSave,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: isEditing
          ? Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Введіть $title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    validator: validator,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: onCancel,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Скасувати',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Зберегти',
                              style: TextStyle(
                                color: Colors.white,
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
            )
          : Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: onEdit,
                  tooltip: 'Редагувати $title',
                  color: Colors.blue,
                ),
              ],
            ),
    );
  }
}

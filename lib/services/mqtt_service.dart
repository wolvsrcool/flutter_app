import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTService {
  static final MQTTService _instance = MQTTService._internal();
  factory MQTTService() => _instance;
  MQTTService._internal();

  late MqttServerClient _client;
  final StreamController<double> _temperatureController =
      StreamController<double>.broadcast();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast();
  final StreamController<String> _statusMessageController =
      StreamController<String>.broadcast();

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _isDisposed = false;

  Stream<double> get temperatureStream => _temperatureController.stream;
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;
  Stream<String> get statusMessageStream => _statusMessageController.stream;
  bool get isConnected => _isConnected;

  Future<void> connectAndListen() async {
    if (_isConnecting || _isConnected || _isDisposed) return;

    _isConnecting = true;
    _addStatusMessage('Підключення до MQTT...');

    try {
      final clientId =
          'flutter_mobile_${DateTime.now().millisecondsSinceEpoch}';
      _client = MqttServerClient('broker.hivemq.com', clientId);

      _client.port = 1883;
      _client.logging(on: false);
      _client.keepAlivePeriod = 30;
      _client.onDisconnected = _onDisconnected;
      _client.onConnected = _onConnected;
      _client.onSubscribed = _onSubscribed;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .startClean()
          .withWillQos(MqttQos.atMostOnce);
      _client.connectionMessage = connMessage;

      await _client.connect();
    } catch (e) {
      _addStatusMessage('Помилка підключення');
      _isConnecting = false;
      _isConnected = false;
      _addConnectionStatus(false);
    }
  }

  void _onConnected() {
    if (_isDisposed) return;

    _isConnecting = false;
    _isConnected = true;
    _addConnectionStatus(true);
    _addStatusMessage('Підключено до MQTT');

    try {
      _client.subscribe('weather/lviv/temperature', MqttQos.atMostOnce);

      _client.updates!.listen(
        (List<MqttReceivedMessage<MqttMessage>> messages) {
          if (_isDisposed) return;

          final MqttPublishMessage recMess =
              messages[0].payload as MqttPublishMessage;
          final String payload = MqttPublishPayload.bytesToStringAsString(
            recMess.payload.message,
          );

          try {
            final double temperature = double.parse(payload);
            _addTemperature(temperature);
            _addStatusMessage('Дані оновлюються');
          } catch (e) {
            _addStatusMessage('Помилка отримання даних');
          }
        },
        onError: (error) {
          if (!_isDisposed) {
            _addStatusMessage('Помилка отримання даних');
          }
        },
      );
    } catch (e) {
      return;
    }
  }

  void _onSubscribed(String topic) {
    if (!_isDisposed) {
      _addStatusMessage('Очікування даних...');
    }
  }

  void _onDisconnected() {
    if (_isDisposed) return;

    _isConnecting = false;
    _isConnected = false;
    _addConnectionStatus(false);
    _addStatusMessage('Відключено від MQTT');
  }

  void _addTemperature(double temperature) {
    if (!_temperatureController.isClosed) {
      _temperatureController.add(temperature);
    }
  }

  void _addConnectionStatus(bool status) {
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
  }

  void _addStatusMessage(String message) {
    if (!_statusMessageController.isClosed) {
      _statusMessageController.add(message);
    }
  }

  Future<void> disconnect() async {
    _isConnecting = false;
    _isConnected = false;
    try {
      _client.disconnect();
    } catch (e) {
      return;
    }
  }

  void dispose() {
    _isDisposed = true;
    _isConnected = false;
    _isConnecting = false;

    if (!_temperatureController.isClosed) _temperatureController.close();
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.close();
    }
    if (!_statusMessageController.isClosed) _statusMessageController.close();

    disconnect();
  }
}

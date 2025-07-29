import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/water_tank_data.dart';

class ApiService {
  static const String baseUrl = 'http://1.1.1.1:5001';
  static const String waterLevelEndpoint = '/pin/V3';
  static const String buzzerEndpoint = '/update/V1';
  static const String cpuTempEndpoint = '/cpu/temperature';
  static const String beepLevelEndpoint = '/api/buzzer/beeplevel';
  static const String triggerLevelEndpoint = '/pin/V2';
  static const String triggerLevelUpdateEndpoint = '/update/V2';

  static Future<WaterTankData?> getWaterLevel() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$waterLevelEndpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WaterTankData.fromJson(data);
      } else {
        print('Failed to load water level: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching water level: $e');
      return null;
    }
  }

  static Future<bool> updateBuzzer(bool isOn) async {
    try {
      final value = isOn ? 1 : 0;
      final response = await http
          .get(
            Uri.parse('$baseUrl$buzzerEndpoint?value=$value'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating buzzer: $e');
      return false;
    }
  }

  static Future<bool?> getBuzzerStatus() async {
    try {
      final response = await http
          .get(
            Uri.parse('http://1.1.1.1:5001/pin/V1'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final value = int.parse(data['value'].toString());
        return value == 1;
      } else {
        print('Failed to get buzzer status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching buzzer status: $e');
      return null;
    }
  }

  static Future<CPUTemperatureData?> getCPUTemperature() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$cpuTempEndpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CPUTemperatureData.fromJson(data);
      } else {
        print('Failed to get CPU temperature: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching CPU temperature: $e');
      return null;
    }
  }

  // NodeMCU Digital Pins API methods
  static Future<DigitalPinData?> getDigitalPin(String pin) async {
    try {
      final response = await http
          .get(
            Uri.parse('http://pizero.local:5001/pin/V$pin'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DigitalPinData.fromJson(data, pin);
      } else {
        print('Failed to get digital pin V$pin: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching digital pin V$pin: $e');
      return null;
    }
  }

  static Future<List<DigitalPinData>> getAllDigitalPins() async {
    final pins = ['5', '6', '7'];
    final List<DigitalPinData> results = [];
    
    // Use parallel requests for better performance
    final futures = pins.map((pin) => getDigitalPin(pin)).toList();
    final responses = await Future.wait(futures, eagerError: false);
    
    for (int i = 0; i < pins.length; i++) {
      final pinData = responses[i];
      if (pinData != null) {
        results.add(pinData);
      } else {
        // Create a fallback pin data if API fails to maintain consistency
        results.add(DigitalPinData(
          pin: 'V${pins[i]}',
          digitalPin: 'D${pins[i]}',
          isHigh: false,
          timestamp: DateTime.now(),
        ));
        print('Warning: Failed to fetch pin V${pins[i]}, using fallback data');
      }
    }
    
    return results;
  }

  // Beep Level API methods
  static Future<BeepLevelData?> getBeepLevel() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$beepLevelEndpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return BeepLevelData.fromJson(data);
      } else if (response.statusCode == 404) {
        // Beep level not initialized on server
        print('Beep level not initialized on server');
        return null;
      } else {
        print('Failed to get beep level: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching beep level: $e');
      return null;
    }
  }

  static Future<bool> setBeepLevel(int level) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl$beepLevelEndpoint'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'beep_level': level}),
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error setting beep level: $e');
      return false;
    }
  }

  // Trigger Level API methods
  static Future<TriggerLevelData?> getTriggerLevel() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$triggerLevelEndpoint'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TriggerLevelData.fromJson(data);
      } else {
        print('Failed to get trigger level: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching trigger level: $e');
      return null;
    }
  }

  static Future<bool> setTriggerLevel(int value) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl$triggerLevelUpdateEndpoint?value=$value'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      print('Error setting trigger level: $e');
      return false;
    }
  }
}

class CPUTemperatureData {
  final double temperature;
  final String unit;
  final String status;
  final DateTime timestamp;

  CPUTemperatureData({
    required this.temperature,
    required this.unit,
    required this.status,
    required this.timestamp,
  });

  factory CPUTemperatureData.fromJson(Map<String, dynamic> json) {
    return CPUTemperatureData(
      temperature: (json['temperature'] as num).toDouble(),
      unit: json['unit'] as String,
      status: json['status'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] as num) * 1000).toInt(),
      ),
    );
  }

  String get temperatureText {
    return '${temperature.toStringAsFixed(1)}$unit';
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'critical':
        return const Color(0xFFE53E3E); // Red
      case 'warning':
        return const Color(0xFFFF9500); // Orange
      case 'warm':
        return const Color(0xFFFFD60A); // Yellow
      case 'normal':
      default:
        return const Color(0xFF30D158); // Green
    }
  }

  String get statusText {
    switch (status.toLowerCase()) {
      case 'critical':
        return 'Critical';
      case 'warning':
        return 'Warning';
      case 'warm':
        return 'Warm';
      case 'normal':
      default:
        return 'Normal';
    }
  }
}

class DigitalPinData {
  final String pin;
  final String digitalPin;
  final bool isHigh;
  final DateTime timestamp;

  DigitalPinData({
    required this.pin,
    required this.digitalPin,
    required this.isHigh,
    required this.timestamp,
  });

  factory DigitalPinData.fromJson(Map<String, dynamic> json, String pinNumber) {
    final value = json['value'].toString();
    final isHigh = value == '1';
    
    // Map V5, V6, V7 to D5, D6, D7
    String digitalPin;
    switch (pinNumber) {
      case '5':
        digitalPin = 'D5';
        break;
      case '6':
        digitalPin = 'D6';
        break;
      case '7':
        digitalPin = 'D7';
        break;
      default:
        digitalPin = 'D$pinNumber';
    }

    return DigitalPinData(
      pin: json['pin'] as String,
      digitalPin: digitalPin,
      isHigh: isHigh,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] as num) * 1000).toInt(),
      ),
    );
  }

  String get stateText {
    return isHigh ? 'HIGH' : 'LOW';
  }

  Color get stateColor {
    return isHigh ? const Color(0xFF30D158) : const Color(0xFFE53E3E);
  }

  IconData get stateIcon {
    return isHigh ? Icons.toggle_on : Icons.toggle_off;
  }
}

class BeepLevelData {
  final int beepLevel;
  final String range;
  final DateTime timestamp;
  final String description;

  BeepLevelData({
    required this.beepLevel,
    required this.range,
    required this.timestamp,
    required this.description,
  });

  factory BeepLevelData.fromJson(Map<String, dynamic> json) {
    return BeepLevelData(
      beepLevel: (json['beep_level'] as num).toInt(),
      range: json['range'] as String? ?? '0-255',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] as num) * 1000).toInt(),
      ),
      description: json['description'] as String? ?? 'Buzzer beep level intensity',
    );
  }

  String get levelText {
    return beepLevel.toString();
  }

  double get levelPercentage {
    return beepLevel / 255.0;
  }

  Color get levelColor {
    if (beepLevel == 0) {
      return const Color(0xFF9E9E9E); // Grey for muted
    } else if (beepLevel < 85) {
      return const Color(0xFF4CAF50); // Green for low
    } else if (beepLevel < 170) {
      return const Color(0xFFFF9800); // Orange for medium
    } else {
      return const Color(0xFFF44336); // Red for high
    }
  }

  String get levelDescription {
    if (beepLevel == 0) {
      return 'Muted';
    } else if (beepLevel < 85) {
      return 'Low';
    } else if (beepLevel < 170) {
      return 'Medium';
    } else {
      return 'High';
    }
  }
}

class TriggerLevelData {
  final int triggerValue;
  final DateTime timestamp;

  TriggerLevelData({
    required this.triggerValue,
    required this.timestamp,
  });

  factory TriggerLevelData.fromJson(Map<String, dynamic> json) {
    return TriggerLevelData(
      triggerValue: int.parse(json['value'].toString()),
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        ((json['timestamp'] as num) * 1000).toInt(),
      ),
    );
  }

  int get triggerPercentage {
    switch (triggerValue) {
      case 0:
        return 0;
      case 33:
        return 33;
      case 66:
        return 66;
      default:
        return 0; // Default to 0% if invalid value
    }
  }

  String get triggerText {
    return '${triggerPercentage}%';
  }

  String get triggerDescription {
    switch (triggerValue) {
      case 0:
        return 'Low Trigger (0%)';
      case 33:
        return 'Medium Trigger (33%)';
      case 66:
        return 'High Trigger (66%)';
      default:
        return 'Unknown Trigger';
    }
  }

  Color get triggerColor {
    switch (triggerValue) {
      case 0:
        return const Color(0xFF4CAF50); // Green for low
      case 33:
        return const Color(0xFFFF9800); // Orange for medium
      case 66:
        return const Color(0xFFF44336); // Red for high
      default:
        return const Color(0xFF9E9E9E); // Grey for unknown
    }
  }

  IconData get triggerIcon {
    switch (triggerValue) {
      case 0:
        return Icons.water_drop_outlined;
      case 33:
        return Icons.water_drop;
      case 66:
        return Icons.water_drop_sharp;
      default:
        return Icons.help_outline;
    }
  }
}

import 'package:flutter/material.dart';

class WaterTankData {
  final int waterLevel;
  final DateTime lastUpdated;

  WaterTankData({
    required this.waterLevel,
    required this.lastUpdated,
  });

  factory WaterTankData.fromJson(Map<String, dynamic> json) {
    return WaterTankData(
      waterLevel: int.parse(json['value'].toString()),
      lastUpdated: DateTime.now(),
    );
  }

  String get waterLevelText {
    switch (waterLevel) {
      case 0:
        return 'Empty';
      case 33:
        return 'Low';
      case 66:
        return 'Medium';
      case 100:
        return 'Full';
      default:
        return 'Unknown';
    }
  }

  Color get waterLevelColor {
    switch (waterLevel) {
      case 0:
        return const Color(0xFFFF3B30); // Red
      case 33:
        return const Color(0xFFFF9500); // Orange
      case 66:
        return const Color(0xFFFFCC02); // Yellow
      case 100:
        return const Color(0xFF34C759); // Green
      default:
        return const Color(0xFF8E8E93); // Gray
    }
  }
}
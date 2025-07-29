import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/water_tank_data.dart';
import '../services/api_service.dart';
import '../providers/theme_provider.dart';
import '../widgets/water_level_indicator.dart';
import '../widgets/buzzer_control.dart';
import '../widgets/status_card.dart';

class WaterTankScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const WaterTankScreen({super.key, required this.themeProvider});

  @override
  State<WaterTankScreen> createState() => _WaterTankScreenState();
}

class _WaterTankScreenState extends State<WaterTankScreen>
    with TickerProviderStateMixin {
  WaterTankData? _waterData;
  TriggerLevelData? _triggerData;
  bool _isConnected = false;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _fetchWaterLevel();
    _fetchTriggerLevel();
    _startAutoUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startAutoUpdate() {
    _updateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _fetchWaterLevel();
      _fetchTriggerLevel();
    });
  }

  Future<void> _fetchWaterLevel() async {
    try {
      final data = await ApiService.getWaterLevel();
      if (mounted) {
        setState(() {
          _waterData = data;
          _isConnected = data != null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConnected = false;
        });
      }
    }
  }

  Future<void> _fetchTriggerLevel() async {
    try {
      final data = await ApiService.getTriggerLevel();
      if (mounted) {
        setState(() {
          _triggerData = data;
        });
      }
    } catch (e) {
      print('Error fetching trigger level: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: widget.themeProvider.backgroundColor,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.themeProvider.backgroundGradient,
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Clean Header
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: widget.themeProvider.cardBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Simple icon
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF667eea),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              CupertinoIcons.drop_fill,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Title and subtitle
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Water Tank Monitor',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: widget.themeProvider.textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'IoT System Dashboard',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        widget.themeProvider.secondaryTextColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Simple status indicator
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _isConnected
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _isConnected
                                        ? Colors.green
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isConnected ? 'Online' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: _isConnected
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Water Level Radial Gauge - Full width on mobile
                    Center(
                      child: WaterLevelIndicator(
                        waterData: _waterData,
                        themeProvider: widget.themeProvider,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Current Level Card
                    _buildQuickStatCard(
                      'Current Level',
                      '${_waterData?.waterLevel ?? 0}%',
                      CupertinoIcons.drop,
                      _waterData?.waterLevelColor ?? Colors.grey,
                    ),

                    const SizedBox(height: 16),

                    // Status Card
                    StatusCard(
                      waterData: _waterData,
                      isConnected: _isConnected,
                      themeProvider: widget.themeProvider,
                    ),

                    const SizedBox(height: 16),

                    // Trigger Level Card
                    _buildQuickStatCard(
                      'Trigger Level',
                      _triggerData?.triggerText ?? 'Unknown',
                      _triggerData?.triggerIcon ?? Icons.water_drop_outlined,
                      _triggerData?.triggerColor ?? Colors.grey,
                    ),

                    const SizedBox(height: 16),

                    // Buzzer Control
                    BuzzerControl(themeProvider: widget.themeProvider),

                    const SizedBox(height: 16),

                    // System Status Card
                    _buildQuickStatCard(
                      'System Status',
                      _isConnected ? 'Online' : 'Offline',
                      _isConnected
                          ? CupertinoIcons.checkmark_circle
                          : CupertinoIcons.xmark_circle,
                      _isConnected ? Colors.green : Colors.red,
                    ),

                    const SizedBox(height: 24),

                    // Bottom stats row - Stack on mobile for better readability
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildInfoCard(
                                'Last Update',
                                _waterData != null
                                    ? _formatTime(_waterData!.lastUpdated)
                                    : 'Never',
                                CupertinoIcons.clock,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildInfoCard(
                                'Tank Status',
                                _waterData?.waterLevelText ?? 'Unknown',
                                CupertinoIcons.info_circle,
                                _waterData?.waterLevelColor ?? Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: widget.themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.themeProvider.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: widget.themeProvider.textColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: widget.themeProvider.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';

class SystemScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const SystemScreen({super.key, required this.themeProvider});

  @override
  State<SystemScreen> createState() => _SystemScreenState();
}

class _SystemScreenState extends State<SystemScreen>
    with TickerProviderStateMixin {
  CPUTemperatureData? _cpuTempData;
  Timer? _tempUpdateTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fetchCPUTemperature();
    _startCPUTempMonitoring();
  }

  @override
  void dispose() {
    _tempUpdateTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCPUTempMonitoring() {
    _tempUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _fetchCPUTemperature();
    });
  }

  Future<void> _fetchCPUTemperature() async {
    try {
      final tempData = await ApiService.getCPUTemperature();
      if (mounted) {
        setState(() {
          _cpuTempData = tempData;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeProvider,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.themeProvider.backgroundGradient,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Information',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // CPU Temperature Card with real-time updates
                  _buildCPUTemperatureCard(),
                  const SizedBox(height: 16),

                  _buildSystemCard(
                    'Device Status',
                    'Raspberry Pi Zero 2W',
                    CupertinoIcons.device_phone_portrait,
                    Colors.green,
                  ),
                  const SizedBox(height: 16),

                  _buildSystemCard(
                    'Network Connection',
                    'WiFi Connected',
                    CupertinoIcons.wifi,
                    Colors.blue,
                  ),
                  const SizedBox(height: 16),

                  _buildSystemCard(
                    'Last Sync',
                    'Just now',
                    CupertinoIcons.refresh,
                    Colors.orange,
                  ),
                  const SizedBox(height: 16),

                  _buildSystemCard(
                    'System Uptime',
                    '2 days, 14 hours',
                    CupertinoIcons.clock,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCPUTemperatureCard() {
    final tempData = _cpuTempData;
    final temperature = tempData?.temperatureText ?? 'Loading...';
    final status = tempData?.statusText ?? 'Unknown';
    final statusColor = tempData?.statusColor ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.themeProvider.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: tempData != null && tempData.status == 'critical'
                        ? _pulseAnimation.value
                        : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.thermometer,
                        color: statusColor,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CPU Temperature',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.themeProvider.secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      temperature,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Temperature status bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: widget.themeProvider.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: tempData != null
                    ? (tempData.temperature / 100).clamp(0.0, 1.0)
                    : 0.0,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0°C',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.themeProvider.secondaryTextColor,
                ),
              ),
              Text(
                'Updates every second',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.themeProvider.secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Text(
                '100°C',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.themeProvider.secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSystemCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.themeProvider.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: widget.themeProvider.secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.themeProvider.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

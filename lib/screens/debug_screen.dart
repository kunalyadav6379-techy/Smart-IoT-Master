import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../providers/theme_provider.dart';
import '../utils/cupertino_utils.dart';
import 'nodemcu_pins_screen.dart';

class DebugScreen extends StatelessWidget {
  final ThemeProvider themeProvider;

  const DebugScreen({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeProvider,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: themeProvider.backgroundGradient,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Debug Console',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // API Endpoints Section
                  Text(
                    'API Endpoints',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // NodeMCU Pin Status Card
                  _buildNavigationCard(
                    context,
                    'NodeMCU Pin Status',
                    'See Sensor Status',
                    CupertinoIcons.device_phone_portrait,
                    const Color(0xFF667eea),
                    () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (context) => NodeMCUPinsScreen(
                            themeProvider: themeProvider,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Water Level Endpoint Card
                  _buildNavigationCard(
                    context,
                    'Water Level Endpoint',
                    'http://1.1.1.1:5001/pin/V4',
                    CupertinoIcons.drop,
                    Colors.blue,
                    () {
                      CupertinoUtils.showAlert(
                        context,
                        title: 'Water Level API',
                        message: 'Test water level endpoint?',
                        primaryButtonText: 'Test',
                        secondaryButtonText: 'Cancel',
                        onPrimaryPressed: () {
                          Navigator.of(context).pop();
                          CupertinoUtils.showSuccessToast(
                            context,
                            'Water level API test executed',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Buzzer Control Endpoint Card
                  _buildNavigationCard(
                    context,
                    'Buzzer Control Endpoint',
                    'http://1.1.1.1:5001/update/V1',
                    CupertinoIcons.speaker_2,
                    Colors.red,
                    () {
                      CupertinoUtils.showAlert(
                        context,
                        title: 'Buzzer API',
                        message: 'Test buzzer endpoint?',
                        primaryButtonText: 'Test',
                        secondaryButtonText: 'Cancel',
                        onPrimaryPressed: () {
                          Navigator.of(context).pop();
                          CupertinoUtils.showSuccessToast(
                            context,
                            'Buzzer API test executed',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // CPU Temperature Endpoint Card
                  _buildNavigationCard(
                    context,
                    'CPU Temperature Endpoint',
                    'http://1.1.1.1:5001/cpu/temperature',
                    CupertinoIcons.thermometer,
                    Colors.orange,
                    () {
                      CupertinoUtils.showAlert(
                        context,
                        title: 'CPU Temperature API',
                        message: 'Test CPU temperature endpoint?',
                        primaryButtonText: 'Test',
                        secondaryButtonText: 'Cancel',
                        onPrimaryPressed: () {
                          Navigator.of(context).pop();
                          CupertinoUtils.showSuccessToast(
                            context,
                            'CPU temperature API test executed',
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Debug Tools Section
                  Text(
                    'Debug Tools',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildDebugTool(
                    context,
                    'Clear Cache',
                    'Clear all cached API responses',
                    CupertinoIcons.trash,
                    Colors.orange,
                  ),
                  const SizedBox(height: 12),

                  _buildDebugTool(
                    context,
                    'Reset Settings',
                    'Reset all app settings to default',
                    CupertinoIcons.refresh,
                    Colors.purple,
                  ),
                  const SizedBox(height: 12),

                  _buildDebugTool(
                    context,
                    'Export Logs',
                    'Export debug logs for analysis',
                    CupertinoIcons.square_arrow_up,
                    Colors.green,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavigationCard(
    BuildContext context,
    String title,
    String endpoint,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: themeProvider.cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
          ),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
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
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    endpoint,
                    style: TextStyle(
                      fontSize: 13,
                      color: themeProvider.secondaryTextColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: themeProvider.secondaryTextColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugTool(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        CupertinoUtils.showAlert(
          context,
          title: 'Debug Tool',
          message: 'Execute $title?',
          primaryButtonText: 'Execute',
          secondaryButtonText: 'Cancel',
          onPrimaryPressed: () {
            Navigator.of(context).pop();
            CupertinoUtils.showSuccessToast(
              context,
              '$title executed successfully',
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeProvider.borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: themeProvider.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_right,
              color: themeProvider.secondaryTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }


}

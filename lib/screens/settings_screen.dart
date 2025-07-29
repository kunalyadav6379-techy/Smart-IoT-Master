import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../providers/theme_provider.dart';
import '../utils/cupertino_utils.dart';
import 'beep_level_screen.dart';
import 'trigger_level_screen.dart';

class SettingsScreen extends StatelessWidget {
  final ThemeProvider themeProvider;

  const SettingsScreen({super.key, required this.themeProvider});

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
                    'Settings',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // API Configuration Section
                  _buildSectionHeader('API Configuration'),
                  const SizedBox(height: 12),

                  _buildSettingItem(
                    context,
                    'Water Level Endpoint',
                    'http://1.1.1.1:5001/pin/V3',
                    CupertinoIcons.link,
                    Colors.blue,
                    null,
                  ),
                  const SizedBox(height: 8),

                  _buildSettingItem(
                    context,
                    'Buzzer Control Endpoint',
                    'http://1.1.1.1:5001/update/V1',
                    CupertinoIcons.speaker_2,
                    Colors.red,
                    null,
                  ),
                  const SizedBox(height: 8),

                  _buildSettingItem(
                    context,
                    'Buzzer Status Endpoint',
                    'http://pizero.local:5001/pin/V1',
                    CupertinoIcons.info_circle,
                    Colors.orange,
                    null,
                  ),

                  const SizedBox(height: 32),

                  // Refresh Settings Section
                  _buildSectionHeader('Refresh Settings'),
                  const SizedBox(height: 12),

                  _buildSettingItem(
                    context,
                    'Water Level Refresh',
                    'Every 5 seconds',
                    CupertinoIcons.refresh,
                    Colors.green,
                    null,
                  ),
                  const SizedBox(height: 8),

                  _buildSettingItem(
                    context,
                    'Buzzer Status Check',
                    'Every 3 seconds',
                    CupertinoIcons.clock,
                    Colors.purple,
                    null,
                  ),

                  const SizedBox(height: 32),

                  // App Settings Section
                  _buildSectionHeader('App Settings'),
                  const SizedBox(height: 12),

                  _buildThemeSwitcher(context),
                  const SizedBox(height: 8),

                  _buildBeepLevelSetting(context),
                  const SizedBox(height: 8),

                  _buildTriggerLevelSetting(context),
                  const SizedBox(height: 8),

                  _buildSettingItem(
                    context,
                    'Notifications',
                    'Enabled',
                    CupertinoIcons.bell,
                    Colors.yellow,
                    null,
                  ),
                  const SizedBox(height: 8),

                  _buildSettingItem(
                    context,
                    'Auto-sync',
                    'Cross-platform enabled',
                    CupertinoIcons.arrow_2_circlepath,
                    Colors.cyan,
                    null,
                  ),

                  const SizedBox(height: 32),

                  // Developer Credits Section
                  _buildSectionHeader('Developer Credits'),
                  const SizedBox(height: 12),

                  _buildDeveloperCredits(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: themeProvider.textColor,
      ),
    );
  }

  Widget _buildThemeSwitcher(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showThemeSelector(context);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor, width: 1),
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
                color: _getThemeColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                themeProvider.themeModeIcon,
                color: _getThemeColor(),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    themeProvider.themeModeText,
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

  Color _getThemeColor() {
    switch (themeProvider.themeMode) {
      case AppThemeMode.light:
        return Colors.orange;
      case AppThemeMode.dark:
        return Colors.indigo;
      case AppThemeMode.system:
        return Colors.purple;
    }
  }

  void _showThemeSelector(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text(
            'Select Theme',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          message: const Text(
            'Choose your preferred theme mode',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                themeProvider.setThemeMode(AppThemeMode.light);
                CupertinoUtils.showSuccessToast(context, 'Light mode enabled');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.light_mode, color: Colors.orange, size: 20),
                  const SizedBox(width: 12),
                  const Text('Light Mode'),
                  if (themeProvider.themeMode == AppThemeMode.light) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.checkmark,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                themeProvider.setThemeMode(AppThemeMode.dark);
                CupertinoUtils.showSuccessToast(context, 'Dark mode enabled');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.dark_mode, color: Colors.indigo, size: 20),
                  const SizedBox(width: 12),
                  const Text('Dark Mode'),
                  if (themeProvider.themeMode == AppThemeMode.dark) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.checkmark,
                      color: Colors.indigo,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
            CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
                themeProvider.setThemeMode(AppThemeMode.system);
                CupertinoUtils.showSuccessToast(
                  context,
                  'System theme enabled',
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.brightness_auto,
                    color: Colors.purple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Text('Follow System'),
                  if (themeProvider.themeMode == AppThemeMode.system) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      CupertinoIcons.checkmark,
                      color: Colors.purple,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Widget _buildBeepLevelSetting(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => BeepLevelScreen(themeProvider: themeProvider),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor, width: 1),
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
                color: Colors.deepPurple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                CupertinoIcons.speaker_2,
                color: Colors.deepPurple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buzzer Beep Level',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Adjust buzzer intensity (0-255)',
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

  Widget _buildTriggerLevelSetting(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) =>
                TriggerLevelScreen(themeProvider: themeProvider),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor, width: 1),
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
                color: Colors.teal.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.water_drop, color: Colors.teal, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trigger Level',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Set water level trigger threshold',
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

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap:
          onTap ??
          () {
            CupertinoUtils.showInfoToast(context, 'Feature coming soon!');
          },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeProvider.cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: themeProvider.borderColor, width: 1),
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
                    value,
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

  Widget _buildDeveloperCredits() {
    return Container(
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
      child: Column(
        children: [
          // Simple made in India with love
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Made in India with',
                style: TextStyle(
                  fontSize: 14,
                  color: themeProvider.secondaryTextColor,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                '❤️',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Text(
                'by Kunal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeProvider.textColor,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Simple tech stack
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Built with Dart programming language & Flutter',
                style: TextStyle(
                  fontSize: 12,
                  color: themeProvider.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(width: 6),
              const Text(
                '🚀',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

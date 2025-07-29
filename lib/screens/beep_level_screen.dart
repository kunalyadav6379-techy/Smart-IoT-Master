import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../utils/cupertino_utils.dart';

class BeepLevelScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const BeepLevelScreen({super.key, required this.themeProvider});

  @override
  State<BeepLevelScreen> createState() => _BeepLevelScreenState();
}

class _BeepLevelScreenState extends State<BeepLevelScreen>
    with TickerProviderStateMixin {
  BeepLevelData? _beepLevelData;
  double _currentLevel = 0.0;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasError = false;
  String _errorMessage = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fetchBeepLevel();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchBeepLevel() async {
    try {
      final beepData = await ApiService.getBeepLevel();
      if (mounted) {
        if (beepData != null) {
          setState(() {
            _beepLevelData = beepData;
            _currentLevel = beepData.beepLevel.toDouble();
            _isLoading = false;
            _hasError = false;
            _errorMessage = '';
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Beep level not initialized on server. No beep level has been set yet. Please check if the Node.js server is running and the API endpoint is accessible.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'API connection error: Cannot connect to server. Please ensure the Node.js server is running on http://1.1.1.1:5001';
        });
      }
    }
  }

  Future<void> _saveBeepLevel() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await ApiService.setBeepLevel(_currentLevel.round());
      
      if (success && mounted) {
        // Refresh data after successful save
        await _fetchBeepLevel();
        
        CupertinoUtils.showSuccessToast(
          context,
          'Beep level set to ${_currentLevel.round()}',
        );
      } else if (mounted) {
        CupertinoUtils.showErrorToast(
          context,
          'Failed to save beep level',
        );
      }
    } catch (e) {
      if (mounted) {
        CupertinoUtils.showErrorToast(
          context,
          'Error saving beep level',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: widget.themeProvider.backgroundGradient,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Custom App Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.themeProvider.cardBackgroundColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              CupertinoIcons.back,
                              color: widget.themeProvider.textColor,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Buzzer Beep Level',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: widget.themeProvider.textColor,
                                ),
                              ),
                              Text(
                                'Adjust buzzer intensity (0-255)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.themeProvider.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          if (_isLoading)
                            _buildLoadingCard()
                          else if (_hasError)
                            _buildErrorCard()
                          else ...[
                            // Current Level Display
                            _buildCurrentLevelCard(),
                            const SizedBox(height: 24),
                            
                            // Level Slider
                            _buildLevelSlider(),
                            const SizedBox(height: 24),
                            
                            // Quick Presets
                            _buildQuickPresets(),
                            const SizedBox(height: 24),
                            
                            // Save Button
                            _buildSaveButton(),
                            const SizedBox(height: 24),
                            
                            // Info Card
                            _buildInfoCard(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeProvider.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          const CupertinoActivityIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading beep level...',
            style: TextStyle(
              fontSize: 16,
              color: widget.themeProvider.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Error Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red,
              size: 48,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Error Title
          Text(
            'API Connection Error',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Error Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: widget.themeProvider.textColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Retry Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _hasError = false;
                  _errorMessage = '';
                });
                _fetchBeepLevel();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CupertinoIcons.refresh, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Retry Connection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Troubleshooting Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.themeProvider.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.info_circle,
                      color: widget.themeProvider.secondaryTextColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Troubleshooting',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: widget.themeProvider.textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTroubleshootingItem('• Check if Node.js server is running'),
                _buildTroubleshootingItem('• Verify API endpoint: /api/buzzer/beeplevel'),
                _buildTroubleshootingItem('• Ensure network connectivity'),
                _buildTroubleshootingItem('• Server should be on http://1.1.1.1:5001'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: widget.themeProvider.secondaryTextColor,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildCurrentLevelCard() {
    final levelColor = _getLevelColor(_currentLevel.round());
    final levelDescription = _getLevelDescription(_currentLevel.round());
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.themeProvider.borderColor,
          width: 1,
        ),
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
          // Level Icon with Animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _currentLevel > 0 ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _currentLevel > 0 ? [
                      BoxShadow(
                        color: levelColor.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    _currentLevel == 0 
                        ? CupertinoIcons.speaker_slash 
                        : CupertinoIcons.speaker_2,
                    color: levelColor,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Current Level Value
          Text(
            _currentLevel.round().toString(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: levelColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Level Description
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: levelColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              levelDescription,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: levelColor,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Percentage
          Text(
            '${((_currentLevel / 255) * 100).round()}% intensity',
            style: TextStyle(
              fontSize: 14,
              color: widget.themeProvider.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelSlider() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeProvider.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adjust Level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getLevelColor(_currentLevel.round()),
              inactiveTrackColor: widget.themeProvider.secondaryBackgroundColor,
              thumbColor: _getLevelColor(_currentLevel.round()),
              overlayColor: _getLevelColor(_currentLevel.round()).withValues(alpha: 0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _currentLevel,
              min: 0,
              max: 255,
              divisions: 255,
              onChanged: (value) {
                setState(() {
                  _currentLevel = value;
                });
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Range Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 (Muted)',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.themeProvider.secondaryTextColor,
                ),
              ),
              Text(
                '255 (Max)',
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

  Widget _buildQuickPresets() {
    final presets = [
      {'label': 'Muted', 'value': 0, 'color': const Color(0xFF9E9E9E)},
      {'label': 'Low', 'value': 64, 'color': const Color(0xFF4CAF50)},
      {'label': 'Medium', 'value': 128, 'color': const Color(0xFFFF9800)},
      {'label': 'High', 'value': 192, 'color': const Color(0xFFF44336)},
      {'label': 'Max', 'value': 255, 'color': const Color(0xFF9C27B0)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeProvider.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Presets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: presets.map((preset) {
              final isSelected = _currentLevel.round() == preset['value'];
              final color = preset['color'] as Color;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _currentLevel = (preset['value'] as int).toDouble();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withValues(alpha: 0.2)
                        : widget.themeProvider.secondaryBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? color 
                          : widget.themeProvider.borderColor,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        preset['label'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                              ? color 
                              : widget.themeProvider.textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preset['value'].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected 
                              ? color 
                              : widget.themeProvider.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    final hasChanged = _beepLevelData?.beepLevel != _currentLevel.round();
    
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasChanged && !_isSaving ? _saveBeepLevel : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: hasChanged ? 4 : 0,
        ),
        child: _isSaving
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CupertinoActivityIndicator(color: Colors.white),
                  SizedBox(width: 12),
                  Text('Saving...'),
                ],
              )
            : Text(
                hasChanged ? 'Save Beep Level' : 'No Changes',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.themeProvider.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.info_circle,
                color: widget.themeProvider.textColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Beep Level Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.themeProvider.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('Range:', '0 - 255'),
          _buildInfoRow('Current API:', '/api/buzzer/beeplevel'),
          _buildInfoRow('Storage:', 'beep_level.json'),
          _buildInfoRow('Last Updated:', 
              _beepLevelData?.timestamp.toString().split('.')[0] ?? 'Never'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: widget.themeProvider.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: widget.themeProvider.textColor,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(int level) {
    if (level == 0) {
      return const Color(0xFF9E9E9E); // Grey for muted
    } else if (level < 85) {
      return const Color(0xFF4CAF50); // Green for low
    } else if (level < 170) {
      return const Color(0xFFFF9800); // Orange for medium
    } else {
      return const Color(0xFFF44336); // Red for high
    }
  }

  String _getLevelDescription(int level) {
    if (level == 0) {
      return 'Muted';
    } else if (level < 85) {
      return 'Low';
    } else if (level < 170) {
      return 'Medium';
    } else {
      return 'High';
    }
  }
}
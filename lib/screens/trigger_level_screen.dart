import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import '../utils/cupertino_utils.dart';

class TriggerLevelScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const TriggerLevelScreen({super.key, required this.themeProvider});

  @override
  State<TriggerLevelScreen> createState() => _TriggerLevelScreenState();
}

class _TriggerLevelScreenState extends State<TriggerLevelScreen>
    with TickerProviderStateMixin {
  TriggerLevelData? _triggerLevelData;
  int _selectedTriggerValue = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasError = false;
  String _errorMessage = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _triggerOptions = [
    {
      'value': 0,
      'percentage': 0,
      'label': 'Low Trigger',
      'description': 'Trigger at 0% water level',
      'color': const Color(0xFF4CAF50),
      'icon': Icons.water_drop_outlined,
    },
    {
      'value': 33,
      'percentage': 33,
      'label': 'Medium Trigger',
      'description': 'Trigger at 33% water level',
      'color': const Color(0xFFFF9800),
      'icon': Icons.water_drop,
    },
    {
      'value': 66,
      'percentage': 66,
      'label': 'High Trigger',
      'description': 'Trigger at 66% water level',
      'color': const Color(0xFFF44336),
      'icon': Icons.water_drop_sharp,
    },
  ];

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
    
    _fetchTriggerLevel();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _fetchTriggerLevel() async {
    try {
      final triggerData = await ApiService.getTriggerLevel();
      if (mounted) {
        if (triggerData != null) {
          setState(() {
            _triggerLevelData = triggerData;
            _selectedTriggerValue = triggerData.triggerValue;
            _isLoading = false;
            _hasError = false;
            _errorMessage = '';
          });
        } else {
          setState(() {
            _isLoading = false;
            _hasError = true;
            _errorMessage = 'Failed to fetch trigger level from server. Please check if the Node.js server is running and the API endpoint /pin/V2 is accessible.';
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

  Future<void> _saveTriggerLevel() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await ApiService.setTriggerLevel(_selectedTriggerValue);
      
      if (success && mounted) {
        // Wait a moment for the API to process the change
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Refresh data to confirm the change
        await _fetchTriggerLevel();
        
        CupertinoUtils.showSuccessToast(
          context,
          'Trigger level set to ${_getSelectedOption()['percentage']}%',
        );
      } else if (mounted) {
        CupertinoUtils.showErrorToast(
          context,
          'Failed to save trigger level',
        );
      }
    } catch (e) {
      if (mounted) {
        CupertinoUtils.showErrorToast(
          context,
          'Error saving trigger level',
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

  Map<String, dynamic> _getSelectedOption() {
    return _triggerOptions.firstWhere(
      (option) => option['value'] == _selectedTriggerValue,
      orElse: () => _triggerOptions[0],
    );
  }

  Map<String, dynamic> _getCurrentOption() {
    if (_triggerLevelData == null) return _triggerOptions[0];
    return _triggerOptions.firstWhere(
      (option) => option['value'] == _triggerLevelData!.triggerValue,
      orElse: () => _triggerOptions[0],
    );
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
                                'Trigger Level',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: widget.themeProvider.textColor,
                                ),
                              ),
                              Text(
                                'Set water level trigger threshold',
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
                            // Current Trigger Display
                            _buildCurrentTriggerCard(),
                            const SizedBox(height: 24),
                            
                            // Trigger Options
                            _buildTriggerOptions(),
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
            'Loading trigger level...',
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
          const Text(
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
                _fetchTriggerLevel();
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
        ],
      ),
    );
  }

  Widget _buildCurrentTriggerCard() {
    final currentOption = _getCurrentOption();
    final color = currentOption['color'] as Color;
    
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
          // Current Trigger Icon with Animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: Icon(
                    currentOption['icon'] as IconData,
                    color: color,
                    size: 40,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 20),
          
          // Current Trigger Percentage
          Text(
            '${currentOption['percentage']}%',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Current Trigger Label
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              currentOption['label'] as String,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Description
          Text(
            currentOption['description'] as String,
            style: TextStyle(
              fontSize: 14,
              color: widget.themeProvider.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTriggerOptions() {
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
            'Select Trigger Level',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: widget.themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 16),
          
          Column(
            children: _triggerOptions.map((option) {
              final isSelected = _selectedTriggerValue == option['value'];
              final color = option['color'] as Color;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTriggerValue = option['value'] as int;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? color.withValues(alpha: 0.1)
                          : widget.themeProvider.secondaryBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? color 
                            : widget.themeProvider.borderColor,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            option['icon'] as IconData,
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
                                option['label'] as String,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected 
                                      ? color 
                                      : widget.themeProvider.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                option['description'] as String,
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
                        Text(
                          '${option['percentage']}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected 
                                ? color 
                                : widget.themeProvider.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isSelected 
                              ? CupertinoIcons.checkmark_circle_fill
                              : CupertinoIcons.circle,
                          color: isSelected 
                              ? color 
                              : widget.themeProvider.secondaryTextColor,
                          size: 20,
                        ),
                      ],
                    ),
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
    final hasChanged = _triggerLevelData?.triggerValue != _selectedTriggerValue;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasChanged && !_isSaving ? _saveTriggerLevel : null,
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
                hasChanged ? 'Save Trigger Level' : 'No Changes',
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
                'Trigger Level Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: widget.themeProvider.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildInfoRow('Available Values:', '0, 33, 66'),
          _buildInfoRow('Get API:', '/pin/V2'),
          _buildInfoRow('Set API:', '/update/V2?value={0|33|66}'),
          _buildInfoRow('Last Updated:', 
              _triggerLevelData?.timestamp.toString().split('.')[0] ?? 'Never'),
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
}
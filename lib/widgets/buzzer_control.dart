import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/api_service.dart';
import '../utils/cupertino_utils.dart';
import '../providers/theme_provider.dart';

class BuzzerControl extends StatefulWidget {
  final ThemeProvider themeProvider;

  const BuzzerControl({super.key, required this.themeProvider});

  @override
  State<BuzzerControl> createState() => _BuzzerControlState();
}

class _BuzzerControlState extends State<BuzzerControl>
    with TickerProviderStateMixin {
  bool _isBuzzerOn = false;
  bool _isLoading = false;
  Timer? _statusTimer;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
    );

    // Start monitoring buzzer status
    _startBuzzerStatusMonitoring();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _startBuzzerStatusMonitoring() {
    // Initial status check
    _checkBuzzerStatus();

    // Set up periodic monitoring every 1 second
    _statusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _checkBuzzerStatus();
    });
  }

  Future<void> _checkBuzzerStatus() async {
    try {
      final status = await ApiService.getBuzzerStatus();
      if (status != null && mounted) {
        final newStatus = status;

        // Only update if status actually changed to avoid unnecessary animations
        if (newStatus != _isBuzzerOn) {
          setState(() {
            _isBuzzerOn = newStatus;
          });

          // Trigger appropriate animations
          if (newStatus) {
            _slideController.forward();
            _pulseController.repeat(reverse: true);
          } else {
            _slideController.reverse();
            _pulseController.stop();
            _pulseController.reset();
          }
        }
      }
    } catch (e) {
      // Silently handle errors to avoid spamming logs
      // The manual control will still work even if monitoring fails
    }
  }

  Future<void> _toggleBuzzer(bool value) async {
    setState(() {
      _isLoading = true;
    });

    // Trigger slide animation
    if (value) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }

    final success = await ApiService.updateBuzzer(value);

    if (success) {
      setState(() {
        _isBuzzerOn = value;
      });

      // Trigger pulse animation when buzzer is turned on
      if (value) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }

      // Show success feedback with Cupertino toast
      if (mounted) {
        CupertinoUtils.showSuccessToast(
          context,
          'Buzzer ${value ? 'enabled' : 'disabled'}',
        );
      }
    } else {
      // Show error feedback with Cupertino toast
      if (mounted) {
        CupertinoUtils.showErrorToast(context, 'Failed to update buzzer');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildCustomSlider() {
    return GestureDetector(
      onTap: () => _toggleBuzzer(!_isBuzzerOn),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 60,
        height: 32,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _isBuzzerOn ? Colors.red : const Color(0xFF4A5568),
          boxShadow: [
            BoxShadow(
              color: _isBuzzerOn
                  ? Colors.red.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: _isBuzzerOn ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Slider thumb with smooth animation
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Positioned(
                  left: 2 + (28 * _slideAnimation.value),
                  top: 2,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isBuzzerOn
                          ? CupertinoIcons.volume_up
                          : CupertinoIcons.volume_off,
                      color: _isBuzzerOn ? Colors.red : const Color(0xFF718096),
                      size: 14,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeProvider,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.themeProvider.cardBackgroundColor,
            borderRadius: BorderRadius.circular(16),
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
              // Header
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isBuzzerOn ? _pulseAnimation.value : 1.0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _isBuzzerOn
                                ? Colors.red.withValues(alpha: 0.2)
                                : widget.themeProvider.secondaryBackgroundColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            _isBuzzerOn
                                ? CupertinoIcons.speaker_2_fill
                                : CupertinoIcons.speaker_slash,
                            color: _isBuzzerOn
                                ? Colors.red
                                : widget.themeProvider.secondaryTextColor,
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Buzzer Control',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.themeProvider.textColor,
                      ),
                    ),
                  ),
                  if (_isLoading)
                    const CupertinoActivityIndicator(color: Color(0xFF667eea))
                  else
                    _buildCustomSlider(),
                ],
              ),

              const SizedBox(height: 20),

              // Status indicator
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: widget.themeProvider.secondaryBackgroundColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _isBuzzerOn
                            ? Colors.red
                            : widget.themeProvider.secondaryTextColor,
                        shape: BoxShape.circle,
                        boxShadow: _isBuzzerOn
                            ? [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _isBuzzerOn
                          ? 'Buzzer is currently ON'
                          : 'Buzzer is currently OFF',
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.themeProvider.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                _isBuzzerOn
                    ? 'The alarm system is active and will sound when triggered'
                    : 'The alarm system is disabled and will not sound',
                style: TextStyle(
                  fontSize: 14,
                  color: widget.themeProvider.secondaryTextColor,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/water_tank_data.dart';
import '../providers/theme_provider.dart';

class WaterLevelIndicator extends StatefulWidget {
  final WaterTankData? waterData;
  final ThemeProvider themeProvider;

  const WaterLevelIndicator({
    super.key, 
    required this.waterData, 
    required this.themeProvider,
  });

  @override
  State<WaterLevelIndicator> createState() => _WaterLevelIndicatorState();
}

class _WaterLevelIndicatorState extends State<WaterLevelIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void didUpdateWidget(WaterLevelIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.waterData?.waterLevel != widget.waterData?.waterLevel) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.themeProvider,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: widget.themeProvider.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
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
              // Header with icon and percentage
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getWaterColor(widget.waterData?.waterLevel ?? 0)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.water_drop,
                      color: _getWaterColor(widget.waterData?.waterLevel ?? 0),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Water Level',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.themeProvider.secondaryTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.waterData?.waterLevelText ?? 'Loading...',
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.themeProvider.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    widget.waterData != null ? '${widget.waterData!.waterLevel}%' : '0%',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getWaterColor(widget.waterData?.waterLevel ?? 0),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Horizontal progress bar
              Column(
                children: [
                  // Level markers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildLevelMarker('0%', widget.waterData?.waterLevel == 0),
                      _buildLevelMarker('25%', (widget.waterData?.waterLevel ?? 0) >= 25),
                      _buildLevelMarker('50%', (widget.waterData?.waterLevel ?? 0) >= 50),
                      _buildLevelMarker('75%', (widget.waterData?.waterLevel ?? 0) >= 75),
                      _buildLevelMarker('100%', widget.waterData?.waterLevel == 100),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Water tank container (broader and taller)
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: widget.themeProvider.secondaryBackgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.themeProvider.borderColor,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          // Water fill animation (horizontal)
                          AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              final progress = widget.waterData != null 
                                  ? (widget.waterData!.waterLevel / 100) * _animation.value
                                  : 0.0;
                              
                              final waterColor = _getWaterColor(widget.waterData?.waterLevel ?? 0);
                              
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 1200),
                                curve: Curves.easeInOut,
                                width: MediaQuery.of(context).size.width * progress,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      waterColor.withValues(alpha: 0.6),
                                      waterColor.withValues(alpha: 0.8),
                                      waterColor,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: waterColor.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(2, 0),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // Water wave effect
                                    if (progress > 0)
                                      Positioned(
                                        top: -10,
                                        left: 0,
                                        right: 0,
                                        child: AnimatedBuilder(
                                          animation: _animation,
                                          builder: (context, child) {
                                            return Container(
                                              height: 20,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: [
                                                    Colors.white.withValues(alpha: 0.3),
                                                    Colors.white.withValues(alpha: 0.1),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    
                                    // Shimmer effect on water surface
                                    if (progress > 0)
                                      Positioned(
                                        top: 0,
                                        left: 0,
                                        right: 0,
                                        child: AnimatedBuilder(
                                          animation: _animation,
                                          builder: (context, child) {
                                            return Container(
                                              height: 4,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.white.withValues(alpha: 0.0),
                                                    Colors.white.withValues(alpha: 0.6),
                                                    Colors.white.withValues(alpha: 0.0),
                                                  ],
                                                  stops: [
                                                    0.0,
                                                    (_animation.value * 0.8) + 0.1,
                                                    1.0,
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                          
                          // Water level percentage overlay
                          if (widget.waterData != null && widget.waterData!.waterLevel > 0)
                            Positioned(
                              right: 16,
                              bottom: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${widget.waterData!.waterLevel}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getWaterColor(widget.waterData!.waterLevel),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Get water color based on level (red to green gradient)
  Color _getWaterColor(int level) {
    if (level == 0) {
      return const Color(0xFFE53E3E); // Red - Empty
    } else if (level <= 25) {
      return const Color(0xFFFF6B6B); // Light Red - Very Low
    } else if (level <= 50) {
      return const Color(0xFFFF9500); // Orange - Low
    } else if (level <= 75) {
      return const Color(0xFFFFD60A); // Yellow - Medium
    } else if (level < 100) {
      return const Color(0xFF30D158); // Light Green - High
    } else {
      return const Color(0xFF34C759); // Green - Full
    }
  }

  Widget _buildLevelMarker(String label, bool isActive) {
    final markerLevel = int.parse(label.replaceAll('%', ''));
    final markerColor = _getWaterColor(markerLevel);
    
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive 
                ? markerColor
                : widget.themeProvider.borderColor,
            shape: BoxShape.circle,
            boxShadow: isActive ? [
              BoxShadow(
                color: markerColor.withValues(alpha: 0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ] : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isActive 
                ? widget.themeProvider.textColor
                : widget.themeProvider.secondaryTextColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class RadialGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  RadialGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    
    // Background arc
    final backgroundPaint = Paint()
      ..color = const Color(0xFF4A5568)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      backgroundPaint,
    );
    
    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withValues(alpha: 0.7),
            color,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate is RadialGaugePainter &&
        (oldDelegate.progress != progress || oldDelegate.color != color);
  }
}
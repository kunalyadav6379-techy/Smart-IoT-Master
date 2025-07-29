import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';

class NodeMCUPinsScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const NodeMCUPinsScreen({super.key, required this.themeProvider});

  @override
  State<NodeMCUPinsScreen> createState() => _NodeMCUPinsScreenState();
}

class _NodeMCUPinsScreenState extends State<NodeMCUPinsScreen>
    with TickerProviderStateMixin {
  List<DigitalPinData> _digitalPins = [];
  List<DigitalPinData> _lastValidPins = []; // Cache for last valid data
  Timer? _pinsUpdateTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isLoading = true;
  int _failedAttempts = 0;
  DateTime? _lastSuccessfulUpdate;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _fetchDigitalPins();
    _startDigitalPinsMonitoring();
  }

  @override
  void dispose() {
    _pinsUpdateTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startDigitalPinsMonitoring() {
    _pinsUpdateTimer?.cancel(); // Cancel any existing timer
    _pinsUpdateTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _fetchDigitalPins();
      } else {
        timer.cancel(); // Cancel timer if widget is no longer mounted
      }
    });
  }

  Future<void> _fetchDigitalPins() async {
    try {
      final pins = await ApiService.getAllDigitalPins();
      if (mounted && pins.isNotEmpty) {
        setState(() {
          _digitalPins = pins;
          _lastValidPins = List.from(pins); // Cache the valid data
          _isLoading = false;
          _failedAttempts = 0;
          _lastSuccessfulUpdate = DateTime.now();
        });
        print('🔌 NodeMCU: Successfully fetched ${pins.length} pins');
      } else if (mounted && pins.isEmpty && _lastValidPins.isNotEmpty) {
        // If API returns empty but we have cached data, use cached data
        setState(() {
          _digitalPins = _lastValidPins;
          _failedAttempts++;
          _isLoading = false;
        });
        print('🔌 NodeMCU: API returned empty, using cached data (attempt $_failedAttempts)');
      }
    } catch (e) {
      if (mounted) {
        _failedAttempts++;
        print('🔌 NodeMCU: Error fetching pins (attempt $_failedAttempts): $e');
        
        // If we have cached data and haven't failed too many times, use cached data
        if (_lastValidPins.isNotEmpty && _failedAttempts < 10) {
          setState(() {
            _digitalPins = _lastValidPins;
            _isLoading = false;
          });
          print('🔌 NodeMCU: Using cached data due to API error');
        } else {
          setState(() {
            _isLoading = false;
          });
        }
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
                                'NodeMCU Pin Status',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: widget.themeProvider.textColor,
                                ),
                              ),
                              Text(
                                'Real-time digital pins monitoring',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: widget.themeProvider.secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Refresh button
                        GestureDetector(
                          onTap: () {
                            _fetchDigitalPins();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(right: 8),
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
                              CupertinoIcons.refresh,
                              color: widget.themeProvider.textColor,
                              size: 20,
                            ),
                          ),
                        ),
                        // Status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _getStatusText(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _getStatusColor(),
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
                          // Info Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF667eea).withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  CupertinoIcons.device_phone_portrait,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'NodeMCU ESP8266',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Monitoring ${_digitalPins.length} digital pins',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildQuickStat('Update Rate', '2s'),
                                    _buildQuickStat('Pins Active', '${_digitalPins.where((p) => p.isHigh).length}'),
                                    _buildQuickStat('Total Pins', '3'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          // Digital Pins
                          if (_isLoading)
                            _buildLoadingCard()
                          else
                            ..._digitalPins.map((pin) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _buildDigitalPinCard(pin),
                            )),
                          
                          const SizedBox(height: 24),
                          
                          // API Endpoints Info
                          _buildEndpointsCard(),
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

  Widget _buildQuickStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
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
            'Loading digital pins status...',
            style: TextStyle(
              fontSize: 16,
              color: widget.themeProvider.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitalPinCard(DigitalPinData pin) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.themeProvider.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              // Pin icon with animation for HIGH state
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: pin.isHigh ? _pulseAnimation.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: pin.stateColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: pin.isHigh ? [
                          BoxShadow(
                            color: pin.stateColor.withValues(alpha: 0.4),
                            blurRadius: 12,
                            spreadRadius: 3,
                          ),
                        ] : null,
                      ),
                      child: Icon(
                        pin.stateIcon,
                        color: pin.stateColor,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 20),
              
              // Pin info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pin.digitalPin,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: widget.themeProvider.textColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            pin.pin,
                            style: TextStyle(
                              fontSize: 12,
                              color: widget.themeProvider.secondaryTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NodeMCU Digital Pin',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.themeProvider.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              // State indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: pin.stateColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: pin.stateColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Text(
                  pin.stateText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: pin.stateColor,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Pin details
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.themeProvider.secondaryBackgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Endpoint',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.themeProvider.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'http://pizero.local:5001/pin/${pin.pin}',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.themeProvider.textColor,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Last Update',
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.themeProvider.secondaryTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getLastUpdateText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.themeProvider.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndpointsCard() {
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
                CupertinoIcons.link,
                color: widget.themeProvider.textColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'API Endpoints',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.themeProvider.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEndpointItem('D5 Pin', 'http://pizero.local:5001/pin/V5'),
          _buildEndpointItem('D6 Pin', 'http://pizero.local:5001/pin/V6'),
          _buildEndpointItem('D7 Pin', 'http://pizero.local:5001/pin/V7'),
        ],
      ),
    );
  }

  Widget _buildEndpointItem(String name, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF667eea),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.themeProvider.textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  url,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.themeProvider.secondaryTextColor,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for status indicator
  Color _getStatusColor() {
    if (_failedAttempts == 0 && _lastSuccessfulUpdate != null) {
      final timeSinceUpdate = DateTime.now().difference(_lastSuccessfulUpdate!);
      if (timeSinceUpdate.inSeconds < 10) {
        return Colors.green; // Live - recent successful update
      }
    }
    
    if (_failedAttempts > 0 && _failedAttempts < 5) {
      return Colors.orange; // Warning - some failures but using cached data
    }
    
    return Colors.red; // Error - too many failures or no data
  }

  String _getStatusText() {
    if (_failedAttempts == 0 && _lastSuccessfulUpdate != null) {
      final timeSinceUpdate = DateTime.now().difference(_lastSuccessfulUpdate!);
      if (timeSinceUpdate.inSeconds < 10) {
        return 'Live';
      }
    }
    
    if (_failedAttempts > 0 && _failedAttempts < 5) {
      return 'Cached';
    }
    
    return 'Error';
  }

  String _getLastUpdateText() {
    if (_lastSuccessfulUpdate == null) {
      return 'Never';
    }
    
    final now = DateTime.now();
    final difference = now.difference(_lastSuccessfulUpdate!);
    
    if (difference.inSeconds < 10) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}
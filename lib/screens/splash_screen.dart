// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  double _progress = 0.0; // progression en %
  late Timer _progressTimer;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  // Couleur fixe : bleu
  final Color navyBlue = const Color.fromARGB(255, 59, 44, 196);

  @override
  void initState() {
    super.initState();

    // Animation lente (10s)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotationAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startProgress();
  }

  void _startProgress() {
    // Pour atteindre 100% en 30 secondes
    const totalDuration = 10; // secondes
    const tick = Duration(milliseconds: 50);
    final increment = 100 / (totalDuration * 1000 / tick.inMilliseconds);

    _progressTimer = Timer.periodic(tick, (timer) {
      if (mounted) {
        setState(() {
          _progress += increment;
          if (_progress >= 100) {
            _progress = 100;
            _progressTimer.cancel();
            _checkAuthStatus(); // navigation après 30s
          }
        });
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    if (!mounted) return;

    final authService = Provider.of<AuthService>(context, listen: false);

    if (authService.isAuthenticated && authService.currentVendor != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    _progressTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond de page blanc
      body: Stack(
        children: [
          // Vague en haut gauche
          Positioned(
            top: -150,
            left: -150,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    50 * sin(_controller.value * 2 * pi),
                    50 * cos(_controller.value * 2 * pi),
                  ),
                  child: _waveCircle(300, navyBlue),
                );
              },
            ),
          ),

          // Vague en bas droite
          Positioned(
            bottom: -150,
            right: -150,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    50 * cos(_controller.value * 2 * pi),
                    50 * sin(_controller.value * 2 * pi),
                  ),
                  child: _waveCircle(340, navyBlue),
                );
              },
            ),
          ),

          // Logo central avec progression
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: CircularProgressIndicator(
                        value: _progress / 100,
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation(navyBlue),
                        backgroundColor: navyBlue,
                      ),
                    ),
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.shopping_bag_rounded,
                            size: 60,
                            color: Color.fromARGB(255, 25, 47, 242),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '${_progress.toInt()} %',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: navyBlue,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Live Commerce',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: navyBlue,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Achetez & vendez en direct',
                  style: TextStyle(fontSize: 15, color: navyBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _waveCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

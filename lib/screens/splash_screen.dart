// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _currentDot = 0;
  late Timer _dotTimer;

  @override
  void initState() {
    super.initState();
    _startDotAnimation();
    _checkAuthStatus();
  }

  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _currentDot = (_currentDot + 1) % 4; // 0,1,2,3 puis 0...
        });
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    // Attendre 2 secondes pour l'animation
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Accéder au AuthService depuis le Provider
      final authService = Provider.of<AuthService>(context, listen: false);

      if (mounted) {
        if (authService.isAuthenticated && authService.currentVendor != null) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/login');
        }
      }
    } catch (e) {
      // En cas d'erreur, rediriger vers login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _dotTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo avec animation subtile
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.storefront,
                size: 50,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 30),

            // Titre
            const Text(
              'Live Commerce',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Plateforme E-commerce',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            // Animation des 3 points (style Facebook moderne)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                bool isActive = false;

                // Logique d'animation:
                // Dot 0: actif aux positions 0
                // Dot 1: actif aux positions 1
                // Dot 2: actif aux positions 2
                // Dot 3: aucun actif (pause)
                if (_currentDot < 3) {
                  isActive = index == _currentDot;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),

            const SizedBox(height: 10),

            // Texte de chargement
            Text(
              _currentDot < 3
                  ? 'Chargement${'.' * (_currentDot + 1)}'
                  : 'Presque terminé',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

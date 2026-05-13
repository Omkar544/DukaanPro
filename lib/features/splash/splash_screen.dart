import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../data/services/auth_repository.dart';
import '../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1. Animation controller for the bubble movement
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _navigateToNext();
  }

  _navigateToNext() async {
    // Increased to 3 seconds to let the animation shine
    await Future.delayed(const Duration(seconds: 3));

    final authRepo = AuthRepository();
    bool isRegistered = await authRepo.isShopRegistered();

    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        isRegistered ? AppRoutes.login : AppRoutes.register,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background base color
      backgroundColor: const Color(0xFF12B8C4),
      body: Stack(
        children: [
          // 2. The Floating Bubbles (Particle Layer)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: BubblePainter(_controller.value),
                size: Size.infinite,
              );
            },
          ),

          // 3. Fire-like Bottom Glow
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.orange.withOpacity(0.4),
                    Colors.red.withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 4. Logo and Spinner
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Entrance for Logo
                TweenAnimationBuilder(
                  duration: const Duration(milliseconds: 1500),
                  tween: Tween<double>(begin: 0, end: 1),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    );
                  },
                  child: Image.asset('assets/images/app_logo.png', width: 180),
                ),
                const SizedBox(height: 40),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 5. Custom Painter for CSS-style bubble animation
class BubblePainter extends CustomPainter {
  final double animationValue;
  BubblePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    // Use a fixed seed so bubbles don't jump on every frame
    final random = Random(5); 

    for (int i = 0; i < 20; i++) {
      // Logic to make bubbles float from bottom to top
      double x = random.nextDouble() * size.width;
      double speed = random.nextDouble() * 0.5 + 0.5;
      double y = (size.height - (animationValue * size.height * speed)) % size.height;
      double radius = random.nextDouble() * 30 + 5;

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
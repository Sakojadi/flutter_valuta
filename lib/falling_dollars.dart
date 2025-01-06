import 'package:flutter/material.dart';
import 'dart:math';

class FallingDollarsBackground extends StatefulWidget {
  final int maxDollars; // Maximum number of dollars at once
  const FallingDollarsBackground({Key? key, this.maxDollars = 50})
      : super(key: key);

  @override
  _FallingDollarsBackgroundState createState() =>
      _FallingDollarsBackgroundState();
}

class _FallingDollarsBackgroundState extends State<FallingDollarsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Dollar> _dollars = [];
  final Random _random = Random();
  int _activeDollars = 0; // Track the number of currently falling dollars

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), // Slow animation
    )..repeat();

    // Schedule dollar generation at intervals
    _generateDollars();
  }

  void _generateDollars() async {
    while (true) {
      // Add 2-5 dollars at the top every 10 seconds
      final newDollarsCount = _random.nextInt(4) + 2; // Generate 2-5 dollars
      if (_activeDollars + newDollarsCount <= widget.maxDollars) {
        setState(() {
          for (int i = 0; i < newDollarsCount; i++) {
            _dollars.add(
              _Dollar(
                startX: _random.nextDouble(), // Random horizontal position
                speed: _random.nextDouble() * 0.5 + 0.1, // Moderate speed (0.1 to 0.6)
                startY: 0.0, // Always start at the top
              ),
            );
          }
          _activeDollars += newDollarsCount;
        });
      }

      // Wait for 10 seconds before generating more dollars
      await Future.delayed(const Duration(seconds: 10));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _DollarPainter(
            dollars: _dollars,
            progress: _controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _Dollar {
  final double startX; // Relative horizontal start position (0.0 to 1.0)
  final double speed; // Speed of falling
  final double startY; // Initial vertical offset

  _Dollar({required this.startX, required this.speed, required this.startY});
}

class _DollarPainter extends CustomPainter {
  final List<_Dollar> dollars;
  final double progress;

  _DollarPainter({required this.dollars, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '\u0024', // Dollar sign
        style: TextStyle(
          color: Colors.teal,
          fontSize: 24,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    final List<_Dollar> toRemove = [];
    for (var dollar in dollars) {
      // Calculate position based on progress and speed
      final dy = ((progress * size.height * dollar.speed) +
              (dollar.startY * size.height)) %
          size.height;
      final dx = dollar.startX * size.width;

      if (dy > size.height) {
        toRemove.add(dollar);
      }

      // Draw glow effect
      canvas.drawCircle(
        Offset(dx + 12, dy + 12), // Offset to center glow behind text
        16, // Glow radius
        Paint()
          ..color = Colors.teal.withOpacity(0.6)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10),
      );

      // Draw the dollar sign
      textPainter.layout();
      textPainter.paint(canvas, Offset(dx, dy));
    }

    // Remove dollars that have fallen off-screen
    for (var dollar in toRemove) {
      dollars.remove(dollar);
    }

    // Update active dollar count
    dollars.removeWhere((dollar) => toRemove.contains(dollar));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class ConfettiCelebration extends StatefulWidget {
  final Widget child;
  final bool autoPlay;

  const ConfettiCelebration({
    super.key,
    required this.child,
    this.autoPlay = true,
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    );

    if (widget.autoPlay) {
      _spawnParticles();
      _controller.forward();
    }
  }

  void _spawnParticles() {
    _particles.clear();
    const int count = 90;
    final colors = [
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFFEC4899), // Rose Pink
      const Color(0xFF10B981), // Emerald
      const Color(0xFFF59E0B), // Amber Gold
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEF4444), // Crimson
    ];

    for (int i = 0; i < count; i++) {
      final color = colors[_random.nextInt(colors.length)];
      final double startX = 0.5 + (_random.nextDouble() - 0.5) * 0.4;
      final double startY = 0.15 + (_random.nextDouble() - 0.5) * 0.1;
      final double angle =
          (_random.nextDouble() * math.pi * 1.4) + (math.pi * 0.8);
      final double speed = 350 + _random.nextDouble() * 500;
      final double rotationSpeed = (_random.nextDouble() - 0.5) * 12;
      final double size = 6 + _random.nextDouble() * 8;
      final _ParticleShape shape =
          _ParticleShape.values[_random.nextInt(_ParticleShape.values.length)];

      _particles.add(
        _ConfettiParticle(
          x: startX,
          y: startY,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          color: color,
          size: size,
          rotation: _random.nextDouble() * 2 * math.pi,
          rotationSpeed: rotationSpeed,
          shape: shape,
          flutterSpeed: 3 + _random.nextDouble() * 5,
        ),
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
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (!_controller.isAnimating && _controller.isCompleted) {
                  return const SizedBox.shrink();
                }
                return CustomPaint(
                  painter: _ConfettiPainter(
                    particles: _particles,
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

enum _ParticleShape { rectangle, circle, star, ribbon }

class _ConfettiParticle {
  final double x;
  final double y;
  final double vx;
  final double vy;
  final Color color;
  final double size;
  final double rotation;
  final double rotationSpeed;
  final _ParticleShape shape;
  final double flutterSpeed;

  _ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.rotation,
    required this.rotationSpeed,
    required this.shape,
    required this.flutterSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const double gravity = 800; // pixels / s^2
    final double time = progress * 3.2; // seconds

    for (final p in particles) {
      // Physics position
      final double posX =
          p.x * size.width +
          p.vx * time * 0.8 +
          math.sin(time * p.flutterSpeed) * 30;
      final double posY =
          p.y * size.height + (p.vy * time) + (0.5 * gravity * time * time);

      // Fade out towards end
      final double opacity = (1.0 - math.pow(progress, 2.5))
          .clamp(0.0, 1.0)
          .toDouble();
      if (opacity <= 0 ||
          posY > size.height + 50 ||
          posX < -50 ||
          posX > size.width + 50) {
        continue;
      }

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(posX, posY);
      canvas.rotate(p.rotation + p.rotationSpeed * time);

      switch (p.shape) {
        case _ParticleShape.rectangle:
          final double w = p.size;
          final double h =
              p.size * (0.6 + 0.4 * math.sin(time * p.flutterSpeed));
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: w, height: h),
              const Radius.circular(2),
            ),
            paint,
          );
          break;

        case _ParticleShape.circle:
          canvas.drawCircle(Offset.zero, p.size * 0.45, paint);
          break;

        case _ParticleShape.ribbon:
          final double w = p.size * 1.8;
          final double h =
              p.size * 0.35 * (0.5 + 0.5 * math.cos(time * p.flutterSpeed));
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: w, height: h),
            paint,
          );
          break;

        case _ParticleShape.star:
          _drawStar(canvas, paint, p.size * 0.5);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, Paint paint, double radius) {
    final path = Path();
    const int points = 5;
    final double innerRadius = radius * 0.45;
    double rot = math.pi / 2 * 3;
    final double step = math.pi / points;

    path.moveTo(math.cos(rot) * radius, math.sin(rot) * radius);
    for (int i = 0; i < points; i++) {
      path.lineTo(math.cos(rot) * radius, math.sin(rot) * radius);
      rot += step;
      path.lineTo(math.cos(rot) * innerRadius, math.sin(rot) * innerRadius);
      rot += step;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

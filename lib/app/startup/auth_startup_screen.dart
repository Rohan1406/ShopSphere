import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/features/auth/controllers/auth_controller.dart';

class AuthStartupScreen extends ConsumerStatefulWidget {
  const AuthStartupScreen({super.key});

  @override
  ConsumerState<AuthStartupScreen> createState() => _AuthStartupScreenState();
}

class _AuthStartupScreenState extends ConsumerState<AuthStartupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _pulseController;
  late final AnimationController _shimmerController;

  // Staggered Entrance Animations
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoRotation;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<Offset> _badgeSlide;
  late final Animation<double> _badgeFade;
  late final Animation<double> _sparkleScale;
  late final Animation<double> _loadingFade;

  // Continuous Pulse / Breathe Animations
  late final Animation<double> _pulseGlow;
  late final Animation<double> _floatingOffset;

  // Brand Name Characters: 'S','h','o','p','S','p','h','e','r','e'
  static const String _brandPrefix = 'Shop';
  static const String _brandSuffix = 'Sphere';
  static const String _fullBrandName = 'ShopSphere';

  final List<Animation<double>> _letterScales = [];
  final List<Animation<Offset>> _letterSlides = [];
  final List<Animation<double>> _letterFades = [];

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (2600ms for a majestic presentation)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // Logo entrance
    _logoScale = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.12, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic),
      ),
    );

    // Staggered Character Animations for 'ShopSphere' (10 letters)
    final totalLetters = _fullBrandName.length;
    for (int i = 0; i < totalLetters; i++) {
      // Stagger start time from 0.25 to 0.70
      final start = 0.25 + (i * 0.045);
      final end = (start + 0.28).clamp(0.0, 1.0);

      _letterScales.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(start, end, curve: Curves.easeOutBack),
          ),
        ),
      );

      _letterSlides.add(
        Tween<Offset>(begin: const Offset(0.0, 0.8), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );

      _letterFades.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Interval(
              start,
              (start + 0.15).clamp(0.0, 1.0),
              curve: Curves.easeIn,
            ),
          ),
        ),
      );
    }

    // Sparkle star after letters appear
    _sparkleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.70, 0.95, curve: Curves.elasticOut),
      ),
    );

    // Subtitle slide & fade
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0.0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.60, 0.88, curve: Curves.easeOutCubic),
          ),
        );

    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.60, 0.85, curve: Curves.easeIn),
      ),
    );

    // Badge slide & fade
    _badgeSlide = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.70, 0.95, curve: Curves.easeOutCubic),
          ),
        );

    _badgeFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.70, 0.92, curve: Curves.easeIn),
      ),
    );

    // Loading indicator fade
    _loadingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.80, 1.0, curve: Curves.easeIn),
      ),
    );

    // 2. Infinite gentle pulse & float loop
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseGlow = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatingOffset = Tween<double>(begin: -5.0, end: 5.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Continuous Shimmer / Sheen sweep across the brand name
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();

    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        ref.read(authControllerProvider.notifier).restoreSession();
      }
    });

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background rich dark luxury gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF090D16),
                  Color(0xFF0F172A),
                  Color(0xFF1E1B4B),
                  Color(0xFF111827),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Ambient Glowing Background Circles
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned(
                    top: -60,
                    right: -60,
                    child: Container(
                      width: 280 * _pulseGlow.value,
                      height: 280 * _pulseGlow.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.18),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80,
                    left: -80,
                    child: Container(
                      width: 300 * (2.0 - _pulseGlow.value),
                      height: 300 * (2.0 - _pulseGlow.value),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.secondary.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Foreground Content
          SafeArea(
            child: SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),

                  // Animated Floating Brand Logo
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _entranceController,
                      _pulseController,
                    ]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatingOffset.value),
                        child: Transform.rotate(
                          angle: _logoRotation.value * math.pi,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoFade.value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Pulsing Glow Aura
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            return Container(
                              width: 124 * _pulseGlow.value,
                              height: 124 * _pulseGlow.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withValues(
                                  alpha: 0.25,
                                ),
                              ),
                            );
                          },
                        ),

                        // 3D Glass / Gradient Logo Box
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF6366F1),
                                Color(0xFF4338CA),
                                Color(0xFF312E81),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.28),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.65,
                                ),
                                blurRadius: 36,
                                spreadRadius: 2,
                                offset: const Offset(0, 12),
                              ),
                              BoxShadow(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 22,
                                offset: const Offset(-4, -4),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Subtle shine overlay
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                height: 50,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(28),
                                    ),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.white.withValues(alpha: 0.25),
                                        Colors.white.withValues(alpha: 0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              // Brand Icon
                              const Icon(
                                Icons.shopping_bag_rounded,
                                size: 52,
                                color: Colors.white,
                              ),
                              // Sparkle accent
                              const Positioned(
                                top: 16,
                                right: 16,
                                child: Icon(
                                  Icons.auto_awesome,
                                  size: 16,
                                  color: Color(0xFFFDE047),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ==========================================
                  // ANIMATED "ShopSphere" BRAND NAME DISPLAY
                  // ==========================================
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _entranceController,
                      _shimmerController,
                    ]),
                    builder: (context, _) {
                      return Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Letter-by-letter animated character row
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // "Shop" Letters (Prefix)
                              ...List.generate(_brandPrefix.length, (index) {
                                return _buildAnimatedCharacter(
                                  char: _brandPrefix[index],
                                  scaleAnim: _letterScales[index],
                                  slideAnim: _letterSlides[index],
                                  fadeAnim: _letterFades[index],
                                  isGradient: false,
                                );
                              }),

                              // "Sphere" Letters (Suffix with glowing gradient)
                              ...List.generate(_brandSuffix.length, (index) {
                                final charIndex = _brandPrefix.length + index;
                                return _buildAnimatedCharacter(
                                  char: _brandSuffix[index],
                                  scaleAnim: _letterScales[charIndex],
                                  slideAnim: _letterSlides[charIndex],
                                  fadeAnim: _letterFades[charIndex],
                                  isGradient: true,
                                );
                              }),
                            ],
                          ),

                          // Sparkling star popping at the top-right of the name
                          Positioned(
                            top: -12,
                            right: -16,
                            child: ScaleTransition(
                              scale: _sparkleScale,
                              child: Transform.rotate(
                                angle: (_pulseController.value * 0.3) * math.pi,
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFFFACC15),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Animated Tagline
                  SlideTransition(
                    position: _subtitleSlide,
                    child: FadeTransition(
                      opacity: _subtitleFade,
                      child: const Text(
                        'CURATED LUXURY & SMART SHOPPING',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                          letterSpacing: 2.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Animated Feature Badge
                  SlideTransition(
                    position: _badgeSlide,
                    child: FadeTransition(
                      opacity: _badgeFade,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.accentLight,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Premium Lifestyle Hub',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 3),

                  // Bottom Loading Spinner & Version Info
                  FadeTransition(
                    opacity: _loadingFade,
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Version 2.0 • Experience the Future',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
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

  /// Builds a single animated character with staggered bounce, slide, and luxury styling
  Widget _buildAnimatedCharacter({
    required String char,
    required Animation<double> scaleAnim,
    required Animation<Offset> slideAnim,
    required Animation<double> fadeAnim,
    required bool isGradient,
  }) {
    // Dynamic light shimmer calculation
    final shimmerPos = _shimmerController.value;

    return SlideTransition(
      position: slideAnim,
      child: ScaleTransition(
        scale: scaleAnim,
        child: FadeTransition(
          opacity: fadeAnim,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0.5),
            child: isGradient
                ? ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: const [
                          Color(0xFF818CF8),
                          Color(0xFFC084FC),
                          Color(0xFFF472B6),
                          Color(0xFF67E8F9),
                        ],
                        stops: const [0.0, 0.35, 0.7, 1.0],
                        transform: GradientRotation(shimmerPos * 2 * math.pi),
                      ).createShader(bounds);
                    },
                    child: Text(
                      char,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0x80818CF8),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  )
                : ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) {
                      final shimmerCenter = (shimmerPos * 3.0) - 1.0;
                      return LinearGradient(
                        colors: const [
                          Colors.white,
                          Color(0xFFE0E7FF),
                          Colors.white,
                        ],
                        stops: [
                          (shimmerCenter - 0.3).clamp(0.0, 1.0),
                          shimmerCenter.clamp(0.0, 1.0),
                          (shimmerCenter + 0.3).clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      char,
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Color(0x60FFFFFF),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

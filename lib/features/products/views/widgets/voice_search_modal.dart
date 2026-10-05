import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shopsphere/app/theme/app_colors.dart';
import 'package:shopsphere/core/mock/dummy_data.dart';

/// Interactive Voice Search Simulation Modal with animated soundwaves and speech recognition demo.
class VoiceSearchModal extends StatefulWidget {
  const VoiceSearchModal({required this.onQueryRecognized, super.key});

  final ValueChanged<String> onQueryRecognized;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onQueryRecognized,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          VoiceSearchModal(onQueryRecognized: onQueryRecognized),
    );
  }

  @override
  State<VoiceSearchModal> createState() => _VoiceSearchModalState();
}

class _VoiceSearchModalState extends State<VoiceSearchModal>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  Timer? _simulationTimer;
  Timer? _typingTimer;

  String _statusMessage = 'Listening... Speak now';
  String _recognizedQuery = '';
  bool _isListening = true;
  bool _isRecognized = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Default simulation: after 2.8s auto-simulate recognizing a random popular search query
    _startDefaultSimulation();
  }

  void _startDefaultSimulation() {
    _simulationTimer?.cancel();
    _typingTimer?.cancel();

    _simulationTimer = Timer(const Duration(milliseconds: 2200), () {
      if (!mounted || !_isListening) return;
      final prompts = List<String>.from(DummyData.voiceSearchPrompts)
        ..shuffle();
      final sample = prompts.first;
      _simulateVoiceInput(sample);
    });
  }

  void _simulateVoiceInput(String phrase) {
    _simulationTimer?.cancel();
    _typingTimer?.cancel();

    setState(() {
      _isListening = true;
      _isRecognized = false;
      _recognizedQuery = '';
      _statusMessage = 'Transcribing speech...';
    });

    int index = 0;
    _typingTimer = Timer.periodic(const Duration(milliseconds: 70), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (index < phrase.length) {
        setState(() {
          _recognizedQuery = phrase.substring(0, index + 1);
        });
        index++;
      } else {
        timer.cancel();
        setState(() {
          _isListening = false;
          _isRecognized = true;
          _statusMessage = 'Search query recognized!';
        });

        // Auto submit after brief pause
        Timer(const Duration(milliseconds: 900), () {
          if (mounted) {
            widget.onQueryRecognized(_recognizedQuery);
            Navigator.of(context).pop();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _typingTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.mic_rounded,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Voice Search (AI Simulation)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Close',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Pulsating Animated Microphone Visualizer
            Center(
              child: GestureDetector(
                onTap: () {
                  if (!_isListening) {
                    setState(() {
                      _isListening = true;
                      _isRecognized = false;
                      _recognizedQuery = '';
                      _statusMessage = 'Listening... Speak now';
                    });
                    _startDefaultSimulation();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer expanding pulse ring 2
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseController.value * 0.6);
                        final opacity = (1.0 - _pulseController.value).clamp(
                          0.0,
                          1.0,
                        );
                        return Transform.scale(
                          scale: _isListening ? scale : 1.0,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(
                                alpha: _isListening ? opacity * 0.18 : 0.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Outer expanding pulse ring 1
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseController.value * 0.35);
                        final opacity = (1.0 - _pulseController.value).clamp(
                          0.0,
                          1.0,
                        );
                        return Transform.scale(
                          scale: _isListening ? scale : 1.0,
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(
                                alpha: _isListening ? opacity * 0.3 : 0.0,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Main Core Mic Button
                    Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _isRecognized
                            ? AppColors.emeraldGradient
                            : AppColors.primaryGradient,
                        boxShadow: [
                          BoxShadow(
                            color:
                                (_isRecognized
                                        ? AppColors.success
                                        : AppColors.primary)
                                    .withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecognized ? Icons.check_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Animated Audio Waveform Bars
            if (_isListening)
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(7, (index) {
                      final factor = math
                          .sin(
                            (_waveController.value * math.pi) + (index * 0.5),
                          )
                          .abs();
                      final height = 8.0 + (factor * 22.0);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                        width: 4,
                        height: height,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                            alpha: 0.4 + (factor * 0.6),
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }),
                  );
                },
              ),
            const SizedBox(height: 14),

            // Status & Recognized Query
            Text(
              _statusMessage,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _isRecognized
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),

            // Speech Preview Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isRecognized
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.borderLight,
                ),
              ),
              child: Text(
                _recognizedQuery.isNotEmpty
                    ? '"$_recognizedQuery"'
                    : 'Say something like "Sony Headphones" or tap below...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: _recognizedQuery.isNotEmpty
                      ? FontWeight.w700
                      : FontWeight.normal,
                  color: _recognizedQuery.isNotEmpty
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontStyle: _recognizedQuery.isNotEmpty
                      ? FontStyle.normal
                      : FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Quick Simulation Prompt Chips
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Or tap a prompt to test simulated voice recognition:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPromptChip('🎧 Sony Headphones'),
                _buildPromptChip('👟 Nike Air Max'),
                _buildPromptChip('⌚ Apple Watch'),
                _buildPromptChip('⌨️ Mechanical Keyboard'),
                _buildPromptChip('🕶️ Polarized Sunglasses'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    final cleanQuery = text.replaceAll(RegExp(r'^[^\w]+'), '').trim();
    return ActionChip(
      avatar: const Icon(Icons.record_voice_over_rounded, size: 14),
      label: Text(text),
      labelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      backgroundColor: AppColors.surfaceSubtle,
      side: const BorderSide(color: AppColors.borderLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onPressed: () => _simulateVoiceInput(cleanQuery),
    );
  }
}

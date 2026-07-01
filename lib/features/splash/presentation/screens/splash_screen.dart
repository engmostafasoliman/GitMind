import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function() onDone;
  const SplashScreen({super.key, required this.onDone});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Phase 0→0.45 : graph draws in
  late final Animation<double> _graphProgress;
  // Phase 0.4→0.7 : nodes pulse / glow
  late final Animation<double> _nodePulse;
  // Phase 0.5→0.78: text slides + fades in
  late final Animation<double> _textOpacity;
  late final Animation<double> _textSlide;
  // Phase 0.82→1.0 : whole screen fades out
  late final Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _graphProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
    );
    _nodePulse = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.40, 0.72, curve: Curves.easeInOut),
    );
    _textOpacity = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.50, 0.78, curve: Curves.easeOut),
    );
    _textSlide = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.50, 0.78, curve: Curves.easeOut),
    );
    _fadeOut = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.84, 1.0, curve: Curves.easeIn),
    );

    _ctrl.forward().then((_) {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0D1117);
    const accent = Color(0xFF6D8BFF);

    return Scaffold(
      backgroundColor: bg,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final fadeOutVal = _fadeOut.value;
          return Opacity(
            opacity: (1 - fadeOutVal).clamp(0.0, 1.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Neural graph ─────────────────────────────────────
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(
                      painter: _GraphPainter(
                        progress: _graphProgress.value,
                        pulse: _nodePulse.value,
                        accent: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  // ── "GitMind" text ───────────────────────────────────
                  Opacity(
                    opacity: _textOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _textSlide.value)),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Git',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: accent,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const TextSpan(
                              text: 'Mind',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Opacity(
                    opacity: (_textOpacity.value * 0.7).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - _textSlide.value)),
                      child: Text(
                        'AI-Powered Repo Intelligence',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.secondary(true),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GraphPainter extends CustomPainter {
  final double progress;
  final double pulse;
  final Color accent;

  const _GraphPainter({
    required this.progress,
    required this.pulse,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final ringR = size.width * 0.42;
    final nodeR = size.width * 0.055;
    final centerR = size.width * 0.085 + pulse * size.width * 0.018;

    final angles = List.generate(6, (i) => math.pi / 2 + i * (math.pi / 3));
    final nodes = angles.map((a) {
      return Offset(cx + ringR * math.cos(a), cy - ringR * math.sin(a));
    }).toList();

    // ── Paints ──────────────────────────────────────────────────────────
    final ringPaint = Paint()
      ..color = accent.withValues(alpha: 0.25 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final linePaint = Paint()
      ..color = accent.withValues(alpha: 0.35 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final spokePaint = Paint()
      ..color = accent.withValues(alpha: 0.55 * progress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final nodeFill = Paint()
      ..color = accent.withValues(alpha: 0.85 * progress);

    final centerFill = Paint()..color = accent;

    final glowPaint = Paint()
      ..color = accent.withValues(alpha: 0.12 * pulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    // ── Ring ────────────────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), ringR, ringPaint);

    // ── Cross-connections (drawn first — behind nodes) ──────────────────
    final pairs = [(0, 3), (1, 4), (2, 5), (0, 1), (2, 3), (4, 5)];
    for (final (i, j) in pairs) {
      _drawAnimatedLine(
        canvas, nodes[i], nodes[j], linePaint,
        threshold: 0.15 + i * 0.06,
      );
    }

    // ── Spokes from centre to each node ─────────────────────────────────
    for (var i = 0; i < 6; i++) {
      _drawAnimatedLine(
        canvas, Offset(cx, cy), nodes[i], spokePaint,
        threshold: i * 0.07,
      );
    }

    // ── Satellite nodes ──────────────────────────────────────────────────
    for (var i = 0; i < 6; i++) {
      final t = ((progress - i * 0.07) / 0.15).clamp(0.0, 1.0);
      if (t <= 0) continue;
      final r = nodeR * t;
      canvas.drawCircle(nodes[i], r, nodeFill);
    }

    // ── Centre glow ──────────────────────────────────────────────────────
    if (pulse > 0) {
      canvas.drawCircle(Offset(cx, cy), centerR * 1.6, glowPaint);
    }

    // ── Centre node ──────────────────────────────────────────────────────
    final ct = (progress / 0.2).clamp(0.0, 1.0);
    canvas.drawCircle(Offset(cx, cy), centerR * ct, centerFill);

    // ── Inner white dot ──────────────────────────────────────────────────
    if (ct > 0) {
      canvas.drawCircle(
        Offset(cx, cy),
        (centerR * 0.3) * ct,
        Paint()..color = Colors.white.withValues(alpha: ct),
      );
    }
  }

  void _drawAnimatedLine(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint, {
    required double threshold,
  }) {
    final t = ((progress - threshold) / 0.25).clamp(0.0, 1.0);
    if (t <= 0) return;
    final end = Offset.lerp(from, to, t)!;
    canvas.drawLine(from, end, paint);
  }

  @override
  bool shouldRepaint(_GraphPainter old) =>
      old.progress != progress || old.pulse != pulse;
}

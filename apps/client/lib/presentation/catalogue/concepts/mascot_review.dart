import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mascot-led: a calm, clean interface, with the personality carried by a
/// small character. The character here is a placeholder: a mikan, peeled at
/// the top.
class MascotReview extends StatelessWidget {
  const MascotReview({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final p = _Calm(dark);
    return ColoredBox(
      color: p.background,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Muki(size: 72),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Bubble(
                        p: p,
                        text: '30 to go — you’re on a roll!',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Card(p: p),
                const SizedBox(height: 20),
                Row(
                  children: [
                    for (final (label, interval, color) in [
                      ('Again', '10m', p.again),
                      ('Hard', '1d', p.hard),
                      ('Good', '3d', p.good),
                      ('Easy', '14d', p.easy),
                    ]) ...[
                      Expanded(
                        child: _Grade(
                          p: p,
                          label: label,
                          interval: interval,
                          color: color,
                        ),
                      ),
                      if (label != 'Easy') const SizedBox(width: 8),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: p.burnedSoft,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const Muki(size: 64, cheering: true),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Burned!', style: _head(18, p.burnedText)),
                            Text(
                              '天気 is yours for good. Muki is proud of you.',
                              style: _body(14, p.burnedText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Calm {
  _Calm(bool dark)
    : background = dark ? const Color(0xFF16181D) : const Color(0xFFFFF9F1),
      surface = dark ? const Color(0xFF22252C) : const Color(0xFFFFFFFF),
      text = dark ? const Color(0xFFF1EEE8) : const Color(0xFF2A2622),
      muted = dark ? const Color(0xFFA7A39C) : const Color(0xFF6E665E),
      border = dark ? const Color(0xFF30343C) : const Color(0xFFF0E6D8),
      again = dark ? const Color(0xFF5A2C2A) : const Color(0xFFFFE3DE),
      hard = dark ? const Color(0xFF52401F) : const Color(0xFFFFEFD2),
      good = dark ? const Color(0xFF233F2E) : const Color(0xFFE0F3E4),
      easy = dark ? const Color(0xFF22344D) : const Color(0xFFE0ECFB),
      burnedSoft = dark ? const Color(0xFF4A3220) : const Color(0xFFFFE8CF),
      burnedText = dark ? const Color(0xFFFFD9B5) : const Color(0xFF7A3D06),
      exampleBg = dark ? const Color(0xFF2B2E36) : const Color(0xFFFFF3E3);

  final Color background;
  final Color surface;
  final Color text;
  final Color muted;
  final Color border;
  final Color again;
  final Color hard;
  final Color good;
  final Color easy;
  final Color burnedSoft;
  final Color burnedText;
  final Color exampleBg;
}

TextStyle _head(double size, Color color) => TextStyle(
  fontFamily: 'ZenMaruGothic',
  fontFamilyFallback: const ['NotoSansJP'],
  fontWeight: FontWeight.w700,
  fontSize: size,
  color: color,
);

TextStyle _body(double size, Color color) =>
    TextStyle(fontFamily: 'NotoSansJP', fontSize: size, color: color);

class _Bubble extends StatelessWidget {
  const _Bubble({required this.p, required this.text});

  final _Calm p;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.border),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomRight: Radius.circular(18),
          bottomLeft: Radius.circular(4),
        ),
      ),
      child: Text(text, style: _head(15, p.text)),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.p});

  final _Calm p;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: p.border),
      ),
      child: Column(
        children: [
          Text('てんき', style: _body(15, p.muted)),
          Text(
            '天気',
            style: _body(56, p.text).copyWith(
              height: 1.15,
              fontVariations: const [FontVariation.weight(500)],
            ),
          ),
          const SizedBox(height: 24),
          Text('weather', style: _head(26, p.text)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.exampleBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日はいい天気ですね。', style: _body(17, p.text)),
                Text(
                  'Nice weather today, isn’t it?',
                  style: _body(14, p.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Grade extends StatelessWidget {
  const _Grade({
    required this.p,
    required this.label,
    required this.interval,
    required this.color,
  });

  final _Calm p;
  final String label;
  final String interval;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(label, style: _head(16, p.text)),
          Text(interval, style: _body(12.5, p.muted)),
        ],
      ),
    );
  }
}

/// Placeholder mascot: a mikan with its peel opened at the top.
class Muki extends StatelessWidget {
  const Muki({super.key, required this.size, this.cheering = false});

  final double size;
  final bool cheering;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _MukiPainter(cheering: cheering),
  );
}

class _MukiPainter extends CustomPainter {
  _MukiPainter({required this.cheering});

  final bool cheering;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final center = Offset(s * 0.5, s * 0.58);
    final r = s * 0.4;

    // Body.
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFFF6922E));
    // Peeled top: the pale pith showing through.
    final pith = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: r * 0.92),
        math.pi * 1.15,
        math.pi * 0.7,
      )
      ..close();
    canvas.drawPath(pith, Paint()..color = const Color(0xFFFFE2B8));
    // Leaf.
    final leaf = Path()
      ..moveTo(center.dx, center.dy - r * 0.95)
      ..quadraticBezierTo(
        center.dx + r * 0.55,
        center.dy - r * 1.45,
        center.dx + r * 0.75,
        center.dy - r * 1.05,
      )
      ..quadraticBezierTo(
        center.dx + r * 0.3,
        center.dy - r * 0.9,
        center.dx,
        center.dy - r * 0.95,
      );
    canvas.drawPath(leaf, Paint()..color = const Color(0xFF5BAA5E));

    // Face.
    final ink = Paint()
      ..color = const Color(0xFF3A2416)
      ..strokeWidth = s * 0.035
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final eyeY = center.dy + r * 0.08;
    for (final dx in [-0.33, 0.33]) {
      final eye = Offset(center.dx + r * dx, eyeY);
      if (cheering) {
        // Happy closed eyes: ^ ^
        canvas.drawPath(
          Path()
            ..moveTo(eye.dx - r * 0.1, eye.dy + r * 0.04)
            ..lineTo(eye.dx, eye.dy - r * 0.06)
            ..lineTo(eye.dx + r * 0.1, eye.dy + r * 0.04),
          ink,
        );
      } else {
        canvas.drawCircle(
          eye,
          r * 0.07,
          Paint()..color = const Color(0xFF3A2416),
        );
      }
    }
    final blush = Paint()..color = const Color(0x66FF5E6C);
    for (final dx in [-0.55, 0.55]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx + r * dx, eyeY + r * 0.2),
          width: r * 0.24,
          height: r * 0.13,
        ),
        blush,
      );
    }
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(center.dx, eyeY + r * 0.14),
        width: r * (cheering ? 0.36 : 0.24),
        height: r * (cheering ? 0.3 : 0.18),
      ),
      0.15 * math.pi,
      0.7 * math.pi,
      false,
      ink,
    );
  }

  @override
  bool shouldRepaint(_MukiPainter old) => old.cheering != cheering;
}

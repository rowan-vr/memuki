import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Study-desk stationery: cards are index cards on a desk, decks have washi
/// tape tabs, and grades are ink stamps. Indigo and vermilion ink on cream.
class StationeryReview extends StatelessWidget {
  const StationeryReview({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final p = _Paper(dark);
    return ColoredBox(
      color: p.desk,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(p: p),
                const SizedBox(height: 20),
                _IndexCard(p: p),
                const SizedBox(height: 28),
                _Stamps(p: p),
                const SizedBox(height: 28),
                _BurnedSlip(p: p),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Paper {
  _Paper(bool dark)
    : desk = dark ? const Color(0xFF1C1A20) : const Color(0xFFEDE5D6),
      paper = dark ? const Color(0xFF2B2830) : const Color(0xFFFCF8EF),
      rule = dark ? const Color(0xFF3D3843) : const Color(0xFFE6DCC8),
      margin = dark ? const Color(0x55FF7A5C) : const Color(0x44D9452B),
      ink = dark ? const Color(0xFFEDE6D8) : const Color(0xFF22355F),
      inkSoft = dark ? const Color(0xFFA9A1B0) : const Color(0xFF6B6F86),
      vermilion = dark ? const Color(0xFFFF7A5C) : const Color(0xFFCF3F24),
      tape = dark ? const Color(0xCC6E8FD8) : const Color(0xCC9DB7E8),
      shadow = dark ? const Color(0x66000000) : const Color(0x22503C1E);

  final Color desk;
  final Color paper;
  final Color rule;
  final Color margin;
  final Color ink;
  final Color inkSoft;
  final Color vermilion;
  final Color tape;
  final Color shadow;
}

const _hand = TextStyle(
  fontFamily: 'ZenMaruGothic',
  fontWeight: FontWeight.w700,
);
const _body = TextStyle(fontFamily: 'NotoSansJP');

class _Header extends StatelessWidget {
  const _Header({required this.p});

  final _Paper p;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // A washi tape tab carrying the deck name.
        Transform.rotate(
          angle: -0.03,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: p.tape,
            child: Text(
              'Japanese · N4',
              style: _hand.copyWith(fontSize: 15, color: p.ink),
            ),
          ),
        ),
        const Spacer(),
        Text(
          '12 / 42',
          style: _body.copyWith(
            fontSize: 14,
            color: p.inkSoft,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _IndexCard extends StatelessWidget {
  const _IndexCard({required this.p});

  final _Paper p;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.008,
      child: Container(
        decoration: BoxDecoration(
          color: p.paper,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: p.shadow,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
            BoxShadow(
              color: p.shadow,
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: CustomPaint(
          painter: _RulePainter(p),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(56, 36, 28, 32),
            child: Column(
              children: [
                Text(
                  'てんき',
                  style: _body.copyWith(fontSize: 15, color: p.inkSoft),
                ),
                Text(
                  '天気',
                  style: _body.copyWith(
                    fontSize: 56,
                    height: 1.15,
                    color: p.ink,
                    fontVariations: const [FontVariation.weight(500)],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'weather',
                  style: _hand.copyWith(fontSize: 26, color: p.ink),
                ),
                const SizedBox(height: 18),
                Text(
                  '今日はいい天気ですね。',
                  style: _body.copyWith(fontSize: 17, color: p.ink),
                ),
                const SizedBox(height: 2),
                Text(
                  'Nice weather today, isn’t it?',
                  style: _body.copyWith(fontSize: 14, color: p.inkSoft),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The top band, ruled lines, and red margin of an index card.
class _RulePainter extends CustomPainter {
  _RulePainter(this.p);

  final _Paper p;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, 6),
      Paint()..color = p.vermilion,
    );
    final rule = Paint()
      ..color = p.rule
      ..strokeWidth = 1;
    for (var y = 40.0; y < size.height - 8; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rule);
    }
    canvas.drawLine(
      const Offset(40, 6),
      Offset(40, size.height),
      Paint()
        ..color = p.margin
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_RulePainter old) => old.p != p;
}

class _Stamps extends StatelessWidget {
  const _Stamps({required this.p});

  final _Paper p;

  @override
  Widget build(BuildContext context) {
    final grades = [
      ('Again', '10m', p.vermilion, -0.10),
      ('Hard', '1d', p.inkSoft, 0.06),
      ('Good', '3d', p.ink, -0.04),
      ('Easy', '14d', p.ink, 0.08),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final (label, interval, color, angle) in grades)
          _Stamp(label: label, interval: interval, color: color, angle: angle),
      ],
    );
  }
}

/// A round rubber-stamp grade.
class _Stamp extends StatelessWidget {
  const _Stamp({
    required this.label,
    required this.interval,
    required this.color,
    required this.angle,
  });

  final String label;
  final String interval;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2.5),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: _hand.copyWith(fontSize: 16, color: color)),
              Text(interval, style: _body.copyWith(fontSize: 12, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A burned card: the card gets a vermilion seal, like a finished page.
class _BurnedSlip extends StatelessWidget {
  const _BurnedSlip({required this.p});

  final _Paper p;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.paper,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 6, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Transform.rotate(
            angle: math.pi / 18,
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: p.vermilion,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '完',
                style: _body.copyWith(
                  fontSize: 26,
                  color: p.paper,
                  fontVariations: const [FontVariation.weight(800)],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Burned',
                  style: _hand.copyWith(fontSize: 17, color: p.ink),
                ),
                Text(
                  '天気 is learned for good. It leaves your reviews.',
                  style: _body.copyWith(fontSize: 14, color: p.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

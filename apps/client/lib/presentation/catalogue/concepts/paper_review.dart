import 'package:flutter/material.dart';

import '../../theme/motion.dart';

/// A tidier take on stationery: the same paper and ink, with everything
/// straight and aligned. Each element keeps one playful detail: the notched
/// tape tab, the deck-colour edge, the perforation between the card's sides,
/// stamps that fill with ink when pressed, and the seal on burned cards.
class PaperReview extends StatelessWidget {
  const PaperReview({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final p = _Ink(dark);
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
                const SizedBox(height: 16),
                _Card(p: p),
                const SizedBox(height: 20),
                Row(
                  children: [
                    for (final (label, interval, color) in [
                      ('Again', '10m', p.vermilion),
                      ('Hard', '1d', p.ink),
                      ('Good', '3d', p.ink),
                      ('Easy', '14d', p.ink),
                    ]) ...[
                      Expanded(
                        child: StampButton(
                          ink: color,
                          paper: p.paper,
                          label: label,
                          interval: interval,
                        ),
                      ),
                      if (label != 'Easy') const SizedBox(width: 10),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
                _Burned(p: p),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Ink {
  _Ink(bool dark)
    : desk = dark ? const Color(0xFF1A191E) : const Color(0xFFF1EBDF),
      paper = dark ? const Color(0xFF26252B) : const Color(0xFFFFFCF6),
      line = dark ? const Color(0xFF3A3841) : const Color(0xFFE4DACA),
      ink = dark ? const Color(0xFFECE6DA) : const Color(0xFF22355F),
      inkSoft = dark ? const Color(0xFFA8A2AE) : const Color(0xFF666A80),
      vermilion = dark ? const Color(0xFFFF7D62) : const Color(0xFFC93C22),
      tape = dark ? const Color(0xFF55699A) : const Color(0xFFB5C8EC),
      tapeInk = dark ? const Color(0xFFF1EDF8) : const Color(0xFF22355F),
      shadow = dark ? const Color(0x59000000) : const Color(0x1A4A3418);

  final Color desk;
  final Color paper;
  final Color line;
  final Color ink;
  final Color inkSoft;
  final Color vermilion;
  final Color tape;
  final Color tapeInk;
  final Color shadow;

  List<BoxShadow> get paperShadow => [
    BoxShadow(color: shadow, blurRadius: 1, offset: const Offset(0, 1)),
    BoxShadow(color: shadow, blurRadius: 14, offset: const Offset(0, 6)),
  ];
}

TextStyle _head(double size, Color color) => TextStyle(
  fontFamily: 'ZenMaruGothic',
  fontFamilyFallback: const ['NotoSansJP'],
  fontWeight: FontWeight.w700,
  fontSize: size,
  color: color,
);

TextStyle _body(double size, Color color, {double weight = 400}) => TextStyle(
  fontFamily: 'NotoSansJP',
  fontSize: size,
  color: color,
  fontVariations: [FontVariation.weight(weight)],
);

class _Header extends StatelessWidget {
  const _Header({required this.p});

  final _Ink p;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipPath(
          clipper: _NotchedEnds(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            color: p.tape,
            child: Text('Japanese · N4', style: _head(14, p.tapeInk)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 12 / 42,
              minHeight: 3,
              color: p.ink,
              backgroundColor: p.line,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '12 / 42',
          style: _body(
            13,
            p.inkSoft,
            weight: 500,
          ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
      ],
    );
  }
}

/// Small V-notches at both ends, like cut washi tape.
class _NotchedEnds extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notch = 5.0;
    final h = size.height;
    final w = size.width;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - notch, h / 2)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..lineTo(notch, h / 2)
      ..close();
  }

  @override
  bool shouldReclip(_NotchedEnds oldClipper) => false;
}

class _Card extends StatelessWidget {
  const _Card({required this.p});

  final _Ink p;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.paper,
        borderRadius: BorderRadius.circular(10),
        boxShadow: p.paperShadow,
      ),
      child: Column(
        children: [
          Container(height: 5, color: p.vermilion),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                Text('てんき', style: _body(15, p.inkSoft)),
                Text(
                  '天気',
                  style: _body(56, p.ink, weight: 500).copyWith(height: 1.15),
                ),
              ],
            ),
          ),
          CustomPaint(
            size: const Size(double.infinity, 1),
            painter: _Perforation(p.line),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            child: Column(
              children: [
                Text('weather', style: _head(26, p.ink)),
                const SizedBox(height: 14),
                Text('今日はいい天気ですね。', style: _body(17, p.ink)),
                const SizedBox(height: 2),
                Text(
                  'Nice weather today, isn’t it?',
                  style: _body(14, p.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A dashed line between the card's sides, like a perforation.
class _Perforation extends CustomPainter {
  _Perforation(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    for (var x = 16.0; x < size.width - 16; x += 9) {
      canvas.drawLine(Offset(x, 0), Offset(x + 4, 0), paint);
    }
  }

  @override
  bool shouldRepaint(_Perforation old) => old.color != color;
}

/// A grade button drawn as an outlined stamp, which fills with ink while
/// pressed.
class StampButton extends StatefulWidget {
  const StampButton({
    super.key,
    required this.ink,
    required this.paper,
    required this.label,
    required this.interval,
    this.onPressed,
  });

  final Color ink;
  final Color paper;
  final String label;
  final String interval;
  final VoidCallback? onPressed;

  @override
  State<StampButton> createState() => _StampButtonState();
}

class _StampButtonState extends State<StampButton> {
  bool _pressed = false;

  void _set(bool pressed) => setState(() => _pressed = pressed);

  @override
  Widget build(BuildContext context) {
    final fg = _pressed ? widget.paper : widget.ink;
    return Semantics(
      button: true,
      label: widget.label,
      child: GestureDetector(
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1,
          duration: Motion.quick,
          curve: _pressed ? Motion.settle : Motion.spring,
          child: AnimatedContainer(
            duration: Motion.quick,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _pressed ? widget.ink : widget.paper,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: widget.ink, width: 2),
            ),
            child: Column(
              children: [
                Text(widget.label, style: _head(16, fg)),
                Text(widget.interval, style: _body(12.5, fg, weight: 500)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Burned extends StatelessWidget {
  const _Burned({required this.p});

  final _Ink p;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.paper,
        borderRadius: BorderRadius.circular(10),
        boxShadow: p.paperShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.vermilion,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('完', style: _body(24, p.paper, weight: 800)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Burned', style: _head(17, p.ink)),
                Text(
                  '天気 is learned for good. It leaves your reviews.',
                  style: _body(14, p.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/motion.dart';

/// Chunky and tactile: thick outlines, solid offset shadows, and buttons that
/// press down into their shadow. Bold, flat colour pairs.
class ChunkyReview extends StatelessWidget {
  const ChunkyReview({super.key, required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final p = _Chunk(dark);
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
                _Header(p: p),
                const SizedBox(height: 20),
                _Block(
                  p: p,
                  color: p.surface,
                  radius: 24,
                  depth: 6,
                  child: _CardFace(p: p),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    for (final (label, interval, color) in [
                      ('Again', '10m', p.again),
                      ('Hard', '1d', p.hard),
                      ('Good', '3d', p.good),
                      ('Easy', '14d', p.easy),
                    ]) ...[
                      Expanded(
                        child: ChunkyButton(
                          outline: p.outline,
                          color: color,
                          child: Column(
                            children: [
                              Text(label, style: _bold(17, p.ink)),
                              Text(interval, style: _plain(13, p.ink)),
                            ],
                          ),
                        ),
                      ),
                      if (label != 'Easy') const SizedBox(width: 10),
                    ],
                  ],
                ),
                const SizedBox(height: 28),
                _Block(
                  p: p,
                  color: p.burned,
                  radius: 18,
                  depth: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          size: 32,
                          color: p.ink,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('BURNED!', style: _bold(18, p.ink)),
                              Text(
                                '天気 is learned for good.',
                                style: _plain(14, p.ink),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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

class _Chunk {
  _Chunk(bool dark)
    : background = dark ? const Color(0xFF1E1B26) : const Color(0xFFFFF1D0),
      surface = dark ? const Color(0xFF2E2A3A) : const Color(0xFFFFFFFF),
      outline = dark ? const Color(0xFFF6EBD6) : const Color(0xFF1F1A17),
      text = dark ? const Color(0xFFF6EBD6) : const Color(0xFF1F1A17),
      muted = dark ? const Color(0xFFB9AFC4) : const Color(0xFF5E5650),
      ink = const Color(0xFF1F1A17),
      again = const Color(0xFFFF6F5B),
      hard = const Color(0xFFFFC94A),
      good = const Color(0xFF5DD39E),
      easy = const Color(0xFF74B9FF),
      burned = const Color(0xFFFFA24C),
      sticker = const Color(0xFFFF8FB8);

  final Color background;
  final Color surface;
  final Color outline;
  final Color text;
  final Color muted;

  /// Text on the bright fills, dark in both themes.
  final Color ink;
  final Color again;
  final Color hard;
  final Color good;
  final Color easy;
  final Color burned;
  final Color sticker;
}

TextStyle _bold(double size, Color color) => TextStyle(
  fontFamily: 'MPLUSRounded1c',
  fontFamilyFallback: const ['NotoSansJP'],
  fontWeight: FontWeight.w700,
  fontSize: size,
  color: color,
);

TextStyle _plain(double size, Color color) => TextStyle(
  fontFamily: 'NotoSansJP',
  fontSize: size,
  color: color,
  fontVariations: const [FontVariation.weight(500)],
);

class _Header extends StatelessWidget {
  const _Header({required this.p});

  final _Chunk p;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Block(
          p: p,
          color: p.sticker,
          radius: 999,
          depth: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text('Japanese · N4', style: _bold(15, p.ink)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: p.outline, width: 2.5),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 12 / 42,
              child: Container(
                decoration: BoxDecoration(
                  color: p.good,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text('12/42', style: _bold(15, p.text)),
      ],
    );
  }
}

/// An outlined block on a solid offset shadow.
class _Block extends StatelessWidget {
  const _Block({
    required this.p,
    required this.color,
    required this.radius,
    required this.depth,
    required this.child,
  });

  final _Chunk p;
  final Color color;
  final double radius;
  final double depth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.outline, width: 2.5),
        boxShadow: [BoxShadow(color: p.outline, offset: Offset(depth, depth))],
      ),
      child: child,
    );
  }
}

class _CardFace extends StatelessWidget {
  const _CardFace({required this.p});

  final _Chunk p;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      child: Column(
        children: [
          Text('てんき', style: _plain(15, p.muted)),
          Text(
            '天気',
            style: _plain(58, p.text).copyWith(
              height: 1.15,
              fontVariations: const [FontVariation.weight(700)],
            ),
          ),
          const SizedBox(height: 20),
          Container(height: 2.5, color: p.outline),
          const SizedBox(height: 20),
          Text('weather', style: _bold(28, p.text)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: p.hard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.outline, width: 2.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('今日はいい天気ですね。', style: _plain(17, p.ink)),
                Text('Nice weather today, isn’t it?', style: _plain(14, p.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A button that sinks into its solid shadow while pressed.
class ChunkyButton extends StatefulWidget {
  const ChunkyButton({
    super.key,
    required this.outline,
    required this.color,
    required this.child,
    this.onPressed,
  });

  final Color outline;
  final Color color;
  final Widget child;
  final VoidCallback? onPressed;

  @override
  State<ChunkyButton> createState() => _ChunkyButtonState();
}

class _ChunkyButtonState extends State<ChunkyButton> {
  static const _depth = 5.0;
  bool _pressed = false;

  void _set(bool pressed) => setState(() => _pressed = pressed);

  @override
  Widget build(BuildContext context) {
    final offset = _pressed ? _depth : 0.0;
    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onPressed,
        child: Padding(
          padding: const EdgeInsets.only(right: _depth, bottom: _depth),
          child: AnimatedContainer(
            duration: Motion.quick,
            curve: _pressed ? Motion.settle : Motion.spring,
            transform: Matrix4.translationValues(offset, offset, 0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.outline, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: widget.outline,
                  offset: Offset(_depth - offset, _depth - offset),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

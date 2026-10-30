import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/memuki_layout.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';

/// A debug-only screen showing Memuki's tokens and the elements built from
/// them, with every appearance setting switchable and at large text scales.
///
/// It is a development tool, so its text is not localized.
class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  Appearance? _appearance;
  double _textScale = 1;

  @override
  Widget build(BuildContext context) {
    final appearance =
        _appearance ??
        Appearance(
          mode: Theme.of(context).brightness == Brightness.dark
              ? ColorMode.dark
              : ColorMode.light,
        );
    void update(Appearance a) => setState(() => _appearance = a);
    return Theme(
      data: AppTheme.build(appearance),
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(_textScale)),
        child: Builder(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Catalogue')),
            body: ListView(
              padding: const EdgeInsets.all(Spacing.lg),
              children: [
                _Controls(
                  appearance: appearance,
                  textScale: _textScale,
                  onChanged: update,
                  onTextScale: (v) => setState(() => _textScale = v),
                ),
                const SizedBox(height: Spacing.xl),
                const Wrap(
                  spacing: Spacing.lg,
                  runSpacing: Spacing.lg,
                  children: [
                    _Column(children: [_Today(), _RecentDecks()]),
                    _Column(children: [_StudyCard(), _Grades()]),
                    _Column(children: [_Elements(), _Palette()]),
                  ],
                ),
                const SizedBox(height: Spacing.xl),
                const _TypeScale(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.appearance,
    required this.textScale,
    required this.onChanged,
    required this.onTextScale,
  });

  final Appearance appearance;
  final double textScale;
  final ValueChanged<Appearance> onChanged;
  final ValueChanged<double> onTextScale;

  @override
  Widget build(BuildContext context) {
    final a = appearance;
    return Wrap(
      spacing: Spacing.lg,
      runSpacing: Spacing.md,
      children: [
        _ChoiceGroup(
          label: 'Mode',
          values: ColorMode.values,
          selected: a.mode,
          name: (v) => v.name,
          onSelected: (v) => onChanged(a.copyWith(mode: v)),
        ),
        _AccentPicker(
          selected: a.accent,
          onSelected: (v) => onChanged(a.copyWith(accent: v)),
        ),
        _ChoiceGroup(
          label: 'Card style',
          values: CardStyle.values,
          selected: a.cardStyle,
          name: (v) => v.name,
          onSelected: (v) => onChanged(a.copyWith(cardStyle: v)),
        ),
        _ChoiceGroup(
          label: 'Density',
          values: Density.values,
          selected: a.density,
          name: (v) => v.name,
          onSelected: (v) => onChanged(a.copyWith(density: v)),
        ),
        _ChoiceGroup(
          label: 'Text scale',
          values: const [1.0, 1.3, 2.0],
          selected: textScale,
          name: (v) => '$v×',
          onSelected: onTextScale,
        ),
      ],
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: context.type.caption.copyWith(color: context.colors.textMuted),
        ),
        const SizedBox(height: Spacing.xs),
        child,
      ],
    );
  }
}

/// A row of choices. A stand-in until the shared segmented control exists.
class _ChoiceGroup<T> extends StatelessWidget {
  const _ChoiceGroup({
    required this.label,
    required this.values,
    required this.selected,
    required this.name,
    required this.onSelected,
  });

  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) name;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Labelled(
      label: label,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: colors.surfaceSunken,
          borderRadius: BorderRadius.circular(Radii.sm),
        ),
        child: Wrap(
          children: [
            for (final value in values)
              _Tappable(
                selected: value == selected,
                onTap: () => onSelected(value),
                child: AnimatedContainer(
                  duration: Motion.quick,
                  curve: Motion.settle,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md - 4,
                    vertical: Spacing.xs + 2,
                  ),
                  decoration: BoxDecoration(
                    color: value == selected
                        ? colors.surfaceRaised
                        : const Color(0x00000000),
                    borderRadius: BorderRadius.circular(Radii.sm - 3),
                    boxShadow: value == selected ? _paperShadow(colors) : null,
                  ),
                  child: Text(
                    name(value),
                    style: context.type.label.copyWith(
                      color: value == selected ? colors.text : colors.textMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.selected, required this.onSelected});

  final MemukiAccent selected;
  final ValueChanged<MemukiAccent> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _Labelled(
      label: 'Accent',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final accent in MemukiAccent.values)
            _Tappable(
              selected: accent == selected,
              label: accent.name,
              onTap: () => onSelected(accent),
              child: AnimatedContainer(
                duration: Motion.quick,
                margin: const EdgeInsets.only(right: Spacing.xs + 2),
                width: 30,
                height: 30,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent == selected
                        ? colors.text
                        : const Color(0x00000000),
                    width: 2,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.swatches[accent]!.base,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Tappable extends StatelessWidget {
  const _Tappable({
    required this.selected,
    required this.onTap,
    required this.child,
    this.label,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final String? label;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: label,
    child: GestureDetector(onTap: onTap, child: child),
  );
}

List<BoxShadow> _paperShadow(MemukiColors colors) => [
  BoxShadow(
    color: colors.brightness == Brightness.light
        ? const Color(0x14473A28)
        : const Color(0x59000000),
    blurRadius: 1,
    offset: const Offset(0, 1),
  ),
  BoxShadow(
    color: colors.brightness == Brightness.light
        ? const Color(0x0F473A28)
        : const Color(0x40000000),
    blurRadius: 12,
    offset: const Offset(0, 4),
  ),
];

class _Column extends StatelessWidget {
  const _Column({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final child in children) ...[
            child,
            const SizedBox(height: Spacing.lg),
          ],
        ],
      ),
    );
  }
}

/// A paper panel on the desk.
class _Panel extends StatelessWidget {
  const _Panel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md + 4,
        vertical: context.layout.dense(Spacing.md + 4),
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(color: colors.border),
        boxShadow: _paperShadow(colors),
      ),
      child: child,
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({required this.label, required this.icon, this.primary = true});

  final String label;
  final IconData icon;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final fg = primary ? colors.accent.onBase : colors.text;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: context.layout.dense(Spacing.sm + 4),
      ),
      decoration: BoxDecoration(
        color: primary ? colors.accent.base : colors.surface,
        borderRadius: BorderRadius.circular(Radii.sm),
        border: primary ? null : Border.all(color: colors.border, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: Spacing.sm),
          Flexible(
            child: Text(label, style: context.type.label.copyWith(color: fg)),
          ),
        ],
      ),
    );
  }
}

class _Today extends StatelessWidget {
  const _Today();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final muted = type.caption.copyWith(color: colors.textMuted);
    Widget stat(String value, String label) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: type.title.copyWith(fontFamily: type.body.fontFamily),
          ),
          Text(label, style: muted),
        ],
      ),
    );
    Widget divider() => Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.only(right: Spacing.md),
      color: colors.border,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Mon, 24 Mar', style: muted),
        Text('Good morning!', style: type.display),
        Text(
          'A little progress goes a long way.',
          style: type.body.copyWith(color: colors.textMuted),
        ),
        const SizedBox(height: Spacing.md),
        _Panel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Ready to study?', style: type.heading),
              SizedBox(height: context.layout.dense(Spacing.md)),
              Row(
                children: [
                  stat('42', 'due'),
                  divider(),
                  stat('12', 'new'),
                  divider(),
                  stat('~18 min', 'estimated'),
                ],
              ),
              SizedBox(height: context.layout.dense(Spacing.md + 4)),
              const _Button(
                label: 'Start studying',
                icon: Icons.play_arrow_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentDecks extends StatelessWidget {
  const _RecentDecks();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final decks = [
      ('Japanese Vocabulary', '32 due', MemukiAccent.coral),
      ('N2 Kanji', '18 due', MemukiAccent.green),
      ('Genki 1', '4 due', MemukiAccent.mustard),
      ('Travel Phrases', '0 due', MemukiAccent.blue),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text('Recent decks', style: type.heading)),
            Text(
              'See all',
              style: type.label.copyWith(color: colors.accent.onSoft),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        _Panel(
          child: Column(
            children: [
              for (final (i, (name, due, swatch)) in decks.indexed) ...[
                if (i > 0) Container(height: 1, color: colors.border),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: context.layout.dense(Spacing.sm + 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: colors.swatches[swatch]!.base,
                          borderRadius: BorderRadius.circular(Radii.xs),
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: type.bodyStrong),
                            Text(
                              due,
                              style: type.caption.copyWith(
                                color: colors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: colors.textMuted),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// The study card in the chosen card style.
class _StudyCard extends StatelessWidget {
  const _StudyCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final style = context.layout.cardStyle;
    final level = colors.swatches[MemukiAccent.mustard]!;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg,
        Spacing.lg,
        Spacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: level.soft,
                borderRadius: BorderRadius.circular(Radii.xs),
              ),
              child: Text(
                'N5',
                style: type.caption.copyWith(color: level.onSoft),
              ),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          Text(
            '猫',
            textAlign: TextAlign.center,
            style: type.body.copyWith(fontSize: 52, height: 1.2),
          ),
          Text(
            'ねこ',
            textAlign: TextAlign.center,
            style: type.body.copyWith(fontSize: 18, color: colors.textMuted),
          ),
          const SizedBox(height: Spacing.sm),
          Icon(Icons.volume_up_outlined, color: colors.textMuted),
          const SizedBox(height: Spacing.md),
          Text('cat', textAlign: TextAlign.center, style: type.title),
        ],
      ),
    );
    return switch (style) {
      CardStyle.minimal => content,
      CardStyle.standard => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: colors.border),
          boxShadow: _paperShadow(colors),
        ),
        child: content,
      ),
      CardStyle.notecard => DecoratedBox(
        decoration: ShapeDecoration(
          color: colors.surface,
          shape: const _FoldedCorner(),
          shadows: _paperShadow(colors),
        ),
        child: CustomPaint(
          foregroundPainter: _NotecardPainter(colors),
          child: content,
        ),
      ),
    };
  }
}

/// A card outline with its top-right corner folded over.
class _FoldedCorner extends ShapeBorder {
  const _FoldedCorner();

  static const fold = 22.0;
  static const radius = 6.0;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()
    ..moveTo(rect.left + radius, rect.top)
    ..lineTo(rect.right - fold, rect.top)
    ..lineTo(rect.right, rect.top + fold)
    ..lineTo(rect.right, rect.bottom - radius)
    ..quadraticBezierTo(
      rect.right,
      rect.bottom,
      rect.right - radius,
      rect.bottom,
    )
    ..lineTo(rect.left + radius, rect.bottom)
    ..quadraticBezierTo(rect.left, rect.bottom, rect.left, rect.bottom - radius)
    ..lineTo(rect.left, rect.top + radius)
    ..quadraticBezierTo(rect.left, rect.top, rect.left + radius, rect.top)
    ..close();

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

/// The folded flap and the coloured rule under a notecard's header.
class _NotecardPainter extends CustomPainter {
  _NotecardPainter(this.colors);

  final MemukiColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    const fold = _FoldedCorner.fold;
    final flap = Path()
      ..moveTo(size.width - fold, 0)
      ..lineTo(size.width - fold, fold - 3)
      ..quadraticBezierTo(size.width - fold, fold, size.width - fold + 3, fold)
      ..lineTo(size.width, fold)
      ..close();
    canvas.drawPath(flap, Paint()..color = colors.surfaceSunken);
    canvas.drawPath(
      flap,
      Paint()
        ..color = colors.border
        ..style = PaintingStyle.stroke,
    );
    canvas.drawLine(
      const Offset(Spacing.lg, 56),
      Offset(size.width - Spacing.lg, 56),
      Paint()
        ..color = colors.swatches[MemukiAccent.coral]!.base.withValues(
          alpha: 0.45,
        )
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_NotecardPainter old) => old.colors != colors;
}

class _Grades extends StatelessWidget {
  const _Grades();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    final grades = [
      ('Again', '<1 min', colors.again),
      ('Hard', '6 min', colors.hard),
      ('Good', '1 day', colors.good),
      ('Easy', '4 days', colors.easy),
    ];
    return Row(
      children: [
        for (final (i, (label, interval, tone)) in grades.indexed) ...[
          if (i > 0) const SizedBox(width: Spacing.sm),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: context.layout.dense(Spacing.sm + 4),
              ),
              decoration: BoxDecoration(
                color: tone.base,
                borderRadius: BorderRadius.circular(Radii.sm),
              ),
              child: Column(
                children: [
                  Text(label, style: type.label.copyWith(color: tone.onBase)),
                  Text(
                    interval,
                    style: type.caption.copyWith(color: tone.onBase),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Elements extends StatelessWidget {
  const _Elements();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
    Widget tag(String label, ToneColors? tone) => Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm + 2,
        vertical: Spacing.xs - 1,
      ),
      decoration: BoxDecoration(
        color: tone?.soft ?? colors.surfaceSunken,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Text(
        label,
        style: type.caption.copyWith(color: tone?.onSoft ?? colors.textMuted),
      ),
    );
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              _Button(label: 'Start studying', icon: Icons.play_arrow_rounded),
              _Button(label: 'Add to library', icon: Icons.add, primary: false),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Wrap(
            spacing: Spacing.xs + 2,
            runSpacing: Spacing.xs + 2,
            children: [
              tag('vocabulary', null),
              tag('nouns', null),
              tag('JLPT N5', colors.swatches[MemukiAccent.green]),
              tag('leech', colors.again),
              tag('burned', colors.burned),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            'Progress',
            style: type.caption.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: Spacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.pill),
            child: SizedBox(
              height: 6,
              child: Row(
                children: [
                  Expanded(flex: 12, child: Container(color: colors.good.base)),
                  Expanded(
                    flex: 30,
                    child: Container(color: colors.surfaceSunken),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            '12 / 42',
            style: type.caption.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Palette extends StatelessWidget {
  const _Palette();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    Widget swatch(Color color, {bool outlined = false}) => Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(Radii.xs),
        border: outlined ? Border.all(color: c.border) : null,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Colour palette', style: context.type.heading),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.xs + 2,
          runSpacing: Spacing.xs + 2,
          children: [
            for (final color in [
              c.background,
              c.surface,
              c.surfaceSunken,
              c.border,
              c.textMuted,
              c.text,
            ])
              swatch(color, outlined: true),
          ],
        ),
        const SizedBox(height: Spacing.xs + 2),
        Wrap(
          spacing: Spacing.xs + 2,
          runSpacing: Spacing.xs + 2,
          children: [for (final tone in c.swatches.values) swatch(tone.base)],
        ),
      ],
    );
  }
}

class _TypeScale extends StatelessWidget {
  const _TypeScale();

  @override
  Widget build(BuildContext context) {
    final t = context.type;
    final muted = t.caption.copyWith(color: context.colors.textMuted);
    final styles = [
      ('display', t.display, 'Learn, remember, grow. 覚えて、つながる。'),
      ('title', t.title, 'Japanese Vocabulary · 日本語'),
      ('heading', t.heading, 'Recent decks · 今日の復習'),
      ('body', t.body, 'Notes generate cards from their fields. 漢字とかな'),
      ('body strong', t.bodyStrong, '42 reviews and 12 new cards'),
      ('label', t.label, 'Start studying'),
      ('caption', t.caption, 'Last studied 2 hours ago'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (name, style, sample) in styles)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: muted),
                Text(sample, style: style),
              ],
            ),
          ),
      ],
    );
  }
}

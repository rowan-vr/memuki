import 'package:flutter/material.dart';

import '../components/animations.dart';
import '../components/buttons.dart';
import '../components/icons.dart';
import '../components/indicators.dart';
import '../components/panel.dart';
import '../components/pressable.dart';
import '../components/rows.dart';
import '../components/screen.dart';
import '../components/segmented_choice.dart';
import '../theme/app_theme.dart';
import '../theme/breakpoints.dart';
import '../theme/memuki_colors.dart';
import '../theme/memuki_layout.dart';
import '../theme/motion.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';

/// A debug-only screen showing Memuki's tokens and components, section by
/// section, with every appearance setting switchable and at large text
/// scales.
///
/// It is a development tool, so its text is not localized.
class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

/// A page of the catalogue.
enum CatalogueSection {
  colours('Foundations', 'Colours'),
  type('Foundations', 'Type'),
  shape('Foundations', 'Shape & spacing'),
  buttons('Components', 'Buttons'),
  grades('Components', 'Grade buttons'),
  lists('Components', 'Lists'),
  choices('Components', 'Choices'),
  indicators('Components', 'Tags & progress'),
  panels('Components', 'Panels'),
  home('Examples', 'Home'),
  study('Examples', 'Study');

  const CatalogueSection(this.group, this.title);

  final String group;
  final String title;
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  Appearance? _appearance;
  double _textScale = 1;
  CatalogueSection _section = CatalogueSection.colours;

  @override
  Widget build(BuildContext context) {
    final appearance =
        _appearance ??
        Appearance(
          mode: Theme.of(context).brightness == Brightness.dark
              ? ColorMode.dark
              : ColorMode.light,
        );
    final wide = WindowSize.of(context) == WindowSize.expanded;
    final nav = _SectionNav(
      selected: _section,
      vertical: wide,
      onSelected: (s) => setState(() => _section = s),
    );
    return Theme(
      data: AppTheme.build(appearance),
      child: MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(_textScale)),
        child: Builder(
          builder: (context) => Screen(
            title: 'Catalogue',
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Toolbar(
                  scrolls: !wide,
                  appearance: appearance,
                  textScale: _textScale,
                  onChanged: (a) => setState(() => _appearance = a),
                  onTextScale: (v) => setState(() => _textScale = v),
                ),
                if (!wide) nav,
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (wide) SizedBox(width: 220, child: nav),
                      Expanded(child: _Page(section: _section)),
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

/// The appearance controls, along the top. On narrow windows they stay on
/// one line that scrolls sideways.
class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.scrolls,
    required this.appearance,
    required this.textScale,
    required this.onChanged,
    required this.onTextScale,
  });

  final bool scrolls;
  final Appearance appearance;
  final double textScale;
  final ValueChanged<Appearance> onChanged;
  final ValueChanged<double> onTextScale;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final a = appearance;
    List<Choice<T>> named<T extends Enum>(List<T> values) => [
      for (final v in values) Choice(v, v.name),
    ];
    const padding = EdgeInsets.fromLTRB(
      Spacing.lg,
      Spacing.sm,
      Spacing.lg,
      Spacing.md,
    );
    final controls = Wrap(
      spacing: Spacing.lg,
      runSpacing: Spacing.sm,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        _Labelled(
          label: 'Mode',
          child: SegmentedChoice(
            choices: named(ColorMode.values),
            selected: a.mode,
            onSelected: (v) => onChanged(a.copyWith(mode: v)),
          ),
        ),
        _Labelled(
          label: 'Accent',
          child: _AccentPicker(
            selected: a.accent,
            onSelected: (v) => onChanged(a.copyWith(accent: v)),
          ),
        ),
        _Labelled(
          label: 'Card style',
          child: SegmentedChoice(
            choices: named(CardStyle.values),
            selected: a.cardStyle,
            onSelected: (v) => onChanged(a.copyWith(cardStyle: v)),
          ),
        ),
        _Labelled(
          label: 'Density',
          child: SegmentedChoice(
            choices: named(Density.values),
            selected: a.density,
            onSelected: (v) => onChanged(a.copyWith(density: v)),
          ),
        ),
        _Labelled(
          label: 'Text scale',
          child: SegmentedChoice(
            choices: [
              for (final v in const [1.0, 1.3, 2.0]) Choice(v, '$v×'),
            ],
            selected: textScale,
            onSelected: onTextScale,
          ),
        ),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: scrolls
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: padding,
              child: controls,
            )
          : Padding(padding: padding, child: controls),
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

class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.selected, required this.onSelected});

  final MemukiAccent selected;
  final ValueChanged<MemukiAccent> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: Spacing.xs + 2,
      runSpacing: Spacing.xs,
      children: [
        for (final accent in MemukiAccent.values)
          Pressable(
            onPressed: () => onSelected(accent),
            selected: accent == selected,
            semanticLabel: accent.name,
            borderRadius: BorderRadius.circular(Radii.pill),
            builder: (context, state) => AnimatedContainer(
              duration: Motion.quick,
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
    );
  }
}

/// The list of sections: a sidebar on wide windows, a scrolling row of chips
/// otherwise.
class _SectionNav extends StatelessWidget {
  const _SectionNav({
    required this.selected,
    required this.vertical,
    required this.onSelected,
  });

  final CatalogueSection selected;
  final bool vertical;
  final ValueChanged<CatalogueSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget item(CatalogueSection section) {
      final isSelected = section == selected;
      return Pressable(
        onPressed: () => onSelected(section),
        selected: isSelected,
        borderRadius: BorderRadius.circular(Radii.sm),
        builder: (context, state) => AnimatedContainer(
          duration: Motion.quick,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm + 2,
            vertical: Spacing.xs + 2,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.accent.soft
                : state.hovered
                ? colors.surfaceSunken
                : null,
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Text(
            section.title,
            style: context.type.label.copyWith(
              color: isSelected ? colors.accent.onSoft : colors.textMuted,
            ),
          ),
        ),
      );
    }

    if (!vertical) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.sm,
        ),
        child: Row(
          children: [
            for (final section in CatalogueSection.values) ...[
              item(section),
              const SizedBox(width: Spacing.xs),
            ],
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        for (final (i, section) in CatalogueSection.values.indexed) ...[
          if (i == 0 ||
              CatalogueSection.values[i - 1].group != section.group) ...[
            Padding(
              padding: EdgeInsets.fromLTRB(
                Spacing.sm + 2,
                i == 0 ? 0 : Spacing.md,
                0,
                Spacing.xs,
              ),
              child: Text(
                section.group,
                style: context.type.caption.copyWith(color: colors.textMuted),
              ),
            ),
          ],
          item(section),
        ],
      ],
    );
  }
}

/// One section: its title and its specimens.
class _Page extends StatelessWidget {
  const _Page({required this.section});

  final CatalogueSection section;

  @override
  Widget build(BuildContext context) {
    final specimens = switch (section) {
      CatalogueSection.colours => _colours(context),
      CatalogueSection.type => _type(context),
      CatalogueSection.shape => _shape(context),
      CatalogueSection.buttons => _buttons(context),
      CatalogueSection.grades => _grades(context),
      CatalogueSection.lists => _lists(context),
      CatalogueSection.choices => _choices(context),
      CatalogueSection.indicators => _indicators(context),
      CatalogueSection.panels => _panels(context),
      CatalogueSection.home => _home(context),
      CatalogueSection.study => _study(context),
    };
    return ListView(
      key: ValueKey(section),
      padding: const EdgeInsets.all(Spacing.lg),
      children: [
        Text(
          section.group,
          style: context.type.caption.copyWith(color: context.colors.textMuted),
        ),
        Text(section.title, style: context.type.display),
        const SizedBox(height: Spacing.lg),
        for (final (i, specimen) in specimens.indexed) ...[
          Entrance(index: i, child: specimen),
          const SizedBox(height: Spacing.xl),
        ],
      ],
    );
  }
}

/// A named example, with a note on when to use it.
class _Specimen extends StatelessWidget {
  const _Specimen({required this.name, required this.child, this.note});

  final String name;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: context.type.heading),
        if (note != null)
          Text(
            note!,
            style: context.type.body.copyWith(color: colors.textMuted),
          ),
        const SizedBox(height: Spacing.md),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: child,
        ),
      ],
    );
  }
}

/// A labelled colour chip.
class _ColourChip extends StatelessWidget {
  const _ColourChip({required this.name, required this.color, this.on});

  final String name;
  final Color color;

  /// A colour shown on top, such as the text colour for a background.
  final Color? on;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(Radii.sm),
              border: Border.all(color: colors.border),
            ),
            child: on == null
                ? null
                : Text(
                    'Aa',
                    style: context.type.bodyStrong.copyWith(color: on),
                  ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            name,
            style: context.type.caption.copyWith(color: colors.textMuted),
          ),
        ],
      ),
    );
  }
}

Widget _chips(List<Widget> children) =>
    Wrap(spacing: Spacing.sm, runSpacing: Spacing.md, children: children);

List<Widget> _colours(BuildContext context) {
  final c = context.colors;
  List<Widget> tone(String name, ToneColors t) => [
    _ColourChip(name: name, color: t.base, on: t.onBase),
    _ColourChip(name: '$name soft', color: t.soft, on: t.onSoft),
  ];
  return [
    _Specimen(
      name: 'Surfaces and text',
      note: 'The desk, the paper on it, and the ink.',
      child: _chips([
        _ColourChip(name: 'background', color: c.background, on: c.text),
        _ColourChip(name: 'surface', color: c.surface, on: c.text),
        _ColourChip(name: 'raised', color: c.surfaceRaised, on: c.text),
        _ColourChip(name: 'sunken', color: c.surfaceSunken, on: c.textMuted),
        _ColourChip(name: 'border', color: c.border),
        _ColourChip(name: 'text', color: c.text),
        _ColourChip(name: 'muted', color: c.textMuted),
        _ColourChip(name: 'faint', color: c.textFaint),
      ]),
    ),
    _Specimen(
      name: 'Accent',
      note: 'Primary actions, selection, and focus. Chosen by the user.',
      child: _chips(tone('accent', c.accent)),
    ),
    _Specimen(
      name: 'Swatches',
      note: 'Colours decks and tags can carry.',
      child: _chips([
        for (final MapEntry(:key, :value) in c.swatches.entries)
          _ColourChip(name: key.name, color: value.base, on: value.onBase),
      ]),
    ),
    _Specimen(
      name: 'Grades and states',
      child: _chips([
        ...tone('again', c.again),
        ...tone('hard', c.hard),
        ...tone('good', c.good),
        ...tone('easy', c.easy),
        ...tone('burned', c.burned),
      ]),
    ),
  ];
}

List<Widget> _type(BuildContext context) {
  final t = context.type;
  final muted = t.caption.copyWith(color: context.colors.textMuted);
  final styles = [
    ('display', 'Zen Maru Gothic 32', t.display, 'Good morning! おはよう'),
    ('title', 'Zen Maru Gothic 24', t.title, 'Japanese Vocabulary · 日本語'),
    ('heading', 'Zen Maru Gothic 19', t.heading, 'Recent decks · 今日の復習'),
    ('body', 'Noto Sans JP 16', t.body, 'Notes generate cards. 漢字とかな'),
    ('body strong', 'Noto Sans JP 16 semibold', t.bodyStrong, '42 due today'),
    ('label', 'Noto Sans JP 14 semibold', t.label, 'Start studying'),
    ('caption', 'Noto Sans JP 12.5', t.caption, 'Last studied 2 hours ago'),
  ];
  return [
    _Specimen(
      name: 'Scale',
      note: 'Headings use Zen Maru Gothic; everything else Noto Sans JP.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (name, spec, style, sample) in styles)
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$name · $spec', style: muted),
                  Text(sample, style: style),
                ],
              ),
            ),
        ],
      ),
    ),
  ];
}

List<Widget> _shape(BuildContext context) {
  final c = context.colors;
  final muted = context.type.caption.copyWith(color: c.textMuted);
  return [
    _Specimen(
      name: 'Radii',
      note: 'Nested shapes use a smaller radius than their container.',
      child: _chips([
        for (final (name, r) in const [
          ('xs', Radii.xs),
          ('sm', Radii.sm),
          ('md', Radii.md),
          ('lg', Radii.lg),
          ('xl', Radii.xl),
        ])
          Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: c.accent.soft,
                  borderRadius: BorderRadius.circular(r),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text('$name · ${r.toInt()}', style: muted),
            ],
          ),
      ]),
    ),
    _Specimen(
      name: 'Spacing',
      note: 'A 4 px scale.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (name, s) in const [
            ('xs', Spacing.xs),
            ('sm', Spacing.sm),
            ('md', Spacing.md),
            ('lg', Spacing.lg),
            ('xl', Spacing.xl),
            ('xxl', Spacing.xxl),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.xs),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text('$name · ${s.toInt()}', style: muted),
                  ),
                  Container(width: s, height: 12, color: c.accent.base),
                ],
              ),
            ),
        ],
      ),
    ),
    const _Specimen(
      name: 'Paper',
      note: 'Panels and cards lie on the desk with a soft shadow.',
      child: Panel(child: Text('A panel')),
    ),
  ];
}

List<Widget> _buttons(BuildContext context) => [
  _Specimen(
    name: 'Button',
    note:
        'Primary for the main action of a screen or panel; secondary for '
        'the others.',
    child: _chips([
      Button(
        label: 'Start studying',
        icon: MemukiIcons.study,
        onPressed: () {},
      ),
      Button(
        label: 'Add to library',
        icon: MemukiIcons.add,
        kind: ButtonKind.secondary,
        onPressed: () {},
      ),
      const Button(label: 'Disabled', onPressed: null),
    ]),
  ),
  _Specimen(
    name: 'Expanded',
    note: 'Fills the width, for the one action at the bottom of a panel.',
    child: Button(
      label: 'Start studying',
      icon: MemukiIcons.study,
      expand: true,
      onPressed: () {},
    ),
  ),
  _Specimen(
    name: 'QuietButton',
    note: 'Low emphasis, such as "See all" next to a heading.',
    child: _chips([
      QuietButton(label: 'See all', onPressed: () {}),
      QuietButton(label: 'Edit', icon: MemukiIcons.edit, onPressed: () {}),
    ]),
  ),
];

List<Widget> _grades(BuildContext context) {
  final c = context.colors;
  return [
    _Specimen(
      name: 'GradeButton',
      note: 'The four grades while studying, with the interval each leads to.',
      child: _GradeRow(colors: c),
    ),
  ];
}

class _GradeRow extends StatelessWidget {
  const _GradeRow({required this.colors});

  final MemukiColors colors;

  @override
  Widget build(BuildContext context) {
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
            child: GradeButton(
              label: label,
              interval: interval,
              tone: tone,
              onPressed: () {},
            ),
          ),
        ],
      ],
    );
  }
}

List<Widget> _deckRows(BuildContext context) {
  final swatches = context.colors.swatches;
  return [
    for (final (name, due, swatch) in const [
      ('Japanese Vocabulary', '32 due', MemukiAccent.coral),
      ('N2 Kanji', '18 due', MemukiAccent.green),
      ('Genki 1', '4 due', MemukiAccent.mustard),
      ('Travel Phrases', '0 due', MemukiAccent.blue),
    ])
      ListRow(
        title: name,
        subtitle: due,
        leading: Swatch(color: swatches[swatch]!.base),
        onTap: () {},
      ),
  ];
}

List<Widget> _lists(BuildContext context) => [
  _Specimen(
    name: 'RowGroup of ListRows',
    note: 'Rows on one panel. Tappable rows show a chevron.',
    child: RowGroup(children: _deckRows(context)),
  ),
  _Specimen(
    name: 'Row variants',
    child: RowGroup(
      children: [
        const ListRow(title: 'Title only'),
        const ListRow(title: 'With a subtitle', subtitle: 'Secondary detail'),
        ListRow(
          title: 'Own trailing element',
          trailing: const Tag(label: '42'),
          onTap: () {},
        ),
      ],
    ),
  ),
];

List<Widget> _choices(BuildContext context) => [
  const _Specimen(
    name: 'SegmentedChoice',
    note: 'Picks one of a few options. Wraps when space is tight.',
    child: _ChoiceDemo(),
  ),
];

class _ChoiceDemo extends StatefulWidget {
  const _ChoiceDemo();

  @override
  State<_ChoiceDemo> createState() => _ChoiceDemoState();
}

class _ChoiceDemoState extends State<_ChoiceDemo> {
  String _theme = 'system';
  String _order = 'mixed';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedChoice(
          choices: const [
            Choice('system', 'System', icon: MemukiIcons.systemTheme),
            Choice('light', 'Light', icon: MemukiIcons.lightTheme),
            Choice('dark', 'Dark', icon: MemukiIcons.darkTheme),
          ],
          selected: _theme,
          onSelected: (v) => setState(() => _theme = v),
        ),
        const SizedBox(height: Spacing.md),
        SegmentedChoice(
          choices: const [
            Choice('mixed', 'Mixed'),
            Choice('reviews', 'Reviews first'),
            Choice('new', 'New first'),
          ],
          selected: _order,
          onSelected: (v) => setState(() => _order = v),
        ),
      ],
    );
  }
}

List<Widget> _indicators(BuildContext context) {
  final c = context.colors;
  return [
    _Specimen(
      name: 'Tag',
      note: 'Neutral for a note\'s tags; coloured for states and levels.',
      child: _chips([
        const Tag(label: 'vocabulary'),
        const Tag(label: 'nouns'),
        Tag(label: 'JLPT N5', tone: c.swatches[MemukiAccent.green]),
        Tag(label: 'leech', tone: c.again),
        Tag(label: 'burned', tone: c.burned),
      ]),
    ),
    const _Specimen(
      name: 'ProgressLine',
      note: 'Progress through a session or toward a goal.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProgressLine(value: 12 / 42, label: '12 of 42'),
          SizedBox(height: Spacing.md),
          ProgressLine(value: 0.85, label: '85%'),
        ],
      ),
    ),
  ];
}

List<Widget> _panels(BuildContext context) => [
  _Specimen(
    name: 'SectionHeader',
    note: 'A heading above a group, with an optional action.',
    child: SectionHeader(
      title: 'Recent decks',
      action: QuietButton(label: 'See all', onPressed: () {}),
    ),
  ),
  _Specimen(
    name: 'Panel',
    note: 'Groups related content on paper. Padding follows the density.',
    child: Panel(
      child: Text(
        'Panels hold the content of a screen: a summary, a form, a list.',
        style: context.type.body,
      ),
    ),
  ),
];

List<Widget> _home(BuildContext context) {
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
  return [
    _Specimen(
      name: 'Today',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Mon, 24 Mar', style: muted),
          Text('Good morning!', style: type.display),
          Text(
            'A little progress goes a long way.',
            style: type.body.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: Spacing.md),
          Panel(
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
                Button(
                  label: 'Start studying',
                  icon: MemukiIcons.study,
                  expand: true,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.lg),
          SectionHeader(
            title: 'Recent decks',
            action: QuietButton(label: 'See all', onPressed: () {}),
          ),
          RowGroup(children: _deckRows(context)),
        ],
      ),
    ),
  ];
}

List<Widget> _study(BuildContext context) => [
  _Specimen(
    name: 'Review',
    note:
        'The card follows the card style setting. Becomes the card '
        'renderer\'s job.',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProgressLine(value: 12 / 42, label: '12 of 42'),
        const SizedBox(height: Spacing.lg),
        const _StudyCard(),
        const SizedBox(height: Spacing.lg),
        _GradeRow(colors: context.colors),
      ],
    ),
  ),
];

/// The study card in the chosen card style.
class _StudyCard extends StatelessWidget {
  const _StudyCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final type = context.type;
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
            child: Tag(
              label: 'N5',
              tone: colors.swatches[MemukiAccent.mustard],
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
          Icon(MemukiIcons.audio, color: colors.textMuted),
          const SizedBox(height: Spacing.md),
          Text('cat', textAlign: TextAlign.center, style: type.title),
        ],
      ),
    );
    return switch (context.layout.cardStyle) {
      CardStyle.minimal => content,
      CardStyle.standard => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: colors.border),
          boxShadow: paperShadow(colors),
        ),
        child: content,
      ),
      CardStyle.notecard => DecoratedBox(
        decoration: ShapeDecoration(
          color: colors.surface,
          shape: const _FoldedCorner(),
          shadows: paperShadow(colors),
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
    // The back of the paper: a shade towards the ink, so lighter in dark
    // mode and darker on paper.
    canvas.drawPath(
      flap,
      Paint()..color = Color.lerp(colors.surface, colors.text, 0.08)!,
    );
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

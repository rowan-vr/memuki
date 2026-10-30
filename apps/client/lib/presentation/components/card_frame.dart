import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/memuki_colors.dart';
import '../theme/memuki_layout.dart';
import '../theme/radii.dart';
import '../theme/spacing.dart';
import 'panel.dart';

/// The paper a study card is drawn on, in the user's card style: a ruled
/// notecard with a folded corner, a plain rounded card, or no frame at all.
class CardFrame extends StatelessWidget {
  const CardFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return switch (context.layout.cardStyle) {
      CardStyle.minimal => child,
      CardStyle.standard => Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border: Border.all(color: colors.border),
          boxShadow: paperShadow(colors),
        ),
        child: child,
      ),
      CardStyle.notecard => DecoratedBox(
        decoration: ShapeDecoration(
          color: colors.surface,
          shape: const _FoldedCorner(),
          shadows: paperShadow(colors),
        ),
        child: CustomPaint(
          foregroundPainter: _NotecardPainter(colors),
          child: child,
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

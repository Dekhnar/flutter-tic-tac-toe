import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/design_system/components/lists/right_side_slider.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';

/// Where a pane sits: [offset] is its item's position relative to the highlighted one.
enum SliderSlot {
  top(-1, Alignment.topCenter),
  center(0, Alignment.center),
  bottom(1, Alignment.bottomCenter);

  const SliderSlot(this.offset, this.alignment);

  final int offset;
  final Alignment alignment;

  /// Where the pane goes during a swipe; null when it leaves the slider.
  SliderSlot? next({required bool swipesUp}) => switch ((this, swipesUp)) {
    (top, true) || (bottom, false) => null,
    (center, true) || (bottom, true) => SliderSlot.values[index - 1],
    (top, false) || (center, false) => SliderSlot.values[index + 1],
  };
}

/// One pane, moving to its next slot as [swipe] runs. The middle slot has the highlighted colours.
class SliderPane<T> extends StatelessWidget {
  const SliderPane({
    super.key,
    required this.ctaLabel,
    required this.item,
    required this.onSelected,
    required this.slot,
    required this.swipe,
    required this.swipesUp,
  });

  final String ctaLabel;
  final SliderItem<T> item;
  final ValueChanged<T> onSelected;
  final SliderSlot slot;
  final Animation<double> swipe;
  final bool swipesUp;

  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.horizontal(left: Radius.circular(Dimens.largeRadius)),
  );

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final next = slot.next(swipesUp: swipesUp);
    (Color, Color) colorsAt(SliderSlot? slot) => switch (slot) {
      SliderSlot.center => (colors.primary, colors.onPrimary),
      _ => (colors.surfaceContainerLow, colors.primary),
    };
    final (fromBackground, fromForeground) = colorsAt(slot);
    final (toBackground, toForeground) = colorsAt(next ?? slot);
    final background = ColorTween(begin: fromBackground, end: toBackground).animate(swipe);
    final foreground = ColorTween(begin: fromForeground, end: toForeground).animate(swipe);

    return AlignTransition(
      alignment: AlignmentTween(begin: slot.alignment, end: (next ?? slot).alignment).animate(swipe),
      child: FadeTransition(
        opacity: next == null ? ReverseAnimation(swipe) : kAlwaysCompleteAnimation,
        child: FractionallySizedBox(
          heightFactor: 1 / SliderSlot.values.length,
          widthFactor: 1,
          child: AnimatedBuilder(
            animation: swipe,
            builder:
                (context, _) => _PaneCard(
                  background: background.value ?? fromBackground,
                  ctaLabel: ctaLabel,
                  foreground: foreground.value ?? fromForeground,
                  item: item,
                  onTap: () => onSelected(item.value),
                ),
          ),
        ),
      ),
    );
  }
}

/// The whole pane is one button: the call to action only shows what tapping it does.
class _PaneCard extends StatelessWidget {
  const _PaneCard({
    required this.background,
    required this.ctaLabel,
    required this.foreground,
    required this.item,
    required this.onTap,
  });

  final Color background;
  final String ctaLabel;
  final Color foreground;
  final SliderItem<Object?> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Material(
      clipBehavior: Clip.antiAlias,
      color: background,
      elevation: 2,
      shape: SliderPane._shape,
      child: MergeSemantics(
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimens.standardPadding),
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: textTheme.titleLarge?.copyWith(color: foreground)),
                    Text(item.description, style: textTheme.bodySmall?.copyWith(color: foreground)),
                    const SizedBox(height: Dimens.halfSpacing),
                    DecoratedBox(
                      decoration: ShapeDecoration(color: foreground, shape: const StadiumBorder()),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Dimens.standardPadding,
                          vertical: Dimens.halfPadding,
                        ),
                        child: Text(ctaLabel, style: textTheme.labelLarge?.copyWith(color: background)),
                      ),
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

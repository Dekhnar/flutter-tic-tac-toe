import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/design_system/components/lists/slider_pane.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';

final class SliderItem<T> {
  const SliderItem({required this.description, required this.title, required this.value});

  final String description;
  final String title;
  final T value;
}

/// Three panes stacked on the right edge, the middle one highlighted; a vertical swipe turns them, wrapping around
/// [items]. Tapping a pane selects its item.
class RightSideSlider<T> extends StatefulWidget {
  const RightSideSlider({super.key, required this.ctaLabel, required this.items, required this.onSelected});

  final String ctaLabel;
  final List<SliderItem<T>> items;
  final ValueChanged<T> onSelected;

  @override
  State<RightSideSlider<T>> createState() => _RightSideSliderState<T>();
}

class _RightSideSliderState<T> extends State<RightSideSlider<T>> with SingleTickerProviderStateMixin {
  static const _swipeDuration = Duration(milliseconds: 400);

  /// A drag longer than this, or flung faster, turns the panes.
  static const _swipeDistance = 48.0;
  static const _swipeVelocity = 300.0;

  late final _swipe = AnimationController(vsync: this, duration: _swipeDuration)..addStatusListener(_onSwipeStatus);
  late int _centerIndex = widget.items.length > 1 ? 1 : 0;
  double _dragDistance = 0;
  bool _swipesUp = false;

  @override
  void didUpdateWidget(RightSideSlider<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.isNotEmpty) _centerIndex = _wrap(_centerIndex);
  }

  @override
  void dispose() {
    _swipe.dispose();
    super.dispose();
  }

  int _wrap(int index) => index % widget.items.length;

  void _onSwipeStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed) return;

    setState(() => _centerIndex = _wrap(_centerIndex + (_swipesUp ? 1 : -1)));
    _swipe.reset();
  }

  void _onDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    final distance = _dragDistance;
    _dragDistance = 0;
    if (_swipe.isAnimating || widget.items.length < 2) return;
    if (distance.abs() < _swipeDistance && velocity.abs() < _swipeVelocity) return;

    setState(() => _swipesUp = (distance.abs() >= _swipeDistance ? distance : velocity) < 0);
    _swipe.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      // The distance counts from where the finger landed, the slop included.
      dragStartBehavior: DragStartBehavior.down,
      onVerticalDragStart: (_) => _dragDistance = 0,
      onVerticalDragUpdate: (details) => _dragDistance += details.delta.dy,
      onVerticalDragEnd: _onDragEnd,
      child: SizedBox(
        width: Dimens.sliderWidth,
        child: Stack(
          children: [
            for (final slot in SliderSlot.values)
              SliderPane<T>(
                ctaLabel: widget.ctaLabel,
                item: widget.items[_wrap(_centerIndex + slot.offset)],
                onSelected: widget.onSelected,
                slot: slot,
                swipe: _swipe,
                swipesUp: _swipesUp,
              ),
          ],
        ),
      ),
    );
  }
}

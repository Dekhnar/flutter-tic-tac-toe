import 'package:flutter/material.dart';
import 'package:tic_tac_toe_app/design_system/components/data_display/base/card.dart';
import 'package:tic_tac_toe_app/design_system/foundations/dimens.dart';

class SliderItem<T> {
  final String title;
  final String description;
  final T value;

  const SliderItem({required this.title, required this.description, required this.value});
}

typedef OnPaneTap = void Function(int index);

class RightSideSlider extends StatefulWidget {
  final List<SliderItem> items;
  final String ctaLabel;
  final OnPaneTap? onPaneTap;

  const RightSideSlider({super.key, required this.items, this.onPaneTap, required this.ctaLabel});

  @override
  State<RightSideSlider> createState() => _RightSideSliderState();
}

class _RightSideSliderState extends State<RightSideSlider> with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  bool _isSwipeUp = false;

  static const _swipeDuration = Duration(milliseconds: 400);
  static const _swipeSensitivity = 8;

  late final AnimationController _swipeController = AnimationController(vsync: this, duration: _swipeDuration)
    ..addStatusListener(_onSwipeTransitionStatusChanged);

  int _getIndexBackward(int i) => i == 0 ? 2 : i - 1;
  int _getIndexForward(int i) => i == 2 ? 0 : i + 1;

  void _onSwipeTransitionStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _currentIndex = _isSwipeUp ? _getIndexForward(_currentIndex) : _getIndexBackward(_currentIndex);
      });
      _swipeController.reset();
    }
  }

  void _animateSwipe({required bool up}) {
    if (_swipeController.isAnimating) return;
    setState(() => _isSwipeUp = up);
    _swipeController.forward(from: 0);
  }

  void _onVerticalDrag(DragUpdateDetails details) {
    if (details.delta.dy.abs() >= _swipeSensitivity) {
      _animateSwipe(up: details.delta.dy < 0);
    }
  }

  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDrag,
      child: AnimatedBuilder(
        animation: _swipeController,
        builder: (_, __) {
          final progress = _swipeController.value;
          return Container(
            constraints: BoxConstraints.tightFor(width: 600),
            child: Stack(
              children: [
                _SliderPaneLayout(
                  position: _SliderPanePosition.top,
                  progress: progress,
                  isSwipeUp: _isSwipeUp,
                  child: _SliderPaneCard(
                    ctaLabel: widget.ctaLabel,
                    item: widget.items[_getIndexBackward(_currentIndex)],
                    onPaneTap: () => widget.onPaneTap?.call(_getIndexBackward(_currentIndex)),
                  ),
                ),
                _SliderPaneLayout(
                  position: _SliderPanePosition.center,
                  progress: progress,
                  isSwipeUp: _isSwipeUp,
                  child: _SliderPaneCard(
                    ctaLabel: widget.ctaLabel,
                    item: widget.items[_currentIndex],
                    onPaneTap: () => widget.onPaneTap?.call(_currentIndex),
                  ),
                ),
                _SliderPaneLayout(
                  position: _SliderPanePosition.bottom,
                  progress: progress,
                  isSwipeUp: _isSwipeUp,
                  child: _SliderPaneCard(
                    ctaLabel: widget.ctaLabel,
                    item: widget.items[_getIndexForward(_currentIndex)],
                    onPaneTap: () => widget.onPaneTap?.call(_getIndexForward(_currentIndex)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum _SliderPanePosition { top, center, bottom }

class _SliderPaneLayout extends StatelessWidget {
  final _SliderPanePosition position;
  final double progress;
  final bool isSwipeUp;
  final Widget child;

  const _SliderPaneLayout({
    required this.position,
    required this.progress,
    required this.isSwipeUp,
    required this.child,
  });

  static final _whiteToGreenTween = ColorTween(begin: Colors.white, end: Colors.green);
  static final _greenToWhiteTween = ColorTween(begin: Colors.green, end: Colors.white);

  Color? get _cardColor => switch (position) {
    _SliderPanePosition.top || _SliderPanePosition.bottom => _whiteToGreenTween,
    _SliderPanePosition.center => _greenToWhiteTween,
  }.transform(progress);

  Color? get _textColor => switch (position) {
    _SliderPanePosition.top || _SliderPanePosition.bottom => _greenToWhiteTween,
    _SliderPanePosition.center => _whiteToGreenTween,
  }.transform(progress);

  double get _currentOpacity {
    final bool isExitingForSwipe = switch ((position, isSwipeUp)) {
      (_SliderPanePosition.top, true) || (_SliderPanePosition.bottom, false) => true,
      _ => false,
    };
    return isExitingForSwipe ? 1 - progress : 1.0;
  }

  Alignment get _currentAlignment {
    const slotAlignments = [Alignment.topCenter, Alignment.center, Alignment.bottomCenter];
    final positionIndex = switch (position) {
      _SliderPanePosition.top => 0,
      _SliderPanePosition.center => 1,
      _SliderPanePosition.bottom => 2,
    };

    final startAlignment = slotAlignments[positionIndex];
    final endAlignment = switch (isSwipeUp) {
      true => switch (position) {
        _SliderPanePosition.top => null,
        _SliderPanePosition.center || _SliderPanePosition.bottom => slotAlignments[positionIndex - 1],
      },
      false => switch (position) {
        _SliderPanePosition.bottom => null,
        _SliderPanePosition.center || _SliderPanePosition.top => slotAlignments[positionIndex + 1],
      },
    };

    if (endAlignment == null) return startAlignment;
    return switch (Alignment.lerp(startAlignment, endAlignment, progress)) {
      null =>
        throw StateError(
          'Alignment.lerp returned null (start=$startAlignment, end=$endAlignment, t=${progress.toStringAsFixed(3)}, pos=$position, up=$isSwipeUp)',
        ),
      final alignment => alignment,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: Theme.of(context).textTheme.apply(bodyColor: _textColor, displayColor: _textColor),
        cardTheme: CardTheme.of(context).copyWith(
          color: _cardColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(left: Radius.circular(Dimens.largeRadius)),
          ),
        ),
      ),
      child: Align(
        alignment: _currentAlignment,
        child: Opacity(opacity: _currentOpacity, child: FractionallySizedBox(heightFactor: 0.33, child: child)),
      ),
    );
  }
}

class _SliderPaneCard extends StatelessWidget {
  const _SliderPaneCard({required this.item, required this.onPaneTap, required this.ctaLabel});

  final SliderItem item;
  final String ctaLabel;
  final VoidCallback onPaneTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: BaseCardButton(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.standardPadding),
        onTap: onPaneTap,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            Text(item.description, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Dimens.halfPadding),
            ElevatedButton(
              onPressed: onPaneTap,
              child: Text(ctaLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

enum BaseAnimatedEffect { fadeIn, zoomIn, zoomOut, topDown, rive, flare, static, lottie }

class BaseAnimatedSplash extends StatefulWidget {
  final Function? next;
  final String imagePath;
  final int duration;
  final BaseAnimatedEffect animationEffect;
  final BoxFit boxFit;

  const BaseAnimatedSplash({
    super.key,
    this.next,
    required this.imagePath,
    this.animationEffect = BaseAnimatedEffect.fadeIn,
    this.duration = 1000,
    this.boxFit = BoxFit.contain,
  });

  @override
  State<StatefulWidget> createState() => BaseAnimatedSplashState();
}

class BaseAnimatedSplashState extends State<BaseAnimatedSplash> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  static const size = Size(86, 86);
  late final imageWidget = Image.asset(widget.imagePath, fit: widget.boxFit, height: size.height, width: size.width);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.reset();
    _controller.forward();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: widget.duration));
    _animation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCubic));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 100)).then((value) => widget.next?.call());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.reset();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.animationEffect) {
      BaseAnimatedEffect.fadeIn => FadeTransition(opacity: _animation, child: imageWidget),
      BaseAnimatedEffect.zoomIn => ScaleTransition(scale: _animation, child: imageWidget),
      BaseAnimatedEffect.zoomOut => ScaleTransition(
        scale: Tween(begin: 2.1, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInCirc)),
        child: imageWidget,
      ),
      BaseAnimatedEffect.topDown || _ => SizeTransition(sizeFactor: _animation, child: imageWidget),
    };
  }
}

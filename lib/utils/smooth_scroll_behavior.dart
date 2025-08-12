import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

/// Custom scroll behavior pentru smooth scrolling cu mouse wheel
/// Implementeaza o scrollare fluida si naturala pentru desktop
class SmoothScrollBehavior extends MaterialScrollBehavior {
  /// Multiplicator pentru viteza de scroll cu mouse wheel
  static const double scrollSpeedMultiplier = 0.3;
  
  /// Factor de amortizare pentru smooth scroll
  static const double dampingFactor = 0.8;

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // Foloseste BouncingScrollPhysics pentru o experienta mai fluida
    return const BouncingScrollPhysics();
  }

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    // Personalizeaza scrollbar-ul pentru o experienta mai buna
    return RawScrollbar(
      controller: details.controller,
      thickness: 8.0,
      radius: const Radius.circular(4.0),
      thumbColor: Colors.grey.withAlpha(60),
      trackColor: Colors.grey.withAlpha(20),
      trackRadius: const Radius.circular(4.0),
      child: child,
    );
  }

  // Removed override since this method doesn't exist in MaterialScrollBehavior
  // Widget buildViewportChrome(BuildContext context, Widget child, AxisDirection axisDirection) {
  //   return child;
  // }
}

/// Custom scroll physics pentru smooth scrolling
class SmoothScrollPhysics extends BouncingScrollPhysics {
  const SmoothScrollPhysics({super.parent});

  @override
  SmoothScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SmoothScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double get minFlingVelocity => 50.0;

  @override
  double get maxFlingVelocity => 8000.0;

  @override
  Tolerance get tolerance => const Tolerance(
    velocity: 1.0,
    distance: 0.5,
  );

  @override
  double carriedMomentum(double existingVelocity) {
    // Reduce carried momentum pentru o scrollare mai controlata
    return existingVelocity * 0.8;
  }

  @override
  double get dragStartDistanceMotionThreshold => 3.0;
}

/// Wrapper widget pentru smooth scrolling cu rotita mouse pe desktop
/// Intercepteaza evenimentele de scroll si le transforma in animatii fluide
class SmoothScrollWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;
  final double scrollSpeed;
  final Duration animationDuration;

  const SmoothScrollWrapper({
    super.key,
    required this.child,
    this.controller,
    this.scrollSpeed = 100.0,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<SmoothScrollWrapper> createState() => _SmoothScrollWrapperState();
}

class _SmoothScrollWrapperState extends State<SmoothScrollWrapper>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (PointerSignalEvent event) {
        if (event is PointerScrollEvent && widget.controller != null) {
          _handleScroll(event);
        }
      },
      child: widget.child,
    );
  }

  void _handleScroll(PointerScrollEvent event) {
    final controller = widget.controller;
    if (controller == null || !controller.hasClients) return;

    // Opreste animatia curenta daca exista
    _animationController.stop();

    // Calculeaza pozitia curenta si noua pozitie
    final currentPosition = controller.position.pixels;
    final scrollDelta = event.scrollDelta.dy;
    final newPosition = (currentPosition + scrollDelta * widget.scrollSpeed / 100)
        .clamp(0.0, controller.position.maxScrollExtent);

    // Creeaza animatia smooth
    _animation = Tween<double>(
      begin: currentPosition,
      end: newPosition,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Listener pentru actualizarea pozitiei
    _animation!.addListener(() {
      if (controller.hasClients) {
        controller.jumpTo(_animation!.value);
      }
    });

    // Porneste animatia
    _animationController.reset();
    _animationController.forward();
  }
}

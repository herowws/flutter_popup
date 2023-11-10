part of flutter_popup;

enum _ArrowDirection { top, bottom }

class CustomPopup extends StatelessWidget {
  final GlobalKey? anchorKey;
  final Widget content;
  final Widget child;
  final bool isLongPress;
  final Color? backgroundColor;
  final Color? arrowColor;
  final Color? barrierColor;
  final bool showArrow;

  const CustomPopup({
    super.key,
    required this.content,
    required this.child,
    this.anchorKey,
    this.isLongPress = false,
    this.backgroundColor,
    this.arrowColor,
    this.showArrow = true,
    this.barrierColor,
  });

  void _show(BuildContext context) {
    final anchor = anchorKey?.currentContext ?? context;
    final renderBox = anchor.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);
    Navigator.of(context).push(_PopupRoute(
      targetRect: offset & renderBox.paintBounds.size,
      backgroundColor: backgroundColor,
      arrowColor: arrowColor,
      showArrow: showArrow,
      barriersColor: barrierColor,
      child: content,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onLongPress: isLongPress ? () => _show(context) : null,
      onTapUp: !isLongPress ? (_) => _show(context) : null,
      child: child,
    );
  }
}

class _PopupContent extends StatelessWidget {
  final Widget child;
  final GlobalKey childKey;
  final GlobalKey arrowKey;
  final _ArrowDirection arrowDirection;
  final double arrowHorizontal;
  final Color? backgroundColor;
  final Color? arrowColor;
  final bool showArrow;

  const _PopupContent({
    Key? key,
    required this.child,
    required this.childKey,
    required this.arrowKey,
    required this.arrowHorizontal,
    required this.showArrow,
    this.arrowDirection = _ArrowDirection.top,
    this.backgroundColor,
    this.arrowColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          key: childKey,
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.symmetric(vertical: 10).copyWith(
            top: arrowDirection == _ArrowDirection.bottom ? 0 : null,
            bottom: arrowDirection == _ArrowDirection.top ? 0 : null,
          ),
          constraints: const BoxConstraints(minWidth: 50),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
              ),
            ],
          ),
          child: child,
        ),
        Positioned(
          top: arrowDirection == _ArrowDirection.top ? 2 : null,
          bottom: arrowDirection == _ArrowDirection.bottom ? 2 : null,
          left: arrowHorizontal,
          child: RotatedBox(
            key: arrowKey,
            quarterTurns: arrowDirection == _ArrowDirection.top ? 2 : 4,
            child: CustomPaint(
              size: showArrow ? const Size(16, 8) : Size.zero,
              painter: _TrianglePainter(color: arrowColor ?? Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final path = Path();
    paint.isAntiAlias = true;
    paint.color = color;

    path.lineTo(size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.58, size.height * 1.05, size.width * 0.42,
        size.height * 1.05, size.width * 0.34, size.height * 0.86);
    path.cubicTo(size.width * 0.34, size.height * 0.86, 0, 0, 0, 0);
    path.cubicTo(0, 0, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, size.width * 0.66, size.height * 0.86,
        size.width * 0.66, size.height * 0.86);
    path.cubicTo(size.width * 0.66, size.height * 0.86, size.width * 0.66,
        size.height * 0.86, size.width * 0.66, size.height * 0.86);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _PopupRoute extends PopupRoute<void> {
  final Rect targetRect;
  final Widget child;

  static const double _margin = 10;
  static final Rect _viewportRect = Rect.fromLTWH(
    _margin,
    Screen.statusBar + _margin,
    Screen.width - _margin * 2,
    Screen.height - Screen.statusBar - Screen.bottomBar - _margin * 2,
  );

  final GlobalKey _childKey = GlobalKey();
  final GlobalKey _arrowKey = GlobalKey();
  final Color? backgroundColor;
  final Color? arrowColor;
  final bool showArrow;
  final Color? barriersColor;

  double _maxHeight = _viewportRect.height;
  _ArrowDirection _arrowDirection = _ArrowDirection.top;
  double _arrowHorizontal = 0;
  double _scaleAlignDx = 0.5;
  double _scaleAlignDy = 0.5;
  double? _bottom;
  double? _top;
  double? _left;
  double? _right;

  _PopupRoute({
    RouteSettings? settings,
    ImageFilter? filter,
    TraversalEdgeBehavior? traversalEdgeBehavior,
    required this.child,
    required this.targetRect,
    this.backgroundColor,
    this.arrowColor,
    required this.showArrow,
    this.barriersColor,
  }) : super(
          settings: settings,
          filter: filter,
          traversalEdgeBehavior: traversalEdgeBehavior,
        );

  @override
  Color? get barrierColor => barriersColor ?? Colors.black.withOpacity(0.1);

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => 'Popup';

  @override
  TickerFuture didPush() {
    super.offstage = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final childRect = _getRect(_childKey);
      final arrowRect = _getRect(_arrowKey);
      _calculateArrowOffset(arrowRect, childRect);
      _calculateChildOffset(childRect);
      super.offstage = false;
    });
    return super.didPush();
  }

  Rect? _getRect(GlobalKey key) {
    final currentContext = key.currentContext;
    final renderBox = currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;
    final offset = renderBox.localToGlobal(renderBox.paintBounds.topLeft);
    return offset & renderBox.paintBounds.size;
  }

  // Calculate the horizontal position of the arrow
  void _calculateArrowOffset(Rect? arrowRect, Rect? childRect) {
    if (childRect == null || arrowRect == null) return;
    // Calculate the distance from the left side of the screen based on the middle position of the target and the popover layer
    var leftEdge = targetRect.center.dx - childRect.center.dx;
    final rightEdge = leftEdge + childRect.width;
    leftEdge = leftEdge < _viewportRect.left ? _viewportRect.left : leftEdge;
    // If it exceeds the screen, subtract the excess part
    if (rightEdge > _viewportRect.right) {
      leftEdge -= rightEdge - _viewportRect.right;
    }
    final center = targetRect.center.dx - leftEdge - arrowRect.center.dx;
    // Prevent the arrow from extending beyond the padding of the popover
    if (center + arrowRect.center.dx > childRect.width - 15) {
      _arrowHorizontal = center - 15;
    } else if (center < 15) {
      _arrowHorizontal = 15;
    } else {
      _arrowHorizontal = center;
    }

    _scaleAlignDx = (_arrowHorizontal + arrowRect.center.dx) / childRect.width;
  }

  // Calculate the position of the popover
  void _calculateChildOffset(Rect? childRect) {
    if (childRect == null) return;

    // Calculate the vertical position of the popover
    final topHeight = targetRect.top - _viewportRect.top;
    final bottomHeight = _viewportRect.bottom - targetRect.bottom;
    final maximum = max(topHeight, bottomHeight);
    _maxHeight = childRect.height > maximum ? maximum : childRect.height;
    if (_maxHeight > bottomHeight) {
      // Above the target
      _bottom = Screen.height - targetRect.top;
      _arrowDirection = _ArrowDirection.bottom;
      _scaleAlignDy = 1;
    } else {
      // Below the target
      _top = targetRect.bottom;
      _arrowDirection = _ArrowDirection.top;
      _scaleAlignDy = 0;
    }

    // Calculate the vertical position of the popover
    final left = targetRect.center.dx - childRect.center.dx;
    final right = left + childRect.width;
    if (right > _viewportRect.right) {
      // at right
      _right = _margin;
    } else {
      // at left
      _left = left < _margin ? _margin : left;
    }
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return child;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    child = _PopupContent(
      childKey: _childKey,
      arrowKey: _arrowKey,
      arrowHorizontal: _arrowHorizontal,
      arrowDirection: _arrowDirection,
      backgroundColor: backgroundColor,
      arrowColor: arrowColor,
      showArrow: showArrow,
      child: child,
    );
    if (!animation.isCompleted) {
      child = FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          alignment: FractionalOffset(_scaleAlignDx, _scaleAlignDy),
          scale: animation,
          child: child,
        ),
      );
    }
    return Stack(
      children: [
        Positioned(
          left: _left,
          right: _right,
          top: _top,
          bottom: _bottom,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _viewportRect.width,
              maxHeight: _maxHeight,
            ),
            child: Material(
              color: Colors.transparent,
              type: MaterialType.transparency,
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);
}

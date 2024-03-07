part of flutter_popup;

abstract class Screen {
  static MediaQueryData get mediaQuery => MediaQueryData.fromView(
        PlatformDispatcher.instance.views.first,
      );

  /// screen width
  static double get width => mediaQuery.size.width;

  // /screen height
  static double get height => mediaQuery.size.height;

  /// dp
  static double get scale => mediaQuery.devicePixelRatio;

  /// top
  static double get statusBar => mediaQuery.padding.top;

  /// bottom
  static double get bottomBar => mediaQuery.padding.bottom;
}

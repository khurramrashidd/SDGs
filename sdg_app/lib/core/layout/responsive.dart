import 'package:flutter/material.dart';

/// One place that decides how the app adapts to screen size.
///
/// The app runs on a ₹6,000 Android phone (360dp wide, sometimes 320dp),
/// a tablet, and a desktop browser via Flutter web. Rather than scatter
/// `MediaQuery.of(context).size.width > 600` checks through every screen,
/// everything goes through here.
enum ScreenSize {
  /// Small phones - 320 to 359dp. Budget Androids and older devices.
  compact,

  /// Ordinary phones - 360 to 599dp. The common case.
  regular,

  /// Large phones in landscape, small tablets - 600 to 904dp.
  medium,

  /// Tablets and desktop browsers - 905dp and up.
  expanded,
}

class Breakpoints {
  const Breakpoints._();

  static const double compactMax = 360;
  static const double regularMax = 600;
  static const double mediumMax = 905;

  /// Content never stretches past this on a wide browser window. Long lines
  /// of text are hard to read, and a 2000px-wide list of scheme cards looks
  /// broken rather than impressive.
  static const double maxContentWidth = 840;

  /// Below this height the keyboard has probably eaten the screen, or the
  /// device is a very short phone - drop decorative spacing.
  static const double shortScreenHeight = 600;
}

extension ResponsiveContext on BuildContext {
  Size get _size => MediaQuery.sizeOf(this);

  double get screenWidth => _size.width;
  double get screenHeight => _size.height;

  ScreenSize get screenSize {
    final w = screenWidth;
    if (w < Breakpoints.compactMax) return ScreenSize.compact;
    if (w < Breakpoints.regularMax) return ScreenSize.regular;
    if (w < Breakpoints.mediumMax) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isPhone =>
      screenSize == ScreenSize.compact || screenSize == ScreenSize.regular;
  bool get isWide =>
      screenSize == ScreenSize.medium || screenSize == ScreenSize.expanded;

  bool get isShortScreen => screenHeight < Breakpoints.shortScreenHeight;
  bool get isLandscape => screenWidth > screenHeight;

  /// Horizontal page padding. Tighter on small phones so cards do not get
  /// squeezed into a narrow column.
  double get pagePadding => switch (screenSize) {
        ScreenSize.compact => 12,
        ScreenSize.regular => 16,
        ScreenSize.medium => 24,
        ScreenSize.expanded => 32,
      };

  /// Pick a value per screen size without writing a switch every time.
  T responsive<T>({
    required T compact,
    T? regular,
    T? medium,
    T? expanded,
  }) {
    final r = regular ?? compact;
    final m = medium ?? r;
    return switch (screenSize) {
      ScreenSize.compact => compact,
      ScreenSize.regular => r,
      ScreenSize.medium => m,
      ScreenSize.expanded => expanded ?? m,
    };
  }
}

/// Centres content and caps its width on large screens, while staying a
/// plain full-width child on phones.
///
/// Wrap page bodies in this rather than letting a ListView run edge to edge
/// on a desktop browser.
class ContentShell extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentShell({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

/// Shared column maths for the two adaptive grids below.
///
/// We compute the column count rather than using
/// [SliverGridDelegateWithMaxCrossAxisExtent], because that delegate can
/// leave one stretched tile on an awkward width.
SliverGridDelegate _adaptiveGridDelegate({
  required double availableWidth,
  required EdgeInsetsGeometry padding,
  required double targetTileWidth,
  required double spacing,
  required double childAspectRatio,
}) {
  final usable = availableWidth - padding.horizontal;
  var columns = (usable / targetTileWidth).floor();
  columns = columns.clamp(2, 6);
  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    mainAxisSpacing: spacing,
    crossAxisSpacing: spacing,
    childAspectRatio: childAspectRatio,
  );
}

/// A box-protocol grid that picks its column count from the available width.
/// Use inside a Column, a ListView, or anywhere a normal widget goes.
///
/// For a `CustomScrollView`, use [AdaptiveSliverGrid] instead.
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double targetTileWidth;
  final double spacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  const AdaptiveGrid({
    super.key,
    required this.children,
    this.targetTileWidth = 180,
    this.spacing = 12,
    this.childAspectRatio = 0.95,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => GridView(
        padding: padding,
        gridDelegate: _adaptiveGridDelegate(
          availableWidth: constraints.maxWidth,
          padding: padding,
          targetTileWidth: targetTileWidth,
          spacing: spacing,
          childAspectRatio: childAspectRatio,
        ),
        children: children,
      ),
    );
  }
}

/// The sliver twin of [AdaptiveGrid], for use in a `CustomScrollView`.
///
/// This is a separate widget rather than a `sliver: true` flag on
/// [AdaptiveGrid], and that is deliberate. A flag that silently switches
/// between the box and sliver layout protocols is a trap: the first version
/// of this used `LayoutBuilder` for both, which crashed at runtime with
///
///   A RenderViewport expected a child of type RenderSliver but received a
///   child of type _RenderLayoutBuilder
///
/// because `LayoutBuilder` is a box widget and a viewport only accepts
/// slivers. Nothing catches that at compile time - both are just `Widget`.
/// With two names, the type you need is the one you type.
///
/// Note it uses [SliverLayoutBuilder], whose builder returns a sliver and
/// whose constraints expose `crossAxisExtent` instead of `maxWidth`.
class AdaptiveSliverGrid extends StatelessWidget {
  final List<Widget> children;
  final double targetTileWidth;
  final double spacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry padding;

  const AdaptiveSliverGrid({
    super.key,
    required this.children,
    this.targetTileWidth = 180,
    this.spacing = 12,
    this.childAspectRatio = 0.95,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) => SliverPadding(
        padding: padding,
        sliver: SliverGrid(
          gridDelegate: _adaptiveGridDelegate(
            availableWidth: constraints.crossAxisExtent,
            padding: padding,
            targetTileWidth: targetTileWidth,
            spacing: spacing,
            childAspectRatio: childAspectRatio,
          ),
          delegate: SliverChildBuilderDelegate(
            (_, i) => children[i],
            childCount: children.length,
          ),
        ),
      ),
    );
  }
}

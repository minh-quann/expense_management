import 'package:flutter/material.dart';

/// A custom InputBorder that draws a superellipse border.
class SuperellipseInputBorder extends InputBorder {
  final BorderRadius borderRadius;

  const SuperellipseInputBorder({
    super.borderSide = BorderSide.none,
    this.borderRadius = const BorderRadius.all(Radius.circular(4.0)),
  });

  @override
  bool get isOutline => true;

  @override
  InputBorder copyWith({BorderSide? borderSide, BorderRadius? borderRadius}) {
    return SuperellipseInputBorder(
      borderSide: borderSide ?? this.borderSide,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(borderSide.width);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRSuperellipse(
        RSuperellipse.fromRectAndRadius(
          rect,
          borderRadius.resolve(textDirection).topLeft,
        ),
      );
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..addRSuperellipse(
        RSuperellipse.fromRectAndRadius(
          rect,
          borderRadius.resolve(textDirection).topLeft,
        ),
      );
  }

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    double? gapStart,
    double gapExtent = 0.0,
    double gapPercentage = 0.0,
    TextDirection? textDirection,
  }) {
    if (borderSide.style == BorderStyle.none) return;

    final Paint paint = borderSide.toPaint();
    final RSuperellipse rsuperellipse = RSuperellipse.fromRectAndRadius(
      rect,
      borderRadius.resolve(textDirection).topLeft,
    );
    canvas.drawRSuperellipse(rsuperellipse, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return SuperellipseInputBorder(
      borderSide: borderSide.scale(t),
      borderRadius: borderRadius * t,
    );
  }
}

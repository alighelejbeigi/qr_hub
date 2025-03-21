import 'package:flutter/material.dart';

class BottomCircularNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double notchRadius = 38.0;
    final Path path = Path();

    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width / 2 - notchRadius, size.height);

    path.relativeQuadraticBezierTo(
      size.width / 2 - notchRadius,
      size.height,
      size.width / 2 - notchRadius,
      size.height,
    );

    path.arcTo(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height),
        radius: notchRadius,
      ),
      3.14,
      3.14,
      false,
    );

    path.relativeQuadraticBezierTo(
      size.width / 2 + notchRadius,
      size.height,
      size.width / 2 + notchRadius,
      size.height,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

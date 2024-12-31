import 'package:flutter/material.dart';

class BottomCircularNotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const double notchRadius = 38.0; // شعاع نیم‌دایره

    final Path path = Path();

    // رسم قسمت‌های بالا و کناره‌ها
    path.moveTo(0, 0);
    path.lineTo(0, size.height); // حرکت به گوشه پایین چپ
    path.lineTo(size.width / 2 - notchRadius, size.height);

    // رسم منحنی نرم برای شروع نیم‌دایره
    path.relativeQuadraticBezierTo(
      size.width / 2 - notchRadius,
      size.height,
      size.width / 2 - notchRadius,
      size.height,
    );

    // رسم نیم‌دایره
    path.arcTo(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height),
        radius: notchRadius,
      ),
      3.14, // شروع از زاویه 180 درجه
      3.14, // طول قوس (نیم‌دایره)
      false,
    );

    // رسم منحنی نرم برای پایان نیم‌دایره
    path.relativeQuadraticBezierTo(
      size.width / 2 + notchRadius,
      size.height,
      size.width / 2 + notchRadius,
      size.height,
    );

    // ادامه مسیر
    path.lineTo(size.width, size.height); // حرکت به گوشه پایین راست
    path.lineTo(size.width, 0); // حرکت به گوشه بالا راست

    // بستن مسیر
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

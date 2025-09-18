import 'package:flutter/material.dart';

class ThemedBackground extends StatelessWidget {
  final Widget child;

  const ThemedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children:[ Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              isDark
                  ? "assets/WhatsApp Image 2025-09-05 at 19.25.57_0deb8013.jpg"   // صورة الوضع الليلي
                  : "assets/WhatsApp Image 2025-09-05 at 19.25.57_551e6ec5.jpg", // صورة الوضع النهاري
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),]
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_color.dart';

class WaterBackground extends StatelessWidget {
  const WaterBackground({
    super.key,
    required this.child,
    this.showWave = false,
    this.waveHeight = 90,
  });

  final Widget child;
  final bool showWave;
  final double waveHeight;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppColors.waterBlue),
        const Positioned.fill(child: CustomPaint(painter: _WaterPainter())),
        if (showWave)
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            height: waveHeight,
            child: ClipPath(
              clipper: _WhiteWaveClipper(),
              child: const ColoredBox(color: AppColors.white),
            ),
          ),
        child,
      ],
    );
  }
}

class _WaterPainter extends CustomPainter {
  const _WaterPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final darkPaint = Paint()..color = AppColors.waterBlueDark;
    final lightPaint = Paint()..color = AppColors.waterBlueLight;
    final bubblePaint = Paint()..color = AppColors.waterBubble;

    final topWave = Path()
      ..moveTo(0, 0)
      ..lineTo(0, size.height * 0.22)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.16,
        size.width * 0.38,
        size.height * 0.34,
        size.width * 0.70,
        size.height * 0.25,
      )
      ..cubicTo(
        size.width * 0.96,
        size.height * 0.18,
        size.width,
        size.height * 0.33,
        size.width,
        size.height * 0.08,
      )
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(topWave, darkPaint);

    final middleWave = Path()
      ..moveTo(0, size.height * 0.55)
      ..cubicTo(
        size.width * 0.26,
        size.height * 0.44,
        size.width * 0.44,
        size.height * 0.70,
        size.width * 0.76,
        size.height * 0.55,
      )
      ..cubicTo(
        size.width * 0.92,
        size.height * 0.48,
        size.width,
        size.height * 0.55,
        size.width,
        size.height * 0.45,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(middleWave, darkPaint);

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.11),
      size.shortestSide * 0.13,
      lightPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.62, size.height * 0.47),
      size.shortestSide * 0.09,
      darkPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.66),
      size.shortestSide * 0.10,
      lightPaint,
    );

    for (final bubble in const <List<double>>[
      [.22, .08, .025],
      [.92, .20, .02],
      [.12, .48, .035],
      [.56, .08, .022],
      [.48, .52, .018],
      [.88, .74, .018],
    ]) {
      canvas.drawCircle(
        Offset(size.width * bubble[0], size.height * bubble[1]),
        size.shortestSide * bubble[2],
        bubblePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WhiteWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()
      ..lineTo(0, size.height * 0.32)
      ..cubicTo(
        size.width * 0.22,
        -size.height * 0.05,
        size.width * 0.40,
        size.height * 0.05,
        size.width * 0.58,
        size.height * 0.28,
      )
      ..cubicTo(
        size.width * 0.75,
        size.height * 0.48,
        size.width * 0.88,
        size.height * 0.22,
        size.width,
        size.height * 0.28,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

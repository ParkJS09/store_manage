import 'package:flutter/material.dart';

class GridPainter extends CustomPainter {
  final double gridSize;
  final Color gridColor;

  GridPainter({
    this.gridSize = 100.0,
    this.gridColor = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor.withOpacity(0.2)
      ..strokeWidth = 1.0;

    // 캔버스를 클리핑하여 필요한 영역만 그리도록 합니다.
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // 수직선 그리기
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // 수평선 그리기
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPainter oldDelegate) =>
      gridSize != oldDelegate.gridSize || gridColor != oldDelegate.gridColor;
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SeatDiagram extends StatelessWidget {
  final bool isLeftShady;

  const SeatDiagram({super.key, required this.isLeftShady});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      color: AppTheme.lightGray,
      child: CustomPaint(
        painter: _BusPainter(isLeftShady: isLeftShady),
      ),
    );
  }
}

class _BusPainter extends CustomPainter {
  final bool isLeftShady;

  _BusPainter({required this.isLeftShady});

  @override
  void paint(Canvas canvas, Size size) {
    final vehicleWidth = size.width * 0.8;
    final vehicleHeight = size.height * 0.7;
    final vehicleRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: vehicleWidth,
      height: vehicleHeight,
    );

    // Draw vehicle body
    final bodyPaint = Paint()..color = AppTheme.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(vehicleRect, const Radius.circular(8)),
      bodyPaint,
    );
    final borderPaint = Paint()
      ..color = AppTheme.midGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(vehicleRect, const Radius.circular(8)),
      borderPaint,
    );

    // Draw front windshield indicator
    canvas.drawLine(
      Offset(vehicleRect.left + 20, vehicleRect.top + 10),
      Offset(vehicleRect.right - 20, vehicleRect.top + 10),
      borderPaint,
    );

    // Compute seat positioning
    final aisleWidth = 16.0;
    final seatWidth = 12.0;
    final seatHeight = 8.0;
    
    final startY = vehicleRect.top + 30;
    final rowSpacing = 20.0;
    
    final leftColX1 = vehicleRect.left + (vehicleWidth / 2) - aisleWidth / 2 - seatWidth * 2 - 10;
    final leftColX2 = leftColX1 + seatWidth + 4;
    
    final rightColX1 = vehicleRect.left + (vehicleWidth / 2) + aisleWidth / 2 + 10;
    final rightColX2 = rightColX1 + seatWidth + 4;

    // Draw seats (3 rows, 2 cols on each side)
    for (int row = 0; row < 3; row++) {
      final y = startY + (row * rowSpacing);
      
      // Draw left seats
      _drawSeat(canvas, Offset(leftColX1, y), seatWidth, seatHeight, isLeftShady);
      _drawSeat(canvas, Offset(leftColX2, y), seatWidth, seatHeight, isLeftShady);
      
      // Draw right seats
      _drawSeat(canvas, Offset(rightColX1, y), seatWidth, seatHeight, !isLeftShady);
      _drawSeat(canvas, Offset(rightColX2, y), seatWidth, seatHeight, !isLeftShady);
    }

    // Draw labels 'Shady' and 'Sunny'
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    
    textPainter.text = TextSpan(
      text: isLeftShady ? 'Shady' : 'Sunny',
      style: TextStyle(color: isLeftShady ? AppTheme.primaryGreen : AppTheme.amber, fontSize: 10, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(leftColX1 + 4, startY + 3 * rowSpacing));
    
    textPainter.text = TextSpan(
      text: !isLeftShady ? 'Shady' : 'Sunny',
      style: TextStyle(color: !isLeftShady ? AppTheme.primaryGreen : AppTheme.amber, fontSize: 10, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rightColX1 + 4, startY + 3 * rowSpacing));

    // Draw sun icon
    final sunX = isLeftShady ? vehicleRect.right + 15 : vehicleRect.left - 15;
    final sunY = size.height / 2;
    final sunPaint = Paint()..color = AppTheme.amber;
    canvas.drawCircle(Offset(sunX, sunY), 8, sunPaint);
  }

  void _drawSeat(Canvas canvas, Offset pos, double w, double h, bool isShady) {
    final seatRect = Rect.fromLTWH(pos.dx, pos.dy, w, h);
    final paint = Paint()
      ..color = isShady ? AppTheme.lightGreen : AppTheme.lightAmber
      ..style = PaintingStyle.fill;
      
    final borderPaint = Paint()
      ..color = isShady ? AppTheme.primaryGreen : AppTheme.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRRect(RRect.fromRectAndRadius(seatRect, const Radius.circular(2)), paint);
    canvas.drawRRect(RRect.fromRectAndRadius(seatRect, const Radius.circular(2)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

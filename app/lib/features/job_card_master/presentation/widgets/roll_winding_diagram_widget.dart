import 'package:flutter/material.dart';

/// Renders the exact 8 Roll Winding Direction diagrams (F1-F4, R1-R4)
/// matching PGPL Excel Specification ("JOB CARD JULY 2026.xlsx").
class RollWindingDiagramWidget extends StatelessWidget {
  const RollWindingDiagramWidget({
    super.key,
    required this.selectedDirection,
    required this.onDirectionSelected,
  });

  final String selectedDirection;
  final ValueChanged<String> onDirectionSelected;

  @override
  Widget build(BuildContext context) {
    // Top row: F3, F4, F2, F1
    final topRow = ['F3', 'F4', 'F2', 'F1'];
    // Bottom row: R3, R4, R2, R1
    final bottomRow = ['R3', 'R4', 'R2', 'R1'];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 0.5),
      ),
      child: Column(
        children: [
          // Image Fallback / Primary Asset
          Image.asset(
            'assets/images/roll_winding_directions.png',
            fit: BoxFit.contain,
            height: 180,
            errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 12),
          // Interactive 8-Card Grid Layout matching PGPL layout
          Column(
            children: [
              // Row 1: F3, F4, F2, F1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: topRow.map((dir) => _buildRollCard(dir)).toList(),
              ),
              const SizedBox(height: 12),
              // Row 2: R3, R4, R2, R1
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: bottomRow.map((dir) => _buildRollCard(dir)).toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRollCard(String dir) {
    final isSelected = selectedDirection.toUpperCase() == dir;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: () => onDirectionSelected(dir),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isSelected ? Colors.amber.shade300 : Colors.white,
              border: Border.all(color: isSelected ? Colors.amber.shade900 : Colors.black, width: isSelected ? 2.5 : 1),
              borderRadius: BorderRadius.circular(4),
              boxShadow: isSelected ? [BoxShadow(color: Colors.amber.withAlpha(140), blurRadius: 6)] : [],
            ),
            child: Column(
              children: [
                // Direction Label (F1, F2, F3, F4, R1, R2, R3, R4)
                Text(
                  dir,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isSelected ? Colors.black : Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                // Custom Canvas Drawing of Cylinder & Paper Sheet
                SizedBox(
                  height: 48,
                  width: double.infinity,
                  child: CustomPaint(
                    painter: _RollPainter(direction: dir, isSelected: isSelected),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RollPainter extends CustomPainter {
  _RollPainter({required this.direction, required this.isSelected});

  final String direction;
  final bool isSelected;

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final paintFill = Paint()
      ..color = isSelected ? Colors.amber.shade50 : Colors.grey.shade100
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    final isTopRoll = direction.startsWith('F');
    final isRightRoll = direction.endsWith('1') || direction.endsWith('2') || direction.endsWith('4');

    // Draw cylinder roll
    double rollX = isRightRoll ? w - 24 : 0;
    double rollY = isTopRoll ? 0 : 8;

    final rollRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(rollX, rollY, 24, h - 8),
      const Radius.circular(4),
    );
    canvas.drawRRect(rollRect, paintFill);
    canvas.drawRRect(rollRect, paintLine);

    // Draw concentric top ellipse lines for paper roll layers
    canvas.drawOval(Rect.fromLTWH(rollX + 2, rollY + 2, 20, 8), paintLine);
    canvas.drawOval(Rect.fromLTWH(rollX + 5, rollY + 4, 14, 4), paintLine);

    // Draw paper sheet rectangle extending out
    double sheetX = isRightRoll ? 4 : 24;
    double sheetW = w - 28;

    final sheetRect = Rect.fromLTWH(sheetX, 10, sheetW, h - 16);
    canvas.drawRect(sheetRect, Paint()..color = Colors.white..style = PaintingStyle.fill);
    canvas.drawRect(sheetRect, paintLine);

    // Draw arrows on sheet
    double arrowY1 = 14;
    double arrowY2 = h - 10;
    bool pointRight = direction.endsWith('1') || direction.endsWith('3');

    if (pointRight) {
      canvas.drawLine(Offset(sheetX + 4, arrowY1), Offset(sheetX + sheetW - 4, arrowY1), paintLine);
      canvas.drawLine(Offset(sheetX + 4, arrowY2), Offset(sheetX + sheetW - 4, arrowY2), paintLine);
      // Arrow head
      canvas.drawLine(Offset(sheetX + sheetW - 8, arrowY1 - 3), Offset(sheetX + sheetW - 4, arrowY1), paintLine);
      canvas.drawLine(Offset(sheetX + sheetW - 8, arrowY2 - 3), Offset(sheetX + sheetW - 4, arrowY2), paintLine);
    } else {
      canvas.drawLine(Offset(sheetX + sheetW - 4, arrowY1), Offset(sheetX + 4, arrowY1), paintLine);
      canvas.drawLine(Offset(sheetX + sheetW - 4, arrowY2), Offset(sheetX + 4, arrowY2), paintLine);
      // Arrow head
      canvas.drawLine(Offset(sheetX + 8, arrowY1 - 3), Offset(sheetX + 4, arrowY1), paintLine);
      canvas.drawLine(Offset(sheetX + 8, arrowY2 - 3), Offset(sheetX + 4, arrowY2), paintLine);
    }

    // Draw PGPL Text inside paper sheet
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    bool isVerticalText = direction.endsWith('1') || direction.endsWith('2');

    if (isVerticalText) {
      textPainter.text = TextSpan(
        text: 'P\nG\nP\nL',
        style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.black, height: 0.9),
      );
    } else {
      textPainter.text = const TextSpan(
        text: 'PGPL',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: 1),
      );
    }

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        sheetX + (sheetW - textPainter.width) / 2,
        (h - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _RollPainter oldDelegate) {
    return oldDelegate.direction != direction || oldDelegate.isSelected != isSelected;
  }
}

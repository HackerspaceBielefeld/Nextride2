import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  LinePainter({super.repaint, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(size.width - strokeWidth, strokeWidth);
    final p2 = Offset(strokeWidth, size.height - strokeWidth);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) => false;
}

class WCBusyWidget extends StatelessWidget {
  final WCState state;
  final double size;

  const WCBusyWidget({super.key, required this.state, this.size = 20.0});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
            padding: const EdgeInsets.all(4.0),
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: _getColor(), width: 4.0),
            ),
            child: Center(
              child: Row(
                children: [
                  //Icon(MdiIcons.humanMaleFemale, color: _getColor(), size: size * 0.8),
                  Text(
                    'WC',
                    style: TextStyle(
                      fontSize: size * 0.5,
                      color: _getColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )),
        Positioned.fill(
            child: state == WCState.free
                ? Container()
                : CustomPaint(painter: LinePainter(color: _getColor(), strokeWidth: 4.0))),
      ],
    );
  }

  Color _getColor() {
    switch (state) {
      case WCState.free:
        return Colors.green;
      case WCState.occupied:
        return Colors.red;
      case WCState.unknown:
        return Colors.grey;
    }
  }
}

enum WCState {
  free,
  occupied,
  unknown,
}

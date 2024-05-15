import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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

  const WCBusyWidget({Key? key, required this.state, this.size = 20.0}) : super(key: key);

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

    switch (state) {
      case WCState.free:
        return Text('WC', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: size));
      case WCState.occupied:
        return Stack(
          children: [
            Text('WC', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: size)),
            Positioned.fill(
              child: Icon(Icons.close, color: Colors.red, size: size * 1.3),
            ),
          ],
        );
      case WCState.unknown:
      default:
        return Text('WC', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: size));
    }
  }

  Color _getColor() {
    switch (state) {
      case WCState.free:
        return Colors.green;
      case WCState.occupied:
        return Colors.red;
      case WCState.unknown:
      default:
        return Colors.grey;
    }
  }
}

enum WCState {
  free,
  occupied,
  unknown,
}

import 'dart:math';
import 'package:flutter/material.dart';

class TrainLoadingIndicator extends StatefulWidget {
  final double? size;
  final Color? color;

  const TrainLoadingIndicator({super.key, this.size, this.color});

  @override
  // ignore: library_private_types_in_public_api
  _TrainLoadingIndicatorState createState() => _TrainLoadingIndicatorState();
}

class _TrainLoadingIndicatorState extends State<TrainLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation =
        CurveTween(curve: Curves.easeInOutSine).animate(_rotationController)
          ..addListener(
            () => setState(() {}),
          );

    _rotationController.repeat(reverse: true);

    super.initState();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Matrix4 transform = Matrix4.skewX(_animation.value - 0.5);

    return Center(
      child: Transform(
        transform: transform,
        alignment: Alignment.center,
        child: Icon(
          Icons.train,
          size: widget.size,
          color: widget.color,
        ),
      ),
    );
  }
}

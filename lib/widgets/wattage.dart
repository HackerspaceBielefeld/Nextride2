import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class WattageWidget extends StatelessWidget {
  final double wattage;
  final double size;

  const WattageWidget({Key? key, required this.wattage, required this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.yellow, width: size / 10),
      ),
      child: Row(
        children: [
          Icon(
            MdiIcons.powerSocketEu,
            color: Colors.yellow,
            size: size / 2,
          ),
          const SizedBox(width: 5),
          Text('${wattage.toStringAsFixed(0)}W', style: TextStyle(fontSize: size * 0.6)),
        ],
      ),
    );
  }
}

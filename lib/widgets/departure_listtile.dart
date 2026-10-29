import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/departure_data.dart';
import '../models/line_color.dart';
import '../providers/line_color_provider.dart';

class RideListTile extends StatelessWidget {
  final DepartureData item;

  const RideListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final LineColor lineColor = context.watch<LineColorProvider>().table.lookupDeparture(item) ?? LineColor.unknown;
    final TextStyle textStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    final TextStyle rideStyle = textStyle.copyWith(decoration: item.isCancelled ? TextDecoration.lineThrough : null);
    final double fontSize = textStyle.fontSize ?? 16;

    final String delay = item.isCancelled
        ? ' ❌'
        : (item.delayMinutes ?? 0) > 0
            ? ' +${item.delayMinutes}'
            : '';

    // Eine Zeile statt ListTile: Linie, Ziel, Zeit und Verspaetung haben
    // dieselbe Schriftgroesse und sind gemeinsam vertikal zentriert.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Mindestens so breit wie frueher, laengere Namen ("2 SEV", "RE6")
          // verbreitern das Feld und werden notfalls etwas verkleinert.
          Container(
            constraints: BoxConstraints(minWidth: fontSize * 2.5, maxWidth: fontSize * 5),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            color: lineColor.background,
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.lineName,
                  maxLines: 1,
                  style: textStyle.copyWith(fontWeight: FontWeight.bold, color: lineColor.foreground),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(item.destination, maxLines: 1, overflow: TextOverflow.ellipsis, style: rideStyle),
          ),
          const SizedBox(width: 12),
          Text(formatDepartureTime(item, DateTime.now()), style: rideStyle),
          if (delay.isNotEmpty) Text(delay, style: textStyle.copyWith(color: Colors.red)),
        ],
      ),
    );
  }
}

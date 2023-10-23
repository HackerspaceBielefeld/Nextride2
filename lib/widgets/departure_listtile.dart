import '../constants.dart' as constants;
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/departure_data.dart';

class RideListTile extends StatelessWidget {
  final DepartureData item;

  const RideListTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item.route),
      leading: Container(
          width: 40,
          alignment: Alignment.center,
          color: constants.mobielLineColors[item.lineNumber],
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: Text(
              item.lineNumber,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: constants.mobielLineColors[item.lineNumber] != null
                      ? Colors.white
                      : Colors.black),
            ),
          )),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          false
              ? Text(
                  '${item.orgHour.toString().padLeft(2, '0')}:${item.orgMinute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodyLarge,
                )
              : Text(
                  timeago.format(item.fullTimeDT,
                      locale: 'de', allowFromNow: true),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
          Text(
            item.delay == null || item.delay == 0 ? '' : ' +${item.delay}',
            style: const TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../models/calendar_item.dart';

class CalendarListTile extends StatelessWidget {
  final CalendarItem item;

  const CalendarListTile(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    List<Widget> categories = [];

    categories.add(Icon(
      Icons.door_front_door,
      color: item.color,
    ));

    for (var name in item.categories) {
      categories.add(Chip(
          labelStyle: const TextStyle(fontSize: 10),
          backgroundColor: Colors.grey.shade200,
          label: Text(name.toString()),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap));
    }

    return ListTile(
      //tileColor: item.color,
      leading: Text(
        "${item.weekday} ${item.day.toString().padLeft(2, '0')}.${item.month.toString().padLeft(2, '0')}.",
      ),

      trailing: Text(
        'ab ${item.hour.toString().padLeft(2, '0')}:${item.minute.toString().padLeft(2, '0')} Uhr',
      ),

      title: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 50),
            alignment: Alignment.center,
            child: Icon(
              item.icon.itemicon,
              color: item.icon.itemcolor,
            ),
          ),
          Text(
            item.summary,
          ),
          ...categories,
        ],
      ),
    );
  }
}

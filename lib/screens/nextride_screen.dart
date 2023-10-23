import 'dart:async';

import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:nextride2/models/departue_data_store.dart';
import 'package:nextride2/models/hassio_state.dart';
import 'package:nextride2/providers/calendar_provider.dart';
import 'package:nextride2/providers/hassio_provider.dart';
import 'package:nextride2/providers/weather_provider.dart';
import 'package:weather/weather.dart';

import '../constants.dart' as constants;

import 'package:flutter/material.dart';
import 'package:nextride2/models/departure_data.dart';
import 'package:nextride2/providers/timetable_provider.dart';
import 'package:provider/provider.dart';

import '../animations/train_loading_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/calendar_item.dart';
import '../widgets/calendar_listtile.dart';
import '../widgets/departure_listtile.dart';

class CalendarGridCard extends StatelessWidget {
  final CalendarItems? calItems;

  const CalendarGridCard({super.key, this.calItems});

  @override
  Widget build(BuildContext context) {
    if (calItems == null) {
      return const Card(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Veranstaltungen',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, idx) {
                return CalendarListTile(calItems!.items[idx]);
              },
              separatorBuilder: (context, idx) => const Divider(),
              itemCount:
                  calItems!.items.length > 5 ? 5 : calItems!.items.length),
        ],
      ),
    );
  }
}

class RouteGridCard extends StatelessWidget {
  final String route;
  final DepartureDataStore departureDataStore;

  const RouteGridCard(
      {super.key, required this.route, required this.departureDataStore});

  @override
  Widget build(BuildContext context) {
    List<DepartureData> items = departureDataStore.getByRouteName(route);

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            route,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              return RideListTile(
                item: items[index],
              );
            },
          )
        ],
      ),
    );
  }
}

class SpaceGridCard extends StatelessWidget {
  const SpaceGridCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/img/spacebi.png',
                  height: 130,
                ),
              ),
              Text(
                'Space.bi',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontSize: 100),
              ),
            ],
          ),
          Consumer<HassioProvider>(builder: (context, hp, child) {
            if (hp.hassioText == null ||
                hp.hassioText!.state == '' ||
                hp.hassioText!.state == 'undefined') {
              return Container();
            }

            return SizedBox(
              height: 80,
              child: Marquee(
                  text: hp.hassioText!.state,
                  blankSpace: 120,
                  style: Theme.of(context).textTheme.headlineSmall),
            );
          }),
          Consumer<WeatherProvider>(
            builder: (context, wp, child) {
              /*
              final weatherData = wp.groupAndSortWeatherByDate();
              return Column(
                children: List.generate(weatherData.length, (di) {
                  return Row(
                    children: List.generate(
                        weatherData.values.elementAt(di).length, (ti) {
                      Weather w =
                          weatherData.values.elementAt(di).elementAt(ti);
                      return Card(
                        child: Icon(WeatherProvider.getWeatherIcon(
                            w.weatherIcon ?? '')),
                      );
                    }),
                  );
                }),
              );
              */
              const int maxCols = 7;

              return GridView.count(
                shrinkWrap: true,
                childAspectRatio: 1,
                crossAxisCount: maxCols,
                children: List.generate(
                    wp.forecast.length > maxCols ? maxCols : wp.forecast.length,
                    (index) {
                  Weather w = wp.forecast[index];

                  return Card(
                      child: Column(
                    children: [
                      Text(
                        DateFormat('HH:mm').format(w.date!),
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      Icon(
                        WeatherProvider.getWeatherIcon(w.weatherIcon ?? ''),
                        size: 40,
                      ),
                      //Text(w.weatherMain ?? ''),
                      Text(
                        '${w.tempMin?.celsius!.round()} - ${w.tempMax?.celsius!.round()}°C',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ));
                }),
              );
            },
          )
        ],
      ),
    );
  }
}

class NextrideScreen extends StatelessWidget {
  const NextrideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: Stack(
        children: [
          Consumer2<TimetableProvider, CalendarProvider>(
            builder: (context, ttp, cp, child) {
              if (ttp.timetable == null) {
                return const TrainLoadingIndicator(
                  size: 400,
                  color: Colors.grey,
                );
              }

              Set<String> routeNames = ttp.timetable!.getRouteNames();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nextride 2',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        StatefulBuilder(
                          builder: (context, setState) {
                            DateTime now = DateTime.now();

                            Timer.periodic(
                              const Duration(seconds: 1),
                              (timer) {
                                setState(
                                  () {
                                    now = DateTime.now();
                                  },
                                );
                              },
                            );

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 46),
                                  child: Text(
                                    '${now.day.toString()}.${now.month.toString()}.${now.year.toString()} ',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                Text(
                                  '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 20 / 9,
                      children: List.generate(routeNames.length, (index) {
                        return RouteGridCard(
                            departureDataStore: ttp.timetable!,
                            route: routeNames.elementAt(index));
                      })
                        ..addAll([
                          CalendarGridCard(
                            calItems: cp.items,
                          ),
                          SpaceGridCard(),
                        ]),
                    )
                    /*
                    ListView.builder(
                      itemCount: ttp.timetable!.items.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        DepartureData item = ttp.timetable!.items[index];
                        return RideListTile(item: item);
                      },
                    )
                    */
                  ],
                ),
              );
            },
          ),
          Consumer<HassioProvider>(
            builder: (context, hp, child) {
              if (hp.hassioTimer == null) {
                return Container();
              }

              if (hp.hassioTimer!.runState != HassioTimerStateRunState.active ||
                  hp.hassioTimer!.finishesAt == null) {
                return Container();
              }

              const Color alertColor = Colors.red;

              return Container(
                constraints: const BoxConstraints.expand(),
                decoration: BoxDecoration(
                    border: Border.all(color: alertColor, width: 10)),
                child: SizedBox(
                  width: double.infinity,
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Builder(
                          builder: (context) {
                            Duration countdown = (hp.hassioTimer!.finishesAt!
                                .difference(DateTime.now()));

                            return Text(
                              "${hp.hassioTimer!.friendlyName} ${countdown.inHours.toString().padLeft(2, '0')}:${countdown.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(countdown.inSeconds.remainder(60).toString().padLeft(2, '0'))}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(
                                      color: Colors.white,
                                      backgroundColor: alertColor),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:nextride2/models/departue_data_store.dart';
import 'package:nextride2/models/hassio_state.dart';
import 'package:nextride2/models/rocket_launch.dart';
import 'package:nextride2/providers/calendar_provider.dart';
import 'package:nextride2/providers/hassio_provider.dart';
import 'package:nextride2/providers/network_provider.dart';
import 'package:nextride2/providers/rocket_launch_provider.dart';
import 'package:nextride2/providers/weather_provider.dart';
import 'package:nextride2/widgets/wattage.dart';
import 'package:nextride2/widgets/wc_busy.dart';
import 'package:weather/weather.dart';

import '../constants.dart' as constants;

import 'package:flutter/material.dart';
import 'package:nextride2/models/departure_data.dart';
import 'package:nextride2/providers/timetable_provider.dart';
import 'package:provider/provider.dart';

import '../animations/train_loading_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../models/calendar_item.dart';
import '../providers/clock_provider.dart';
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
              itemCount: calItems!.items.length > 5 ? 5 : calItems!.items.length),
        ],
      ),
    );
  }
}

class RouteGridCard extends StatelessWidget {
  final String route;
  final DepartureDataStore departureDataStore;

  const RouteGridCard({super.key, required this.route, required this.departureDataStore});

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

class DepartureGridCard extends StatelessWidget {
  final String lineName;
  final DepartureDataStore departureDataStore;

  const DepartureGridCard({super.key, required this.lineName, required this.departureDataStore});

  @override
  Widget build(BuildContext context) {
    List<DepartureData> items = departureDataStore.items;

    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            lineName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: items.length > 6 ? 6 : items.length,
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
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 100),
              ),
            ],
          ),
          Consumer<HassioProvider>(builder: (context, hp, child) {
            if (hp.hassioText == null || hp.hassioText!.state == '' || hp.hassioText!.state == 'undefined') {
              return Container();
            }

            return SizedBox(
              height: 80,
              width: double.infinity,
              child: Center(child: Text(hp.hassioText!.state, style: Theme.of(context).textTheme.headlineSmall)),
            );

            // PI3 GPU ist zu Kacke dafür
            return SizedBox(
              height: 80,
              child: Marquee(
                  text: hp.hassioText!.state, blankSpace: 120, style: Theme.of(context).textTheme.headlineSmall),
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
              const int maxCols = 6;

              return GridView.count(
                shrinkWrap: true,
                childAspectRatio: 1,
                crossAxisCount: maxCols,
                children: List.generate(wp.forecast.length > maxCols ? maxCols : wp.forecast.length, (index) {
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
          Consumer3<TimetableProvider, CalendarProvider, NetworkProvider>(
            builder: (context, ttp, cp, net, child) {
              if (net.nic != null) {
                return Stack(
                  children: [
                    Container(
                      constraints: const BoxConstraints.expand(),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(net.nic!.uri),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Display seconds in bottom right corner
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            net.secondsRemaining.toString(),
                            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                  foreground: Paint()
                                    ..style = PaintingStyle.stroke
                                    ..strokeWidth = 2
                                    ..color = Colors.black,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (ttp.timetable == null) {
                return const TrainLoadingIndicator(
                  size: 400,
                  color: Colors.grey,
                );
              }

              //Set<String> routeNames = ttp.timetable!.getRouteNames();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'NxR 2',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 50.0),
                              child: Consumer<HassioProvider>(
                                builder: (context, hp, child) {
                                  if (hp.hassioWCBusy == null) {
                                    return const WCBusyWidget(state: WCState.unknown, size: 60);
                                  }

                                  return WCBusyWidget(
                                      state: hp.hassioWCBusy!.isOn ? WCState.occupied : WCState.free, size: 60);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Consumer<HassioProvider>(
                                builder: (context, value, child) {
                                  if (value.hassioLeistung == null) {
                                    return const CircularProgressIndicator();
                                  }

                                  return WattageWidget(wattage: double.parse(value.hassioLeistung!.state), size: 60);
                                },
                              ),
                            )
                          ],
                        ),
                        Consumer<ClockProvider>(
                          builder: (context, clock, child) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 46),
                                  child: Text(
                                    '${clock.dateTime.day.toString()}.${clock.dateTime.month.toString()}.${clock.dateTime.year.toString()} ',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                                false
                                    ? Text(
                                        '${clock.dateTime.hour.toString().padLeft(2, '0')}:${clock.dateTime.minute.toString().padLeft(2, '0')}:${clock.dateTime.second.toString().padLeft(2, '0')}',
                                        style: Theme.of(context).textTheme.headlineLarge,
                                      )
                                    : Text(
                                        '${clock.dateTime.hour.toString().padLeft(2, '0')}:${clock.dateTime.minute.toString().padLeft(2, '0')}',
                                        style: Theme.of(context).textTheme.headlineLarge,
                                      )
                              ],
                            );
                          },
                        )
                      ],
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 20 / 10,
                      children: [
                        DepartureGridCard(departureDataStore: ttp.timetable!, lineName: 'Linie 2'),
                        Consumer<RocketLaunchProvider>(
                          builder: (context, rlp, child) {
                            if (rlp.rocketLaunchDataStore == null) {
                              return const CircularProgressIndicator();
                            }

                            return Card(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Raketenstarts',
                                    style: Theme.of(context).textTheme.headlineSmall,
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: rlp.rocketLaunchDataStore!.items.length > 4
                                        ? 4
                                        : rlp.rocketLaunchDataStore!.items.length,
                                    itemBuilder: (context, index) {
                                      RocketLaunch r = rlp.rocketLaunchDataStore!.items[index];
                                      return ListTile(
                                        leading: Icon(MdiIcons.rocketLaunch),
                                        title: Text('${r.name}'),
                                        subtitle: Text('${r.providerName} - ${r.vehicleName}'),
                                        trailing: Text(timeago.format(r.t0Dt, locale: 'de', allowFromNow: true)),
                                      );
                                    },
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                        CalendarGridCard(
                          calItems: cp.items,
                        ),
                        const SpaceGridCard(),
                      ],
                    )
                    /*
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      childAspectRatio: 20 / 10,
                      children: List.generate(routeNames.length, (index) {
                        return RouteGridCard(
                            departureDataStore: ttp.timetable!,
                            route: routeNames.elementAt(index));
                      })
                        ..addAll([
                          CalendarGridCard(
                            calItems: cp.items,
                          ),
                          const SpaceGridCard(),
                        ]),
                    )
                    */
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

              if (hp.hassioTimer!.runState != HassioTimerStateRunState.active || hp.hassioTimer!.finishesAt == null) {
                return Container();
              }

              const Color alertColor = Colors.red;

              return Container(
                constraints: const BoxConstraints.expand(),
                decoration: BoxDecoration(border: Border.all(color: alertColor, width: 10)),
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
                            Duration countdown = (hp.hassioTimer!.finishesAt!.difference(DateTime.now()));

                            return Text(
                              "${hp.hassioTimer!.friendlyName} ${countdown.inHours.toString().padLeft(2, '0')}:${countdown.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(countdown.inSeconds.remainder(60).toString().padLeft(2, '0'))}",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge!
                                  .copyWith(color: Colors.white, backgroundColor: alertColor),
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

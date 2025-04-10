import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:day_picker/model/day_in_week.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:intl/intl.dart';
import 'package:iot_project/cubit/timer_schedule_cubit.dart';
import 'package:iot_project/model/schedule_model.dart';
import 'package:iot_project/ui/screens/create_schedule_screen.dart';
import 'package:iot_project/ui/widgets/custom_error.dart';
import 'package:iot_project/ui/widgets/custom_loading_widget.dart';
import 'package:iot_project/utils/utils.dart';

class TimerScheduleScreen extends StatefulWidget {
  const TimerScheduleScreen({super.key});

  @override
  State<TimerScheduleScreen> createState() => _TimerSchduleScreenState();
}

class _TimerSchduleScreenState extends State<TimerScheduleScreen>
    with SingleTickerProviderStateMixin {
  TimerScheduleCubit get _cubit => context.read<TimerScheduleCubit>();
  late TabController _controller;
  final List<DayInWeek> _days = [
    DayInWeek("sat", dayKey: "saturday"),
    DayInWeek(
      "sun",
      dayKey: "sunday",
    ),
    DayInWeek("mon", dayKey: "monday"),
    DayInWeek("tue", dayKey: "tuesday"),
    DayInWeek("wed", dayKey: "wednesday"),
    DayInWeek("thu", dayKey: "thursday"),
    DayInWeek("fri", dayKey: "friday"),
  ];
  @override
  void initState() {
    _controller = TabController(vsync: this, length: 2);
    super.initState();
  }

  String _weekDaysString({required List<int> weeks}) {
    if (weeks.length == 7) {
      return "All days";
    }
    String txt = "";
    for (var i = 0; i < weeks.length; i++) {
      txt += _days[weeks[i]].dayName + ", ";
    }
    return txt;
  }

  Widget _txtWidget(String txt) {
    return Expanded(
      // width: 100,
      // alignment: Alignment.center,
      child: Text(
        txt,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _timerWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _cubit.currentTimer != null
          ? [
              CircularCountDownTimer(
                duration: Duration(
                        hours: _cubit.currentTimer!.timer.hour,
                        minutes: _cubit.currentTimer!.timer.minute,
                        seconds: _cubit.currentTimer!.timer.second)
                    .inSeconds,
                initialDuration: 0,
                controller: CountDownController(),
                width: MediaQuery.of(context).size.width / 2,
                height: MediaQuery.of(context).size.height / 2,
                ringColor: Colors.grey.shade300,
                ringGradient: null,
                fillColor: Colors.grey.shade100,
                fillGradient: null,
                backgroundColor: Colors.black,
                backgroundGradient: null,
                strokeWidth: 20.0,
                strokeCap: StrokeCap.round,
                textStyle: const TextStyle(
                    fontSize: 33.0,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
                textFormat: CountdownTextFormat.S,
                isReverse: true,
                isReverseAnimation: false,
                isTimerTextShown: true,
                autoStart: true,
                onStart: () {
                  debugPrint('Countdown Started');
                },
                onComplete: () {
                  debugPrint('Countdown Ended');
                },
                onChange: (String timeStamp) {
                  debugPrint('Countdown Changed $timeStamp');
                },
                timeFormatterFunction: (defaultFormatterFunction, duration) {
                  if (duration.inSeconds == 0) {
                    return "Start";
                  } else {
                    return duration.toString().split('.').first.padLeft(8, "0");
                  }
                },
              ),
              IconButton(
                  onPressed: () {
                    _cubit.removeTimer(model: _cubit.currentTimer!);
                  },
                  icon: Icon(
                    Icons.stop_circle_outlined,
                    color: Colors.red,
                    size: 42,
                  ))
            ]
          : [
              SizedBox(
                width: 280,
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _txtWidget("Hour"),
                    const SizedBox(
                      width: 50,
                    ),
                    _txtWidget("Minutes"),
                    const SizedBox(
                      width: 50,
                    ),
                    _txtWidget("Seconds")
                  ],
                ),
              ),
              TimePickerSpinner(
                alignment: Alignment.center,
                isShowSeconds: true,
                is24HourMode: true,
                normalTextStyle:
                    TextStyle(fontSize: 24, color: Colors.grey.shade500),
                highlightedTextStyle:
                    const TextStyle(fontSize: 24, color: Colors.black),
                spacing: 50,
                itemHeight: 80,
                itemWidth: 60,
                isForce2Digits: true,
                onTimeChange: (time) {
                  // setState(() {
                  _cubit.timerSelectedTime = time;
                  // });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                child: IconButton(
                    onPressed: () {
                      if (_cubit.timerSelectedTime != null)
                        _cubit.addTimer(time: _cubit.timerSelectedTime!);
                    },
                    icon: const Icon(
                      Icons.play_circle_filled_outlined,
                      size: 42,
                    )),
              )
            ],
    );
  }

  // Widget _schedule() {
  //   return Column(
  //     children: [
  //       Tooltip(
  //         message:
  //             "After choosing the days that you need and selecting the right command the device will be triggred on the right time.",
  //         child: Padding(
  //           padding: const EdgeInsets.all(8.0),
  //           child: Material(
  //             elevation: 8,
  //             borderRadius: BorderRadius.circular(16),
  //             color: Colors.white,
  //             // margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
  //             child: TimePickerSpinner(
  //               alignment: Alignment.center,
  //               isShowSeconds: false,
  //               is24HourMode: false,
  //               normalTextStyle:
  //                   TextStyle(fontSize: 24, color: Colors.grey.shade600),
  //               highlightedTextStyle:
  //                   const TextStyle(fontSize: 24, color: Colors.black),
  //               spacing: 50,
  //               itemHeight: 80,
  //               itemWidth: 60,
  //               isForce2Digits: true,
  //               onTimeChange: (time) {
  //                 _cubit.timerSelectedTime = time;
  //               },
  //             ),
  //           ),
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Material(
  //           elevation: 8,
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(16),
  //           child: Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   "Select desired days",
  //                   style: Theme.of(context).textTheme.titleMedium,
  //                 ),
  //                 SelectWeekDays(
  //                   // key: customWidgetKey,
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w500,
  //                   unSelectedDayTextColor: Colors.black,
  //                   days: _days,
  //                   border: false,
  //                   padding: 16,
  //                   width: MediaQuery.of(context).size.width,
  //                   boxDecoration: BoxDecoration(
  //                     // color: Colors.red,
  //                     borderRadius: BorderRadius.circular(30.0),
  //                   ),
  //                   onSelect: (values) {
  //                     print(values);
  //                   },
  //                 ),
  //                 Padding(
  //                   padding:
  //                       const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
  //                   child: Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     children: [
  //                       Text(
  //                         "Switch ${_cubit.keyNumber + 1}",
  //                         style: Theme.of(context).textTheme.titleMedium,
  //                       ),
  //                       Switch(value: true, onChanged: (value) {})
  //                     ],
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         ),
  //       )
  //     ],
  //   );

  // }
  void showLogoutConfirmationDialog(
      {required BuildContext context, required Function logoutFunction}) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        title: Text('Confirm delete',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete this schedule?',
          style: TextStyle(fontSize: 16.0),
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: TextStyle(fontSize: 16.0),
            ),
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: TextStyle(fontSize: 16.0),
            ),
            child: Text('Delete'),
            onPressed: () {
              Navigator.of(context).pop();
              logoutFunction();
            },
          ),
        ],
      ),
    );
  }

  Widget _bodyWidget({required int mode, required TimerScheduleState state}) {
    // 0 is for timer
    // 1 is for Schedule

    if (mode == 0) {
      // if (state is Loading)
      //   return Center(
      //     child: CustomLoadingWidget(),
      //   );
      return _timerWidget();
    } else {
      return Padding(
        padding: EdgeInsets.all(12),
        child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            // margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: List.generate(
                          _cubit.mainSchedules.length,
                          (index) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Material(
                                  borderRadius: BorderRadius.circular(12),
                                  // margin: EdgeInsets.symmetric(
                                  //     vertical: 8, horizontal: 12),

                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      print("asd");
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    DateFormat('hh:mm').format(
                                                        _cubit
                                                            .mainSchedules[
                                                                index]
                                                            .time
                                                            .toLocal()),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge,
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                _weekDaysString(
                                                    weeks: _cubit
                                                        .mainSchedules[index]
                                                        .weekDays),
                                                // DateFormat('hh:mm').format(_cubit
                                                //     .mainSchedules[index].time
                                                //     .toLocal()
                                                // ),
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                              Text("Switch state: " +
                                                  (_cubit.mainSchedules[index]
                                                          .state
                                                      ? "On"
                                                      : "Off"))
                                            ],
                                          ),
                                          IconButton(
                                              onPressed: () {
                                                showLogoutConfirmationDialog(
                                                    context: context,
                                                    logoutFunction: () {
                                                      _cubit.deleteSchedule(
                                                          model: _cubit
                                                                  .mainSchedules[
                                                              index]);
                                                    });
                                              },
                                              icon: Icon(
                                                Icons.delete_outlined,
                                                color: Colors.red,
                                              ))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                    ),
                  ),
                ),
                Divider(
                  indent: 10,
                  endIndent: 10,
                  color: Colors.grey.shade200,
                ),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  child: TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .push(CupertinoModalPopupRoute(
                          builder: (context) => CreateScheduleScreen(
                            keyNumber: _cubit.keyNumber,
                            device: _cubit.device,
                          ),
                        ))
                            .then((value) {
                          if (value != null) {
                            _cubit.addSchedule(model: value as ScheduleModel);
                            // print(value);
                          }
                        });
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.add), Text("Add Schedule")],
                      )),
                )
              ],
            )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Schedule"),
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.arrow_back_ios_rounded)),
          centerTitle: true,
          bottom: TabBar(controller: _controller, tabs: [
            Tab(
              icon: const Icon(Icons.timer),
              child: Text(
                "Timer",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            ),
            Tab(
              icon: const Icon(Icons.lock_clock),
              child: Text(
                "Schedule",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.white),
              ),
            )
          ]),
        ),
        body: BlocBuilder<TimerScheduleCubit, TimerScheduleState>(
          builder: (context, state) {
            if (state is Loading) return CustomLoadingWidget();
            if (state is Error)
              return CustomError(error: state.error, onCall: state.onCall);
            if (state is ScaffoldError)
              Utils.showSnackBar(
                  context: context,
                  txt: state.message,
                  afterSnack: _cubit.empty);
            return TabBarView(
              controller: _controller,
              children: List.generate(_controller.length,
                  (index) => _bodyWidget(mode: index, state: state)),
            );
          },
        ));
  }
}

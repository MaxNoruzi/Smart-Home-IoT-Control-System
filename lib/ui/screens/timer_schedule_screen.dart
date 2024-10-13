import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:iot_project/cubit/timer_schedule_cubit.dart';
import 'package:iot_project/ui/screens/create_schedule_screen.dart';

class TimerScheduleScreen extends StatefulWidget {
  const TimerScheduleScreen({super.key});

  @override
  State<TimerScheduleScreen> createState() => _TimerSchduleScreenState();
}

class _TimerSchduleScreenState extends State<TimerScheduleScreen>
    with SingleTickerProviderStateMixin {
  TimerScheduleCubit get _cubit => context.read<TimerScheduleCubit>();
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(vsync: this, length: 2);
    super.initState();
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
      children: _cubit.timerStarted
          ? [
              CircularCountDownTimer(
                duration: Duration(
                        hours: _cubit.timerSelectedTime!.hour,
                        minutes: _cubit.timerSelectedTime!.hour,
                        seconds: _cubit.timerSelectedTime!.second)
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
                    _cubit.timerStop();
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
                      _cubit.startTimer();
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

  Widget _bodyWidget({required int mode}) {
    if (mode == 0) {
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
                  child: SingleChildScrollView(),
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
                          if (value != null) {}
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
            return TabBarView(
              controller: _controller,
              children: List.generate(
                  _controller.length, (index) => _bodyWidget(mode: index)),
            );
          },
        ));
  }
}

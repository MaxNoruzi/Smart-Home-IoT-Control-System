import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/model/error_model.dart';
import 'package:iot_project/model/receive_model.dart';
import 'package:iot_project/model/schedule_model.dart';
import 'package:iot_project/utils/utils.dart';
import 'package:meta/meta.dart';

part 'timer_schedule_state.dart';

class TimerScheduleCubit extends Cubit<TimerScheduleState> {
  TimerScheduleCubit({required this.device, required this.keyNumber})
      : super(TimerScheduleInitial()) {
    Utils.client.addFunction(onListen);
  }
  @override
  Future<void> close() {
    Utils.client.removeFunction(onListen);
    return super.close();
  }
  Device device;
  int keyNumber;
  DateTime? timerSelectedTime;
  bool timerStarted = false;
  // "users/" + Utils.username
  @override
  void emit(TimerScheduleState state) {
    if (!isClosed) super.emit(state);
  }

  void onListen(BaseEvent event) async {
    // BaseEvent event;
    try {
      // event = await compute(
      //     (message) => BaseEvent.fromJson(jsonDecode(message)), model.input);

      // BaseEvent.fromJson(jsonDecode(model.input));
      switch (event.eventType) {
        case EventType.nuAckDelTimer:
          break;
        case EventType.nuAckTimer:
          timerStarted = true;
          emit(Empty());
          break;
        case EventType.unschAck:
          break;
        case EventType.nuTimerDone:
          timerSelectedTime = null;
          timerStarted = false;
          emit(Empty());
          break;
        case EventType.unDelSchedAck:
          break;
        default:
      }
      log("type recived : " + event.eventType.toString());
    } catch (e) {
      if (!e.toString().contains("Sample")) log(e.toString());
    }

    // log(model.input);
  }

  void startTimer() {
    timerStarted = true;
    emit(Empty());
  }

  void timerStop() {
    timerStarted = false;
    emit(Empty());
  }

  int changeStartSunday(int value) {
    if (value == 0) return 6;
    return value - 1;
  }

  void addSchedule({required ScheduleModel model}) {
    int SchedID = (model.time.hour * 3600) * (model.time.minute * 60) +
        (model.weekDays
            .fold(0, (previousValue, element) => previousValue + element));
    String ScheduleTxt = "";
    for (var i = 0; i < model.weekDays.length; i++) {
      ScheduleTxt = ScheduleTxt +
          changeStartSunday(model.weekDays[i]).toString() +
          ((i < model.weekDays.length - 1) ? "," : "");
    }
    log('''
    {
    "Type": "U-Sch",
    "NodeID": "${device.nodeID}",
    "Token": "${device.token}",
    "Schedule": "($ScheduleTxt)-${model.time.toUtc().hour}-${model.time.toUtc().minute}",
    "SchedID": $SchedID,
    "Action": {
        "Key": "K${keyNumber}_${model.state ? 1 : 0}"
    }
    }''');
    Utils.client.publish(Utils.topic, '''
    {
    "Type": "U-Sch",
    "NodeID": "${device.nodeID}",
    "Token": "${device.token}",
    "Schedule": "($ScheduleTxt)-${model.time.toUtc().hour}-${model.time.toUtc().minute}",
    "SchedID": $SchedID,
    "Action": {
        "Key": "K${keyNumber}_${model.state ? 1 : 0}"
    }
    }''');
  }

  void addTimer({required DateTime time}) {
    emit(Loading());
    String timerID =
        ((time.hour * 3600) * (time.minute * 60) + (time.second)).toString();
    log('''
{
    "Type": "U-Timer",
    "NodeID": "${device.nodeID}",
    "Token": "${device.token}",
    "TimerID": ${timerID},
    "Timer": "K${keyNumber}_1-${time.hour}:${time.minute}:${time.second}"
}
''');
    Utils.client.publish(Utils.topic, '''
{
    "Type": "U-Timer",
    "NodeID": "${device.nodeID}",
    "Token": "${device.token}",
    "TimerID": ${timerID},
    "Timer": "K${keyNumber}_1-${time.hour}:${time.minute}:${time.second}"
}
''');
  }

//   ```
// {
//     "Type": "U-Timer",
//     "NodeID": "KEY-CH4-65325648976543",
//     "Token": "dajwkdnakwjodip12qjdnjbnalmksdOJNSLKhskljdhbh",
//     "TimerID": 52260,
//     "Timer": "K2_1-02:25:10"
// }
// ```
}

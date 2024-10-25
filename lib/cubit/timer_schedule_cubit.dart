import 'dart:convert';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/model/error_model.dart';
import 'package:iot_project/model/receive_model.dart';
import 'package:iot_project/model/schedule_model.dart';
import 'package:iot_project/model/timer_model.dart';
import 'package:iot_project/utils/appApi.dart';
import 'package:iot_project/utils/consts.dart';
import 'package:iot_project/utils/utils.dart';
import 'package:meta/meta.dart';
part 'timer_schedule_state.dart';

class TimerScheduleCubit extends Cubit<TimerScheduleState> {
  TimerScheduleCubit({required this.device, required this.keyNumber})
      : super(TimerScheduleInitial()) {
    Utils.client.addFunction(onListen);
    getSchedulesApi();
  }
  @override
  Future<void> close() {
    Utils.client.removeFunction(onListen);
    return super.close();
  }

  List<ScheduleModel> schedules = [];
  List<ScheduleModel> mainSchedules = [];
  Device device;
  int keyNumber;
  DateTime? timerSelectedTime;
  // bool timerStarted = false;
  TimerModel? currentTimer;
  // "users/" + Utils.username
  @override
  void emit(TimerScheduleState state) {
    if (!isClosed) super.emit(state);
  }

  void empty() {
    emit(Empty());
  }

  void onListen(BaseEvent event) async {
    // BaseEvent event;
    try {
      // event = await compute(
      //     (message) => BaseEvent.fromJson(jsonDecode(message)), model.input);
      // BaseEvent.fromJson(jsonDecode(model.input));
      switch (event.eventType) {
        case EventType.nuAckDelTimer:
          timerSelectedTime = null;
          currentTimer = null;
          emit(Empty());
          break;
        case EventType.nuAckTimer:
          currentTimer!.isActive = true;
          addTimerApi(model: currentTimer!);
          emit(Empty());
          break;
        case EventType.unschAck:
          if (schedules
              .where(
                  (element) => element.schedID == (event as UNSchAck).schedID)
              .isNotEmpty) {
            schedules
                .where(
                    (element) => element.schedID == (event as UNSchAck).schedID)
                .first
                .isActive = true;
            addScheduleApi(
                model: schedules
                    .where((element) =>
                        element.schedID == (event as UNSchAck).schedID)
                    .first);
            emit(Empty());
          }
          break;
        case EventType.nuTimerDone:
          timerSelectedTime = null;
          currentTimer == null;
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

  // void startTimer() {
  //   timerStarted = true;
  //   emit(Empty());
  // }

  // void timerStop() {
  //   timerStarted = false;
  //   emit(Empty());
  // }

  int changeStartSunday(int value) {
    if (value == 0) return 6;
    return value - 1;
  }

  void addScheduleApi({required ScheduleModel model}) {
    AppApi.instance.postApi(
      url: "$baseApiUrl/api/set_schedule/",
      body: model.toJson(),
      onSuccess: (response) {
        print(response);
      },
      onError: (error) {
        print(error);
      },
    );
  }

  void getSchedulesApi() {
    emit(Loading());
    AppApi.instance.getApi(
      url: "$baseApiUrl/api/get_schedule/",
      queryParameters: {"nodeID": device.nodeID},
      onSuccess: (response) {
        List<dynamic> temp = jsonDecode(response)["data"];
        mainSchedules..clear();
        temp.forEach((element) {
          mainSchedules.add(ScheduleModel.fromJson(element));
        });
        getTimerApi();
        // emit(Empty());
      },
      onError: (error) {
        print(error);
        emit(Error(error: error, onCall: getSchedulesApi));
      },
    );
  }

  void addSchedule({required ScheduleModel model}) {
    schedules.add(model);
    int SchedID = (model.time.hour * 3600) * (model.time.minute * 60) +
        (model.weekDays
            .fold(0, (previousValue, element) => previousValue + element));
    String ScheduleTxt = "";
    for (var i = 0; i < model.weekDays.length; i++) {
      ScheduleTxt = ScheduleTxt +
          changeStartSunday(model.weekDays[i]).toString() +
          ((i < model.weekDays.length - 1) ? "," : "");
    }
    model.schedID = SchedID;

    // log('''
    // {
    // "Type": "U-Sch",
    // "NodeID": "${device.nodeID}",
    // "Token": "${device.token}",
    // "Schedule": "($ScheduleTxt)-${model.time.toUtc().hour}-${model.time.toUtc().minute}",
    // "SchedID": $SchedID,
    // "Action": {
    //     "Key": "K${keyNumber}_${model.state ? 1 : 0}"
    // }
    // }''');
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

  void deleteSchedule({required ScheduleModel model}) {
    emit(Loading());
    AppApi.instance.postApi(
      url: "$baseApiUrl/api/del_schedule/",
      body: {"nodeID": model.nodeID, "schedID": model.schedID},
      onError: (error) {
        emit(ScaffoldError(
            message:
                "Something went wrong and we could not delete that schedule."));
      },
      onSuccess: (response) {
        mainSchedules.remove(model);
        emit(Empty());
      },
    );
// {
//  "nodeID": "string",
//  "schedID": "string"
// }
  }

  void addTimerApi({required TimerModel model}) {
    AppApi.instance.postApi(
      url: "$baseApiUrl/api/set_timer/",
      body: model.toJson(),
      onSuccess: (response) {
        emit(Empty());
        print(response);
      },
      onError: (error) {
        print(error);
      },
    );
  }

  void getTimerApi() {
    emit(Loading());
    AppApi.instance.getApi(
      url: "$baseApiUrl/api/get_timer/",
      queryParameters: {"nodeID": device.nodeID},
      onSuccess: (response) {
        List<dynamic> temp = jsonDecode(response)["data"];
        if (temp.isNotEmpty) {
          TimerModel newTimer = TimerModel.fromJson(temp.first);
          if (newTimer.keyNumber == keyNumber) {
            currentTimer = newTimer;
          }
        }
        // currentTimer = jsonDecode(response)["data"];

        // List<dynamic> temp = jsonDecode(response)["data"];
        // mainSchedules..clear();
        // temp.forEach((element) {
        //   mainSchedules.add(ScheduleModel.fromJson(element));
        // });
        emit(Empty());
      },
      onError: (error) {
        print(error);
        emit(Error(error: error, onCall: getSchedulesApi));
      },
    );
  }

  void addTimer({required DateTime time}) {
    emit(Loading());
    String timerID =
        ((time.hour * 3600) * (time.minute * 60) + (time.second)).toString();
    currentTimer = TimerModel(
        nodeId: device.nodeID,
        token: device.token,
        timerID: timerID,
        timer: time,
        keyNumber: keyNumber,
        startTime: DateTime.now(),
        isActive: false);
//     log('''
// {
//     "Type": "U-Timer",
//     "NodeID": "${device.nodeID}",
//     "Token": "${device.token}",
//     "TimerID": ${timerID},
//     "Timer": "K${keyNumber}_1-${time.hour}:${time.minute}:${time.second}"
// }
// ''');
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

  void removeTimer({required TimerModel model}) {
    Utils.client.publish(Utils.topic, '''
{
    "Type": "UN-DelTimer",
    "NodeID": "${device.nodeID}",
    "Token": "${device.token}",
    "TimerID": ${model.timerID}
}
''');

//     {
//     "Type": "UN-DelTimer",
//     "NodeID": "KEY-CH4-65325648976543",
//     "Token": "jdlkwasjaipu8wdya8w7dtagywduihajhwoGYouHDuy7w8",
//     "TimerID": 52260
// }
  }
}

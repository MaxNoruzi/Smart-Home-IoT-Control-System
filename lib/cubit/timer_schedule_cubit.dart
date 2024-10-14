import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/model/error_model.dart';
import 'package:iot_project/utils/mqtt_client.dart';
import 'package:iot_project/utils/utils.dart';
import 'package:meta/meta.dart';

part 'timer_schedule_state.dart';

class TimerScheduleCubit extends Cubit<TimerScheduleState> {
  TimerScheduleCubit(
      {required this.device, required this.keyNumber, required this.client})
      : super(TimerScheduleInitial());

  Device device;
  int keyNumber;
  DateTime? timerSelectedTime;
  bool timerStarted = false;
  late MqttService client;
  // "users/" + Utils.username
  @override
  void emit(TimerScheduleState state) {
    if (!isClosed) super.emit(state);
  }

  void startTimer() {
    timerStarted = true;
    emit(Empty());
  }

  void timerStop() {
    timerStarted = false;
    emit(Empty());
  }

  void pwmChange({
    required Device device,
    required int value,
  }) {
    client.publish(Utils.topic, '''
    {
    "Type": "U-Sch",
    "NodeID": "${device.nodeID}",
    "Token": "${device.token}",
    "Schedule": "FR-11-18-22",
    "SchedID": 1265,
    "Event": {
        "Type": "PWM",
        "PWM": $value
        }
    }''');
  }
//   {
//     "Type": "U-Sch",
//     "NodeID": "KEY-CH4-645358",
//     "Token": "<the-token-received-when-node-registration>",
  // "Schedule": "FR-11-18-22",
  // "SchedID": 1265,
//     "Action": {
//         "Key": "K1_1,K2_0,K4_1",
//         "PWM": 88
//     }
// }
}

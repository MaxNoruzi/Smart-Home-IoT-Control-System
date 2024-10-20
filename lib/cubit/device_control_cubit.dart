import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/model/error_model.dart';
import 'package:iot_project/model/receive_model.dart';
import 'package:iot_project/utils/mqtt_client.dart';
import 'package:iot_project/utils/utils.dart';

part 'device_control_state.dart';

class DeviceControlCubit extends Cubit<DeviceControlState> {
  DeviceControlCubit({required this.topic, required this.device})
      : super(Loading()) {
    if (!Utils.client.functionExist(onListen)) {
      Utils.client.addFunction(onListen);
    }
  }
  Device device;
  Set<int> loadingList = {};
  String topic; // "users/" + Utils.username
  @override
  void emit(DeviceControlState state) {
    if (!isClosed) super.emit(state);
  }

  // void onListen(ListenModel model) async {
  void onListen(BaseEvent event) async {
    // BaseEvent event;
    try {
      // event = await compute(
      //     (message) => BaseEvent.fromJson(jsonDecode(message)), model.input);

      // BaseEvent.fromJson(jsonDecode(model.input));
      switch (event.eventType) {
        case EventType.ackKey:
          if ((event as AckResponse).nodeId == device.nodeID) {
            device.keys[(event as AckResponse).ack.key!] =
                (event as AckResponse).ack.eventValue! ? 1 : 0;
            loadingList.remove((event as AckResponse).ack.key);
            emit(Empty());
          }
          break;
        case EventType.ackPwm:
          if ((event as AckResponse).nodeId == device.nodeID) {
            device.pwm = event.ack.pwm;
            emit(Empty());
          }
          break;
        case EventType.event:
          break;
        case EventType.ruu:
          break;
        case EventType.uu:
          Utils.updateDevice(
              nodeID: (event as NodeKeysUpdate).nodeId,
              keys: (event).keys,
              pwm: (event).pwm);
          emit(Empty());
          break;
        default:
      }
      log("type recived : " + event.eventType.toString());
    } catch (e) {
      if (!e.toString().contains("Sample")) log(e.toString());
    }

    // log(model.input);
  }

  void pwmChange({
    required Device device,
    required int value,
  }) {
    Utils.client.publish(topic, '''
    {
    "Type": "Event",
    "NodeID": "${device.nodeID}",
    "Token": "${device.token}",
    "Event": {
        "Type": "PWM",
        "PWM": $value
        }
    }''');
  }

  void onOffModule(
      {required Device device, required int channel, required bool state}) {
    loadingList.add(channel - 1);
    emit(Empty());
//     log('''{
//     "Type": "Event",
//     "NodeID": "${device.nodeID}",
//     "Token": "${device.token}",
//     "Event": {
//         "Type": "Key",
//         "Key": "$channel",
//         "EventValue": "${state ? "ON" : "OFF"}"
//     }
// }''');
    Utils.client.publish(topic, '''{
    "Type": "Event",
    "NodeID": "${device.nodeID}",
    "Token": "${device.token}",
    "Event": {
        "Type": "Key",
        "Key": "$channel",
        "EventValue": "${state ? "ON" : "OFF"}"
    }
}''');
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/model/error_model.dart';
import 'package:iot_project/model/listen_model.dart';
import 'package:iot_project/model/receive_model.dart';
import 'package:iot_project/utils/appApi.dart';
import 'package:iot_project/utils/consts.dart';
import 'package:iot_project/utils/mqtt_client.dart';
import 'package:iot_project/utils/utils.dart';
import 'package:meta/meta.dart';

part 'devices_screen_state.dart';

class DevicesScreenCubit extends Cubit<DevicesScreenState> {
  DevicesScreenCubit() : super(Loading()) {
    Utils.client.setOnConnected(onConnected);
    Utils.client.setOnDisconnected(onDisconnected);
    fetchDevices();
  }
  // late final MqttService client;
  bool onceRefreshed = false;
  @override
  void emit(DevicesScreenState state) {
    if (!isClosed) super.emit(state);
  }

  @override
  Future<void> close() {
    onceRefreshed = true;
    Utils.client.client.unsubscribe("users/" + Utils.username);
    if (Utils.client.functionExist(onListen)) {
      Utils.client.removeFunction(onListen);
    }
    return super.close();
  }

  void _startClient() async {
    if (!Utils.client.isConnected()) {
      await Utils.client.connect();
      subscribeToTopic();
      if (!Utils.client.functionExist(onListen)) {
        Utils.client.addFunction(onListen);
      }
    }
    fetchStatus();
  }

  // void onListen(ListenModel model) async {
  void onListen(BaseEvent event) async {
    // BaseEvent event;
    // event = await compute(
    //     (message) => BaseEvent.fromJson(jsonDecode(message)), model.input);
    try {
      // event = BaseEvent.fromJson(jsonDecode(model.input));
      switch (event.eventType) {
        case EventType.ackKey:
          break;
        case EventType.ackPwm:
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

  void subscribeToTopic({String? topic}) {
    Utils.client.subscribe(topic ?? ("users/" + Utils.username));
  }

  void onConnected() {
    onceRefreshed = false;
    if (kDebugMode) log("دوباره متصل شدید.");
    // emit(ScaffoldError(message: "دوباره متصل شدید."));
  }

  void onDisconnected() async {
    if (kDebugMode) log("Disconnected");

    Future.delayed(Duration(milliseconds: 500)).then((value) => emit(Error(
        error: ErrorModel(
            title: "قطع ارتباط با سرور لطفا دوباره تلاش کنید.",
            errorStatus: ErrorStatus.connection),
        onCall: () {
          fetchDevices();
        })));
    // }
    await Future.delayed(Duration(milliseconds: 500)).then((value) => emit(
        Error(
            error: ErrorModel(
                title: "قطع ارتباط با سرور لطفا دوباره تلاش کنید.",
                errorStatus: ErrorStatus.connection),
            onCall: () {
              fetchDevices();
            })));
  }

  void fetchStatus({String? topic}) {
    Utils.client.publish(topic ?? ("users/" + Utils.username), '''{
    "Type": "RUU"
    }''');
  }

  void fetchDevices() async {
    emit(Loading());
    AppApi.instance.postApi(
      url: "$baseApiUrl/api/login/",
      body: {"Username": Utils.username, "Password": Utils.password},
      onSuccess: (response) {
        List<Device> deviceList = List<Device>.from(
            (jsonDecode(response)['data']["devices_list"])
                .map((e) => Device.fromJson(e))).toList();
        Utils.deviceList = deviceList;
        emit(DevicesLoaded());
        _startClient();
      },
      onError: (error) async {
        await Future.delayed(Duration(milliseconds: 500)).then((value) => emit(
            Error(
                error: ErrorModel(
                    title: "اتفاقی غیر منتظره رخ داده است .",
                    errorStatus: ErrorStatus.badRequest),
                onCall: () {
                  fetchDevices();
                })));
      },
    );
    // try {
    //   final client = await Utils.createHttpClientWithCertificate();
    //   // Timer(Duration(seconds: 10), () {
    //   //   client.close(); // Close the client if needed
    //   //   emit(Error(
    //   //       error: ErrorModel(
    //   //           title: "اتفاقی غیر منتظره رخ داده است .",
    //   //           errorStatus: ErrorStatus.badRequest),
    //   //       onCall: () {
    //   //         fetchDevices();
    //   //       }));
    //   //   return;
    //   // });
    //   final response = await client.post(
    //     Uri.parse("$baseApiUrl/api/login/"),
    //     body: jsonEncode(
    //         {"Username": Utils.username, "Password": Utils.password}),
    //     headers: {"Content-Type": "application/json"},
    //   );

    //   if (response.statusCode == 200) {
    //     List<Device> deviceList = List<Device>.from(
    //         (jsonDecode(response.body)['data']["devices_list"])
    //             .map((e) => Device.fromJson(e))).toList();
    //     Utils.deviceList = deviceList;
    //     emit(DevicesLoaded());
    //     _startClient();
    //   } else {
    //     if (response.body != "" &&
    //         jsonDecode(response.body)["status"] != null) {
    //       return jsonDecode(response.body)["status"];
    //     }
    //     await Future.delayed(Duration(milliseconds: 500)).then((value) => emit(
    //         Error(
    //             error: ErrorModel(
    //                 title: "اتفاقی غیر منتظره رخ داده است .",
    //                 errorStatus: ErrorStatus.badRequest),
    //             onCall: () {
    //               fetchDevices();
    //             })));

    //     // return "اتفاقی غیر منتظره رخ داده است .";
    //   }
    // } catch (e) {
    //   // "اتفاقی غیر منتظره رخ داده است ."
    //   await Future.delayed(Duration(milliseconds: 500)).then((value) => emit(
    //       Error(
    //           error: ErrorModel(
    //               title: e.toString(), errorStatus: ErrorStatus.badRequest),
    //           onCall: () {
    //             fetchDevices();
    //           })));
    //   ;
    // }
  }
}

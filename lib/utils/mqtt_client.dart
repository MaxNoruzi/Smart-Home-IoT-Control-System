import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:iot_project/model/listen_model.dart';
import 'package:iot_project/model/receive_model.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttService(
      {required String broker,
      required String clientId,
      required void Function() onDisconnected,
      required void Function() onConnected}) {
    client = MqttServerClient(broker, clientId);
    client.port = 1883; // Default MQTT port
    client.keepAlivePeriod = double.maxFinite.toInt();
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
  }
  late MqttServerClient client;
  // List<void Function(ListenModel model)> listenerList = [];
  // void addFunction(void Function(ListenModel model) function) {
  //   listenerList.add(function);
  // }

  // void removeFunction(void Function(ListenModel model) function) {
  //   listenerList.remove(function);
  // }

  // bool functionExist(void Function(ListenModel model) function) {
  //   return listenerList.contains(function);
  // }
  List<void Function(BaseEvent event)> listenerList = [];
  void addFunction(void Function(BaseEvent model) function) {
    listenerList.add(function);
  }

  void removeFunction(void Function(BaseEvent model) function) {
    listenerList.remove(function);
  }

  bool functionExist(void Function(BaseEvent model) function) {
    return listenerList.contains(function);
  }

  void setOnConnected(void Function() onConnected) {
    client.onConnected = onConnected;
  }

  void setOnDisconnected(void Function() onDisconnected) {
    client.onDisconnected = onDisconnected;
  }

  MqttConnectionState? checkStatus() {
    return client.connectionStatus?.state;
  }

  bool isConnected() {
    if (client.connectionStatus == null) return false;
    return (client.connectionStatus?.state == MqttConnectionState.connected);
  }

  Future<void> connect() async {
    try {
      await client.connect("solana", "Nima@1379");
    } catch (e) {
      print('Connection failed: $e');
      client.disconnect();
    }
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
    // Listen for incoming messages
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) async {
      final MqttPublishMessage recMess = (c[0].payload as MqttPublishMessage);
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      BaseEvent event;
      try {
        // Todo uncomment this
        event = await compute(
            (message2) => BaseEvent.fromJson(jsonDecode(message2)), message);
        // onListen(input: message, topic: c[0].topic);
        onListen(event: event);
      } catch (e) {
        log(e.toString());
      }

      // print('Received message: $message from topic: ${c[0].topic}>');
    });
  }

  // void onListen({required String input, required String topic}) {
  //   listenerList.forEach((element) {
  //     // compute(element, ListenModel(input: input, topic: topic));
  //     element(ListenModel(input: input, topic: topic));
  //   });
  //   // print('Received message: $input from topic: ${topic}>');
  // }

  void onListen({required BaseEvent event}) {
    listenerList.forEach((element) {
      // compute(element, ListenModel(input: input, topic: topic));
      element(event);
    });
    // print('Received message: $input from topic: ${topic}>');
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  // void onConnected() {
  //   print('Connected to the broker');
  // }

  // void onDisconnected() {
  //   print('Disconnected from the broker');
  // }
}

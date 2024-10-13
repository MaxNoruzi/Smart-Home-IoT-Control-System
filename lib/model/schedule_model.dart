import 'package:iot_project/model/device_model.dart';

class ScheduleModel {
  Device device;
  String weekDays;
  int switchNumber;
  bool isActive;
  DateTime time;
  ScheduleModel(
      {required this.device,
      required this.weekDays,
      required this.switchNumber,
      required this.isActive,
      required this.time});

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      device: json['Device'] ?? '',
      weekDays: json['WeekDays'] ?? '',
      switchNumber: json['SwitchNumber'] ?? 0,
      isActive: json['IsActive'] ?? false,
      time: json['Time'] ?? DateTime.now(),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'NodeID': nodeID,
  //     'Token': token,
  //     'Channel': channel,
  //   };
  // }
}

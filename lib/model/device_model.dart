class Device {
  String nodeID;
  String token;
  int channel;
  List<int> keys;
  int? pwm;
  Device(
      {required this.nodeID,
      required this.token,
      required this.channel,
      required this.keys,
      this.pwm});

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
        nodeID: json['NodeID'] ?? '',
        token: json['Token'] ?? '',
        channel: json['Channel'] ?? 0,
        pwm: json['Pwm'] ?? 0,
        keys: List.generate(json['Channel'] ?? 0, (index) => -1));
  }

  Map<String, dynamic> toJson() {
    return {
      'NodeID': nodeID,
      'Token': token,
      'Channel': channel,
    };
  }
}

// class DevicesList {
//   List<Device> devicesList;

//   DevicesList({required this.devicesList});

//   factory DevicesList.fromJson(Map<String, dynamic> json) {
//     return DevicesList(
//       devicesList: List<Device>.from(
//           (json['devices_list'] ?? []).map((x) => Device.fromJson(x))),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'devices_list': devicesList.map((x) => x.toJson()).toList(),
//     };
//   }
// }
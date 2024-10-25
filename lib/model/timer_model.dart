class TimerModel {
  String nodeId;
  String token;
  String timerID;
  DateTime timer;
  DateTime startTime;
  int keyNumber;
  bool isActive;
  TimerModel(
      {required this.nodeId,
      required this.token,
      required this.timerID,
      required this.timer,
      required this.keyNumber,
      required this.isActive,
      required this.startTime});

  // Factory constructor to create an instance from a JSON map
  factory TimerModel.fromJson(Map<String, dynamic> json) {
    return TimerModel(
      nodeId: json['NodeID'] ?? '',
      token: json['Token'] ?? '',
      timerID: json['TimerID'] ?? "",
      timer: json['Timer'] != null
          ? DateTime.parse(json['Timer'])
          : DateTime.now(),
      keyNumber: json['key_number'] ?? 0,
      isActive: json['isActive'] ?? true,
      startTime:  json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
    );
  }

  // Method to convert the object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'NodeID': nodeId,
      'Token': token,
      'TimerID': timerID,
      'Timer': timer.toIso8601String(),
      'key_number': keyNumber,
      'startTime':startTime.toIso8601String()
    };
  }
}

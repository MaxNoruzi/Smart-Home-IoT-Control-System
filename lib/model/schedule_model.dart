class ScheduleModel {
  String nodeID;
  List<String> weekDays;
  int switchNumber;
  bool isActive;
  bool state;
  DateTime time;

  ScheduleModel({
    required this.nodeID,
    required this.weekDays,
    required this.switchNumber,
    required this.isActive,
    required this.time,
    required this.state,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      nodeID: json['nodeID'] ?? '',
      weekDays: List<String>.from(
          json['WeekDays'] ?? []), // Proper type casting for weekDays
      switchNumber: json['SwitchNumber'] ?? 0,
      isActive: json['IsActive'] ?? false,
      time: json['Time'] != null
          ? DateTime.parse(json['Time']) // Parsing DateTime if present
          : DateTime.now(),
      state: json['State'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nodeID': nodeID,
      'WeekDays': weekDays,
      'SwitchNumber': switchNumber,
      'IsActive': isActive,
      'Time': time
          .toIso8601String(), // Converting DateTime to ISO format string for JSON
      'State': state,
    };
  }
}

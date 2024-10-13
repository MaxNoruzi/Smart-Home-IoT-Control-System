// import 'package:iot_project/utils/utils.dart';

// class ReceiveModel {
//   ReceiveTypes type;
//   String nodeId;
//   String token;
//   String keys;
//   Event event;
  
//   ReceiveModel(
//       {required this.type,
//       required this.nodeId,
//       required this.token,
//       required this.event,
//       required this.keys});

//   // Factory method to create an EventModel object from JSON
//   factory ReceiveModel.fromJson(Map<String, dynamic> json) {
//     return ReceiveModel(
//       type: Utils.stringToEnum(json['Type'] ?? ''),
//       nodeId: json['NodeID'] ?? '',
//       token: json['Token'] ?? '',
//       keys: json['Keys'] ?? '',

//       event: Event.fromJson(json['Event'] ?? {}),
//     );
//   }

//   // Method to convert an EventModel object to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'Type': type,
//       'NodeID': nodeId,
//       'Token': token,
//       'Event': event.toJson(),
//     };
//   }
// }

// class Event {
//   String type;
//   String key;
//   String eventValue;

//   Event({
//     required this.type,
//     required this.key,
//     required this.eventValue,
//   });

//   // Factory method to create an Event object from JSON
//   factory Event.fromJson(Map<String, dynamic> json) {
//     return Event(
//       type: json['Type'] ?? '',
//       key: json['Key'] ?? '',
//       eventValue: json['EventValue'] ?? '',
//     );
//   }

//   // Method to convert an Event object to JSON
//   Map<String, dynamic> toJson() {
//     return {
//       'Type': type,
//       'Key': key,
//       'EventValue': eventValue,
//     };
//   }
// }
// Enum representing different event types
enum EventType {
  event,
  uu,      // Update from node
  ruu,     // Request User Update
  ackKey,  // Acknowledgement for Key
  ackPwm   // Acknowledgement for PWM
}

// enum ReceiveTypes { ACK, EVENT, RUU, SAMPLE }
// Base class for all events
abstract class BaseEvent {
  // Enum to store event type
  final EventType eventType;

  BaseEvent(this.eventType);

  // Factory method to distinguish the right event type and return the appropriate class
  factory BaseEvent.fromJson(Map<String, dynamic> json) {
    String typeString = json['Type'] ?? '';
  
    switch (typeString) {
      case 'Event':
        return NodeEvent.fromJson(json);
      case 'UU': // Update from node
        return NodeKeysUpdate.fromJson(json);
      case 'RUU': // Request User Update
        return RequestUserUpdate.fromJson(json);
      case 'UserAckKey': // Acknowledgement for key events
        return AckResponse.fromJson(json, EventType.ackKey);
      case 'UserAckPWM': // Acknowledgement for PWM events
        return AckResponse.fromJson(json, EventType.ackPwm);
      default:
        throw Exception('Unknown event type: $typeString');
    }
  }
}

// Model for Node Registration
class NodeRegistration extends BaseEvent {
  String username;
  String userPassword;
  String nodeId;
  int channelNum;

  NodeRegistration({
    required this.username,
    required this.userPassword,
    required this.nodeId,
    required this.channelNum,
  }) : super(EventType.event);

  factory NodeRegistration.fromJson(Map<String, dynamic> json) {
    return NodeRegistration(
      username: json['Username'] ?? '',
      userPassword: json['Password'] ?? '',
      nodeId: json['NodeID'] ?? '',
      channelNum: json['ChannelNum'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Username': username,
      'Password': userPassword,
      'NodeID': nodeId,
      'ChannelNum': channelNum,
    };
  }
}

// Model for Keys Update from Node (UU)
class NodeKeysUpdate extends BaseEvent {
  String token;
  String nodeId;
  String keys;
  int pwm;

  NodeKeysUpdate({
    required this.token,
    required this.nodeId,
    required this.keys,
    required this.pwm,
  }) : super(EventType.uu);

  factory NodeKeysUpdate.fromJson(Map<String, dynamic> json) {
    return NodeKeysUpdate(
      token: json['Token'] ?? '',
      nodeId: json['NodeID'] ?? '',
      keys: json['Keys'] ?? '',
      pwm: json['PWM'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Token': token,
      'NodeID': nodeId,
      'Keys': keys,
      'PWM': pwm,
    };
  }
}

// Model for Request User Update (RUU)
class RequestUserUpdate extends BaseEvent {
  String? token;

  RequestUserUpdate({
    this.token,
  }) : super(EventType.ruu);

  factory RequestUserUpdate.fromJson(Map<String, dynamic> json) {
    return RequestUserUpdate(
      token: json['Token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (token != null) 'Token': token,
      'Type': 'RUU',
    };
  }
}

// Model for Node Event (Key or PWM)
class NodeEvent extends BaseEvent {
  String nodeId;
  String token;
  EventDetails event;

  NodeEvent({
    required this.nodeId,
    required this.token,
    required this.event,
  }) : super(EventType.event);

  factory NodeEvent.fromJson(Map<String, dynamic> json) {
    return NodeEvent(
      nodeId: json['NodeID'] ?? '',
      token: json['Token'] ?? '',
      event: EventDetails.fromJson(json['Event'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NodeID': nodeId,
      'Token': token,
      'Event': event.toJson(),
    };
  }
}

// EventDetails Model (For Key or PWM Events)
class EventDetails {
  String type;
  String? key;
  String? eventValue;
  int? pwm;

  EventDetails({
    required this.type,
    this.key,
    this.eventValue,
    this.pwm,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      type: json['Type'] ?? '',
      key: json['Key'],
      eventValue: json['EventValue'],
      pwm: json['PWM'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      if (key != null) 'Key': key,
      if (eventValue != null) 'EventValue': eventValue,
      if (pwm != null) 'PWM': pwm,
    };
  }
}

// Model for Ack Response (for Key or PWM Events)
class AckResponse extends BaseEvent {
  String nodeId;
  String token;
  AckDetails ack;

  AckResponse({
    required this.nodeId,
    required this.token,
    required this.ack,
    required EventType eventType,
  }) : super(eventType);

  factory AckResponse.fromJson(Map<String, dynamic> json, EventType type) {
    return AckResponse(
      nodeId: json['NodeID'] ?? '',
      token: json['Token'] ?? '',
      ack: AckDetails.fromJson(json['Ack'] ?? {}),
      eventType: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NodeID': nodeId,
      'Token': token,
      'Ack': ack.toJson(),
    };
  }
}

// AckDetails Model (For Acknowledge of Key or PWM)
class AckDetails {
  String type;
  int? key;
  bool? eventValue;
  int? pwm;

  AckDetails({
    required this.type,
     this.key,
     this.eventValue,
    this.pwm,
  });

  factory AckDetails.fromJson(Map<String, dynamic> json) {
    return AckDetails(
      type: json['Type'] ?? '',
      key: json['Key'],
      eventValue: json['EventValue'],
      pwm: json['PWM'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Type': type,
      if (key != null) 'Key': key,
      if (eventValue != null) 'EventValue': eventValue,
      if (pwm != null) 'PWM': pwm,
    };
  }
}


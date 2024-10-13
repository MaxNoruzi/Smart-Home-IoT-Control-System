part of 'device_control_cubit.dart';

sealed class DeviceControlState {}

final class DeviceControlInitial extends DeviceControlState {}

class Loading extends DeviceControlState {}

class DevicesLoaded extends DeviceControlState {}

class Empty extends DeviceControlState {}

// class PopFromScreen extends InformationState {}

class Error extends DeviceControlState {
  Error({required this.error, required this.onCall});
  final ErrorModel error;
  final Function onCall;
}

class ScaffoldError extends DeviceControlState {
  ScaffoldError({required this.message});
  final String message;
  // final String id;
}

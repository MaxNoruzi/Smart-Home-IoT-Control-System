part of 'devices_screen_cubit.dart';

sealed class DevicesScreenState {}

final class DevicesScreenInitial extends DevicesScreenState {}

class Loading extends DevicesScreenState {}

class DevicesLoaded extends DevicesScreenState {}

class Empty extends DevicesScreenState {}

// class PopFromScreen extends InformationState {}

class Error extends DevicesScreenState {
  Error({required this.error, required this.onCall});
  final ErrorModel error;
  final Function onCall;
}

class ScaffoldError extends DevicesScreenState {
  ScaffoldError({required this.message});
  final String message;
  // final String id;
}

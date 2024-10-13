part of 'timer_schedule_cubit.dart';

@immutable
sealed class TimerScheduleState {}

final class TimerScheduleInitial extends TimerScheduleState {}

final class DeviceControlInitial extends TimerScheduleState {}

class Loading extends TimerScheduleState {}

class DevicesLoaded extends TimerScheduleState {}

class Empty extends TimerScheduleState {}

// class PopFromScreen extends InformationState {}

class Error extends TimerScheduleState {
  Error({required this.error, required this.onCall});
  final ErrorModel error;
  final Function onCall;
}

class ScaffoldError extends TimerScheduleState {
  ScaffoldError({required this.message});
  final String message;
  // final String id;
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iot_project/cubit/devices_screen_cubit.dart';
import 'package:iot_project/model/device_model.dart';
import 'package:iot_project/model/error_model.dart';
import 'package:meta/meta.dart';

part 'timer_schedule_state.dart';

class TimerScheduleCubit extends Cubit<TimerScheduleState> {
  TimerScheduleCubit({required this.device, required this.keyNumber})
      : super(TimerScheduleInitial());
  Device device;
  int keyNumber;
  DateTime? timerSelectedTime;
  bool timerStarted = false;
  @override
  void emit(TimerScheduleState state) {
    if (!isClosed) super.emit(state);
  }

  void startTimer() {
    timerStarted = true;
    emit(Empty());
  }

  void timerStop() {
    timerStarted = false;
    emit(Empty());
  }
}

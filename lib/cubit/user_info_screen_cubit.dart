import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'user_info_screen_state.dart';

class UserInfoScreenCubit extends Cubit<UserInfoScreenState> {
  UserInfoScreenCubit() : super(UserInfoScreenInitial());
}

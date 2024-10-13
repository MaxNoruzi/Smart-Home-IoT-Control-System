import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'home_page_screen_state.dart';

class HomePageScreenCubit extends Cubit<HomePageScreenState> {
  HomePageScreenCubit() : super(HomePageScreenInitial());
}

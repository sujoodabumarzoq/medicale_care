import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationCubit extends Cubit<int> {
  NavigationCubit() : super(0);

  void setIndex(int index) {
    emit(index);
  }

  void navigateToAppointments() {
    emit(2);
  }

  void goBack() {
    emit(0);
  }
}

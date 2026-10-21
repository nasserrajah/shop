import 'package:flutter_bloc/flutter_bloc.dart';

import 'navigation_event.dart';
import 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<NavigateTo>((event, emit) {
      if (event.index < 0 || event.index >= state.tabCount) return;
      if (event.index == state.index) return;
      emit(state.copyWith(index: event.index));
    });
  }
}

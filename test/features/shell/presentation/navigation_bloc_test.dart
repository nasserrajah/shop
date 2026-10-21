import 'package:flutter_test/flutter_test.dart';
import 'package:shop/features/shell/presentation/bloc/navigation_bloc.dart';
import 'package:shop/features/shell/presentation/bloc/navigation_event.dart';

void main() {
  group('NavigationBloc', () {
    test('starts on the home tab', () {
      final bloc = NavigationBloc();
      addTearDown(bloc.close);

      expect(bloc.state.index, 0);
      expect(bloc.state.isHome, isTrue);
      expect(bloc.state.tabCount, 4);
    });

    test('navigates to a valid tab', () async {
      final bloc = NavigationBloc();
      addTearDown(bloc.close);

      final moved = bloc.stream.firstWhere((state) => state.index == 2);
      bloc.add(const NavigateTo(2));

      expect((await moved).index, 2);
      expect(bloc.state.isHome, isFalse);
    });

    test('ignores the current tab and out-of-range tabs', () async {
      final bloc = NavigationBloc();
      addTearDown(bloc.close);

      final emissions = <int>[];
      final subscription = bloc.stream.listen((state) => emissions.add(state.index));

      bloc.add(const NavigateTo(0));
      bloc.add(const NavigateTo(-1));
      bloc.add(const NavigateTo(4));
      await Future<void>.delayed(Duration.zero);

      expect(emissions, isEmpty);
      expect(bloc.state.index, 0);

      await subscription.cancel();
    });
  });
}

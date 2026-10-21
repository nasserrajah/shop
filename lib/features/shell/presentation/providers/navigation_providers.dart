import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../bloc/navigation_bloc.dart';

final navigationBlocProvider = Provider<NavigationBloc>((ref) {
  final bloc = NavigationBloc();
  ref.onDispose(bloc.close);
  return bloc;
});

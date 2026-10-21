import 'package:equatable/equatable.dart';

class NavigationState extends Equatable {
  const NavigationState({
    this.index = 0,
    this.tabCount = 4,
  });

  final int index;
  final int tabCount;

  bool get isHome => index == 0;

  NavigationState copyWith({int? index, int? tabCount}) {
    return NavigationState(
      index: index ?? this.index,
      tabCount: tabCount ?? this.tabCount,
    );
  }

  @override
  List<Object?> get props => [index, tabCount];
}

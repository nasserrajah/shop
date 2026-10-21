import 'package:equatable/equatable.dart';

abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class NavigateTo extends NavigationEvent {
  const NavigateTo(this.index);

  final int index;

  @override
  List<Object?> get props => [index];
}

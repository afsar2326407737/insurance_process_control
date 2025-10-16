part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  const UserState();

  User? get user => null;
}

final class UserInitial extends UserState {
  @override
  List<Object> get props => [];
}


final class UserLoadingState extends UserState{
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

final class UserSuccessState extends UserState{
  String message;
  final User userdata;
  UserSuccessState(this.message , this.userdata);

  @override
  // TODO: implement props
  List<Object?> get props => [message,userdata];

  @override
  User get user => userdata;
}

final class UserErrorState extends UserState{
  String error;
  UserErrorState(this.error);
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

final class UserPasswordChangedState extends UserState {
  String message;

  UserPasswordChangedState(this.message);

  @override
  List<Object?> get props => throw UnimplementedError();
}
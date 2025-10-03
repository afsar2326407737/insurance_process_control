part of 'user_bloc.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
}

final class UserSignUpEvent extends UserEvent{
  final User user;
  const UserSignUpEvent(this.user);
  @override
  // TODO: implement props
  List<Object?> get props => [user];
}


final class UserLoginEvent extends UserEvent{
  final String userEmail;
  final String userPassword;

  const UserLoginEvent( this.userEmail , this.userPassword);

  @override
  List<Object?> get props => [userEmail,userPassword];
}
import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:i_p_c/model/user_model.dart';

part 'user_event.dart';
part 'user_state.dart';

/// testing purpose only Login data
final _loginUserDetailsManager = User(
  empId: '111',
  name: 'Test Manager',
  email: 'testmanager@gmail.com',
  branch: 'Pune',
  role: 'Manager',
  password: 'test@123',
);
final _loginUserDetailsAgent = User(
  empId: '112',
  name: 'Test Agent',
  email: 'testagent@gmail.com',
  branch: 'Pune',
  role: 'Agent',
  password: 'test@123',
);

/// testing purpose only SignUp data
late User _signupUser;

class UserBloc extends Bloc<UserEvent, UserState> {
  static late User userDetails;

  UserBloc() : super(UserInitial()) {
    on<UserSignUpEvent>(_userSignUpEvent);
    on<UserLoginEvent>(_userLoginEvent);
  }

  // code for the user login state
  FutureOr<void> _userLoginEvent(
    UserLoginEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoadingState());
      await Future.delayed(Duration(seconds: 2));
      if (event.userEmail == _loginUserDetailsManager.email &&
          event.userPassword == _loginUserDetailsManager.password) {
        emit(
          UserSuccessState('Logged In As Manager', _loginUserDetailsManager),
        );
      } else if (event.userEmail == _loginUserDetailsAgent.email &&
          event.userPassword == _loginUserDetailsAgent.password) {
        emit(UserSuccessState('Logged In As Agent', _loginUserDetailsManager));
      } else {
        emit(UserErrorState('User Password or User Name is wrong'));
      }
    } catch (e) {
      emit(UserErrorState(e.toString()));
    }
  }

  // sign up function call in the application
  FutureOr<void> _userSignUpEvent(
    UserSignUpEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoadingState());
      await Future.delayed(Duration(seconds: 2));
      userDetails = User(
        empId: event.user.empId,
        name: event.user.name,
        email: event.user.email,
        branch: event.user.branch,
        role: event.user.role,
        password: event.user.password,
        filePath: event.user.filePath,
      );
      _signupUser = userDetails;
      emit(
        UserSuccessState('User Logged In as ${userDetails.role}', _signupUser),
      );
    } catch (e) {
      emit(UserErrorState(e.toString()));
    }
  }
}

import 'dart:async';
import 'dart:developer' as developer;
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:i_p_c/model/user_model.dart';
import 'package:i_p_c/repository/database_helper.dart';


part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  //static late User userDetails;

  UserBloc() : super(UserInitial()) {
    on<UserSignUpEvent>(_userSignUpEvent);
    on<UserLoginEvent>(_userLoginEvent);
  }


  // sign up function call in the application
  FutureOr<void> _userSignUpEvent(
      UserSignUpEvent event,
      Emitter<UserState> emit,
      ) async {
    try {
      emit(UserLoadingState());
      await DatabaseHelper().insertUser(User(
        empId: event.user.empId,
        name: event.user.name,
        email: event.user.email,
        branch: event.user.branch,
        role: event.user.role,
        password: event.user.password,
        filePath: event.user.filePath,
      ));
      await DatabaseHelper().saveLoginState(event.user.email);

      emit(
        UserSuccessState('User Logged In as ${event.user.role}', event.user),
      );
    } catch (e) {
      emit(UserErrorState(e.toString()));
    }
  }

  // code for the user login state
  FutureOr<void> _userLoginEvent(
    UserLoginEvent event,
    Emitter<UserState> emit,
  ) async {
    try {
      emit(UserLoadingState());
      final user = await DatabaseHelper().getUserByEmail(event.userEmail);
      if (user != null && user.password == event.userPassword) {
        // save the state of the user details in the logged in
        await DatabaseHelper().saveLoginState(user.email);
        emit(UserSuccessState('Logged In As ${user.role}', user));
      } else {
        emit(UserErrorState('User Password or User Name is wrong'));
      }
    } catch (e) {
      emit(UserErrorState(e.toString()));
    }
  }


}

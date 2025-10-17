import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_p_c/components/colors.dart';
import 'package:i_p_c/repository/database_helper.dart';
import 'package:i_p_c/utils/input_fields.dart';
import '../bloc/user_bloc/user_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userNameController = TextEditingController();
  final _userPasswordController = TextEditingController();

  /// prevent from the multiple navigation
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: ColorsClass().button_color_1,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 130,
                  height: 130,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/splash_screen_image.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'I P C',
                  style: GoogleFonts.nunito(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InputFields(
                        _userNameController,
                        'Enter the username or Email',
                        false,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      InputFields(
                        _userPasswordController,
                        'Enter the password',
                        true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                            return 'Password must contain at least one special character';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: BlocProvider(
                            create: (context) => UserBloc(),
                            child: BlocConsumer<UserBloc, UserState>(
                              listener: (context, state) {
                                if (state is UserErrorState) {
                                  final snackBar = SnackBar(
                                    content: Text(state.error),
                                    backgroundColor: Colors.red,
                                  );
                                  ScaffoldMessenger.of(
                                    context,
                                  ).showSnackBar(snackBar);
                                } else if (state is UserSuccessState) {
                                  // if( state.userdata.role == 'Manager' ){
                                  //   context.go('/home_manager');
                                  // }
                                  // else if( state.userdata.role == 'Agent' ){
                                  //   context.go('/home_agent');
                                  // }
                                  if (!_hasNavigated) {
                                    _hasNavigated = true;
                                    GoRouter.of(context).go('/home');
                                  }
                                }
                              },
                              builder: (context, state) {
                                if (state is UserLoadingState) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  );
                                }
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  onPressed: () async {
                                    BlocProvider.of<UserBloc>(context).add(
                                      UserLoginEvent(
                                        _userNameController.text.trim(),
                                        _userPasswordController.text.trim(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.nunito(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.go('/signup'),
                        child: Text(
                          "Don't have the account? Signup",
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF8E2DE2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

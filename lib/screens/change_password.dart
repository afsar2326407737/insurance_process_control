import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/bloc/user_bloc/user_bloc.dart';
import 'package:i_p_c/utils/button_fun.dart';
import 'package:i_p_c/utils/input_fields.dart';
import 'package:i_p_c/utils/scaffold_message_notifier.dart';

class ChangePassword extends StatefulWidget {
  final String empId;

  const ChangePassword({required this.empId, super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            ),
            pinned: true,
            elevation: 0,
            expandedHeight: 140,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  titlePadding: EdgeInsetsDirectional.only(
                    start: 56,
                    bottom: 12,
                    end: 16,
                  ),
                  title: Text(
                    'Change Password',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.asset(
                        'assets/change_password.jpg',
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 40),
                    InputFields(_oldPasswordController, 'Old Password', true),
                    const SizedBox(height: 16),
                    InputFields(_newPasswordController, 'New Password', true),
                    const SizedBox(height: 16),
                    InputFields(
                      _confirmPasswordController,
                      'Confirm Password',
                      true,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocConsumer<UserBloc, UserState>(
          bloc: context.read<UserBloc>(),
          listener: (context, state) {
            if (state is UserErrorState) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            } else if (state is UserPasswordChangedState) {
              MyScaffoldMessenger.scaffoldSuccessMessage(context, 'Password changed successfully!', Colors.green);
              context.pop();
            }
          },
          builder: (context, state) {
            if (state is UserLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            return ButtonsFun(() {
              context.read<UserBloc>().add(
                ChangePasswordEvent(
                  empId: widget.empId,
                  oldPassword: _oldPasswordController.text,
                  newPassword: _newPasswordController.text,
                ),
              );
            }, 'Submit');
          },
        ),
      ),
    );
  }
}

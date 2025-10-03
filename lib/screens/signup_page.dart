import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_p_c/bloc/user_bloc/user_bloc.dart';
import 'package:i_p_c/components/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/user_model.dart';
import '../utils/input_fields.dart';
import '../utils/scaffold_message_notifier.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // controllers
  final _userNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  final _userBranchController = TextEditingController();
  final _userEmpIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _role; // role selected
  File? _pickedFile;

  // instance of the user bloc
  var _userBloc = UserBloc();

  // bottom bar to pick the photo or image from the phone
  Future<void> _pickFileOrCamera() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Take a photo"),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    setState(() => _pickedFile = File(picked.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) {
                    setState(() => _pickedFile = File(picked.path));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _nextPage() {
    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  void _submitForm() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    final userData = {
      "empId": _userEmpIdController.text,
      "name": _userNameController.text,
      "email": _userEmailController.text,
      "branch": _userBranchController.text,
      "role": _role,
      "password": _passwordController.text,
      "file": _pickedFile?.path,
    };

    _userBloc.add(
      UserSignUpEvent(
        User(
          empId: _userEmpIdController.text,
          name: _userNameController.text,
          email: _userEmailController.text,
          branch: _userBranchController.text,
          role: _role ?? 'null',
          password: _passwordController.text,
          filePath: _pickedFile?.path,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
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
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/splash_screen_image.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'I P C',
                  style: GoogleFonts.nunito(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            Column(
                              children: [
                                const SizedBox(height: 20),
                                InputFields(
                                  _userEmpIdController,
                                  'Enter the Employee Id',
                                  false,
                                ),
                                const SizedBox(height: 20),
                                InputFields(
                                  _userNameController,
                                  'Enter the User Name',
                                  false,
                                ),
                                const SizedBox(height: 20),
                                InputFields(
                                  _userEmailController,
                                  'Enter the Email',
                                  false,
                                ),
                              ],
                            ),
                            // Step 2 → Branch
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  InputFields(
                                    _userBranchController,
                                    'Enter the Branch',
                                    false,
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    "Select Role",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 20),
                                  RadioListTile<String>(
                                    title: Text(
                                      "Manager",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    value: "Manager",
                                    groupValue: _role,
                                    onChanged: (String? val) {
                                      setState(() {
                                        _role = val;
                                      });
                                    },
                                  ),
                                  RadioListTile<String>(
                                    title: Text(
                                      "Inspector",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                    value: "Inspector",
                                    groupValue: _role,
                                    onChanged: (String? val) {
                                      setState(() {
                                        _role = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Step 3 → File picker
                            SingleChildScrollView(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  AnimatedContainer(
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.easeInOut,
                                    width: _pickedFile != null ? 200 : 120,
                                    height: _pickedFile != null ? 200 : 120,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: _pickedFile != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            child: Image.file(
                                              _pickedFile!,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.note_add_outlined,
                                            size: 50,
                                            color: Colors.black54,
                                          ),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: _pickFileOrCamera,
                                    child: const Text("Pick File / Camera"),
                                  ),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                            // Step 4 → password creation
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  'Create Password',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 20),
                                InputFields(
                                  _passwordController,
                                  'Enter Password',
                                  true,
                                ),
                                const SizedBox(height: 20),
                                InputFields(
                                  _confirmPasswordController,
                                  'Confirm Password',
                                  true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_currentPage > 0)
                            SizedBox(
                              width: 120,
                              height: 45,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8E2DE2),
                                      Color(0xFF6A82FB),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: _previousPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Back",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          if (_currentPage < 3)
                            SizedBox(
                              width: 120,
                              height: 45,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF8E2DE2),
                                      Color(0xFF6A82FB),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ElevatedButton(
                                  onPressed: _nextPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    "Next",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.white),
                                  ),
                                ),
                              ),
                            )
                          else
                            BlocConsumer<UserBloc, UserState>(
                              bloc: _userBloc,
                              listener: (context, state) {
                                if (state is UserSuccessState) {
                                  MyScaffoldMessenger.scaffoldSuccessMessage(
                                    context,
                                    'Login Successful',
                                    Colors.green,
                                  );
                                  context.go('/home');
                                } else if (state is UserErrorState) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error : ${state.error}'),
                                    ),
                                  );
                                }
                              },
                              builder: (context, state) {
                                if (state is UserLoadingState) {
                                  return CircularProgressIndicator(value: 30);
                                }
                                return SizedBox(
                                  width: 120,
                                  height: 45,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF8E2DE2),
                                          Color(0xFF6A82FB),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _submitForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        "Signup",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      if (_currentPage == 0)
                        TextButton(
                          onPressed: () => context.go('/'),
                          child: const Text("Have an account? Login"),
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

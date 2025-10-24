import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:i_p_c/bloc/user_bloc/user_bloc.dart';
import 'package:i_p_c/components/colors.dart';
import 'package:i_p_c/repository/couchbase_services.dart';
import 'package:i_p_c/utils/button_fun.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import '../model/bank_det_models.dart';
import '../model/user_model.dart';
import '../platform_channels/camera_channel.dart';
import '../repository/database_helper.dart';
import '../utils/image_cropper_helper.dart' show ImageCropperHelper;
import '../utils/input_fields.dart';
import '../utils/scaffold_message_notifier.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// controllers
  final _userNameController = TextEditingController();
  final _userEmailController = TextEditingController();
  String? _userEmpId;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final PageController _pageController = PageController();
  int _currentPage = 0;

  String? _role;
  File? _pickedFile;

  var _userBloc = UserBloc();

  /// validation of the empid
  bool isValidEmpid = false;

  ///Bank branches field
  String? _selectedBranch;
  String? _selectedBankId;

  Future<void> _handleCamera() async {
    context.pop();
    var status = await Permission.camera.status;

    if (status.isDenied || status.isRestricted) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return;
    }

    if (status.isGranted) {
      final pickedFile = await CameraChannel.takePictureNative();
      if (pickedFile != null) {
        log('Camera image path: ${pickedFile.path}' , name: 'SignupPage');
        setState(() {
          _pickedFile = pickedFile;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera permission denied')),
      );
    }
  }

  /// bottom bar to pick the photo or image from the phone
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
                onTap: _handleCamera,
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from gallery"),
                onTap: () async {
                  context.pop();
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

  ///employee id field
  Widget _buildEmpIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Employee ID',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Pinput(
          length: 6,
          keyboardType: TextInputType.text,
          onCompleted: (value) => _userEmpId = value,
          defaultPinTheme: PinTheme(
            width: 50,
            height: 56,
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }

  void _nextPage() async {
    if (_currentPage == 0) {
      if (_userEmpId == null || _userEmpId!.isEmpty || _userEmpId!.length < 6) {
        MyScaffoldMessenger.scaffoldSuccessMessage(
          context,
          "Please enter a valid Employee ID",
          Colors.red,
        );
        return;
      }
      final empIdExists = await DatabaseHelper().doesEmpIdExist(_userEmpId!);
      log('empIdExists: $empIdExists');
      if (empIdExists) {
        setState(() {
          isValidEmpid = false;
        });

        /// Show alert dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Employee ID already exists"),
            content: const Text("Please use a different Employee ID."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return;
      } else {
        print('catched on the else');
        setState(() {
          isValidEmpid = true;
        });
      }
    }

    if (!(_formKey.currentState?.validate() ?? true)) {
      return;
    }

    if (_currentPage < 4 && isValidEmpid) {
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
    if (!(_formKey.currentState?.validate() ?? true)) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      MyScaffoldMessenger.scaffoldSuccessMessage(
        context,
        "Passwords do not match",
        Colors.red,
      );
      return;
    }
    _userBloc.add(
      UserSignUpEvent(
        User(
          empId: _userEmpId!,
          name: _userNameController.text,
          email: _userEmailController.text,
          branch: Banks(
            bankId: _selectedBankId,
            bankName: _selectedBranch,
          ),
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
                  height: MediaQuery.of(context).size.height * 0.47,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: PageView(
                            controller: _pageController,
                            physics: const NeverScrollableScrollPhysics(),
                            children: [
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  _buildEmpIdField(),
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
                                ],
                              ),

                              /// Step 2 → Branch
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 50),
                                    FutureBuilder<BankDet>(
                                      future: CouchbaseServices()
                                          .getBankDetails(),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text(
                                            'Error loading banks: ${snapshot.error}',
                                          );
                                        } else if (!snapshot.hasData ||
                                            snapshot.data!.banks == null ||
                                            snapshot.data!.banks!.isEmpty) {
                                          return const Text(
                                            'No bank data found.',
                                          );
                                        }

                                        final banks = snapshot.data!.banks!;
                                        final bankNames = banks
                                            .map((bank) => bank.bankName ?? '')
                                            .where((name) => name.isNotEmpty)
                                            .toList();
                                        final bankIds = banks
                                            .map((bank) => bank.bankId ?? '')
                                            .where((id) => id.isNotEmpty)
                                            .toList();
                                        return DropdownButtonFormField<String>(
                                          value: _selectedBranch,
                                          decoration: InputDecoration(
                                            labelText: 'Select Bank',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            filled: true,
                                            fillColor: Colors.white,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 10,
                                                  horizontal: 12,
                                                ),
                                          ),
                                          items: bankNames.map((bank) {
                                            return DropdownMenuItem<String>(
                                              value: bank,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(Icons.account_balance, color: Colors.blueAccent),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      bank,
                                                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w500 , fontSize: 16),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedBranch = value;
                                              final index = bankNames
                                                  .indexOf(value!);
                                              _selectedBankId =
                                                  bankIds[index];
                                            });
                                          },
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Bank selection is required';
                                            }
                                            return null;
                                          },
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 50),
                                    Text(
                                      "Select Role",
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: RadioListTile<String>(
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
                                        ),
                                        Expanded(
                                          child: RadioListTile<String>(
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
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Inside your Step 3 → File picker widget
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
                                              borderRadius:
                                                  BorderRadius.circular(12),
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
                                    ButtonsFun(
                                      _pickFileOrCamera,
                                      "Pick File / Camera",
                                    ),
                                    const SizedBox(height: 10),
                                    if (_pickedFile != null)
                                      ButtonsFun(() async {
                                        final cropped =
                                            await ImageCropperHelper.cropImage(
                                              imageFile: _pickedFile!,
                                              title: 'Edit Image',
                                            );
                                        if (cropped != null) {
                                          setState(() {
                                            _pickedFile = cropped;
                                          });
                                        } else {
                                          print('Edit button was clicked');
                                        }
                                      }, "Edit"),

                                    const SizedBox(height: 20),
                                  ],
                                ),
                              ),

                              /// Step 4 → password creation
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
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      if (!RegExp(
                                        r'[!@#$%^&*(),.?":{}|<>]',
                                      ).hasMatch(value)) {
                                        return 'Password must contain at least one special character';
                                      }
                                      return null;
                                    },
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
                                  GoRouter.of(context).go('/home');
                                } else if (state is UserErrorState) {
                                  MyScaffoldMessenger.scaffoldSuccessMessage(
                                    context,
                                    'Error : ${state.error}',
                                    Colors.red,
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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/utils/scaffold_message_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:signature/signature.dart';
import '../bloc/inspection_bloc/inspection_bloc.dart';
import '../repository/database_helper.dart';
import '../utils/image_cropper_helper.dart';
import '../utils/input_fields.dart';

class UploadReportScreen extends StatefulWidget {
  String insuranceId;
  UploadReportScreen({required this.insuranceId, super.key});

  @override
  State<UploadReportScreen> createState() => _UploadReportScreenState();
}

class _UploadReportScreenState extends State<UploadReportScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _insuranceIdController = TextEditingController();

  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
  );

  final List<File?> _pickedFiles = [];
  bool _isVerified = false;
  String _status = 'Pending';

  //get the employee id
  final defaultPinTheme = PinTheme(
    width: 60,
    height: 60,
    textStyle: const TextStyle(
      fontSize: 20,
      color: Colors.black,
      fontWeight: FontWeight.w600,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade400),
    ),
  );

  late final focusedPinTheme = defaultPinTheme.copyWith(
    decoration: defaultPinTheme.decoration!.copyWith(
      border: Border.all(color: Colors.blue, width: 2),
      boxShadow: [
        BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 6),
      ],
    ),
  );

  late final submittedPinTheme = defaultPinTheme.copyWith(
    decoration: defaultPinTheme.decoration!.copyWith(
      border: Border.all(color: Colors.green, width: 2),
    ),
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _insuranceIdController.text = widget.insuranceId;
  }

  @override
  void dispose() {
    _employeeIdController.dispose();
    _insuranceIdController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  /// pick proof images
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
                title: const Text("Take Photo"),
                onTap: () async {
                  context.pop();
                  final picker = ImagePicker();
                  final picked = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (picked != null) {
                    setState(() => _pickedFiles.add(File(picked.path)));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Choose from Gallery"),
                onTap: () async {
                  context.pop();
                  final picker = ImagePicker();
                  final pickedList = await picker.pickMultiImage();
                  if (pickedList != null) {
                    setState(() {
                      _pickedFiles.addAll(pickedList.map((e) => File(e.path)));
                    });
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _removeImage(int index) {
    setState(() => _pickedFiles.removeAt(index));
  }

  Future<void> _verifyEmployeeId() async {
    /// Placeholder for real validation logic
    final bool isempexist = await DatabaseHelper().doesEmpIdExist(
      _employeeIdController.text,
    );
    if (_employeeIdController.text.trim().isNotEmpty && isempexist) {
      setState(() => _isVerified = true);
      MyScaffoldMessenger.scaffoldSuccessMessage(
        context,
        "Employee ID verified!",
        Colors.green,
      );
    } else {
      setState(() => _isVerified = false);
      MyScaffoldMessenger.scaffoldSuccessMessage(
        context,
        "Invalid Employee ID!",
        Colors.red,
      );
    }
  }

  Widget _buildPickedFilesPreview() {
    if (_pickedFiles.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.blueAccent),
          borderRadius: BorderRadius.circular(20),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: _pickedFiles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: FileImage(_pickedFiles[index]!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 32,
                      child: GestureDetector(
                        onTap: () async {
                          final cropped = await ImageCropperHelper.cropImage(
                            imageFile: _pickedFiles[index]!,
                            title: 'Edit Image',
                          );
                          if (cropped != null) {
                            setState(() {
                              _pickedFiles[index] = cropped;
                            });
                          } else {
                            print('Edit button was clicked');
                          }
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removeImage(index),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPickButton() {
    return InkWell(
      onTap: _pickFileOrCamera,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file, color: Colors.blue),
            SizedBox(width: 8),
            Text(
              "Upload Proof Images",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextButton(
        onPressed: () async {
          if (!_isVerified) {
            MyScaffoldMessenger.scaffoldSuccessMessage(context, "Please verify Employee ID first.", Colors.red);
            return;
          }
          final signatureBytes = await _signatureController.toPngBytes();
          if (signatureBytes == null) {
            MyScaffoldMessenger.scaffoldSuccessMessage(context, "Please provide a signature.", Colors.red);

            return;
          }
          context.read<InspectionBloc>().add(
            SubmitReportEvent(
              inspectionId: _insuranceIdController.text,
              empId: _employeeIdController.text,
              media: _pickedFiles,
              signature: signatureBytes,
              status: _status,
            ),
          );
        },
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
        ),
        child: const Text(
          "Submit Report",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            centerTitle: false,
            pinned: true,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => context.pop(),
            ),
            elevation: 0,
            expandedHeight: 100,
            backgroundColor: Colors.transparent,
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF003B71),
                ),
                child: const FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    'Upload Report',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InputFields(
                    _insuranceIdController,
                    'Enter Insurance ID',
                    false,
                    enabled: false,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Enter Employee ID',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 10),
                  Pinput(
                    controller: _employeeIdController,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    onCompleted: (value) {
                      _verifyEmployeeId();
                    },
                    keyboardType: TextInputType.text,
                    inputFormatters: [],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _verifyEmployeeId,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isVerified
                            ? Colors.green
                            : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      icon: Icon(
                        _isVerified
                            ? Icons.check_circle
                            : Icons.verified_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isVerified ? 'Verified' : 'Verify',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _buildPickButton(),
                  const SizedBox(height: 16),
                  _buildPickedFilesPreview(),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Employee Signature",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Signature(
                      controller: _signatureController,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _signatureController.clear,
                        child: Text(
                          "Clear",
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium!.copyWith(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _status,
                    items: [
                      DropdownMenuItem(
                        value: 'Pending',
                        child: Text(
                          'Pending',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Completed',
                        child: Text(
                          'Completed',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    ],
                    onChanged: (value) => setState(() => _status = value!),
                    decoration: InputDecoration(
                      labelText: 'Status of Completion',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  BlocConsumer<InspectionBloc, InspectionState>(
                    bloc: context.read<InspectionBloc>(),
                    listener: (context, state) {
                      if (state is InspectionError) {
                        MyScaffoldMessenger.scaffoldSuccessMessage(
                          context,
                          state.message,
                          Colors.red,
                        );
                      } else if (state is InspReportSubSuccessState) {
                        MyScaffoldMessenger.scaffoldSuccessMessage(
                          context,
                          "Report submitted successfully!",
                          Colors.green,
                        );
                        context.pop();
                        context.read<InspectionBloc>().add(
                          InspectionInitialEvent(),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is InspectionLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return _buildSubmitButton();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

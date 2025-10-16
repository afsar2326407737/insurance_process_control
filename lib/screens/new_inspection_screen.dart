import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:i_p_c/repository/couchbase_services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pinput/pinput.dart';
import 'package:intl/intl.dart';
import '../bloc/inspection_bloc/inspection_bloc.dart';
import '../model/inspection_detailes_model.dart';
import '../utils/image_cropper_helper.dart';
import '../utils/scaffold_message_notifier.dart';

class NewInspectionScreen extends StatefulWidget {
  const NewInspectionScreen({super.key});

  @override
  State<NewInspectionScreen> createState() => _NewInspectionScreenState();
}

class _NewInspectionScreenState extends State<NewInspectionScreen> {
  /// Option selections
  String? _inspectionType;
  String? _priority;
  final String _status = 'Pending';

  /// Stepper state
  int _currentStep = 0;

  /// Form fields
  String? _inspectionId;
  String? _propertyName;
  String? _address;
  final List<File> _images = [];

  DateTime? _assignedDate;
  DateTime? _dueDate;

  /// verify button check
  bool _isVerified = false;

  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            floating: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
              title: Text(
                'New Inspection',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: true,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 10),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Color(0xFF8E2DE2),
                    onPrimary: Colors.white,
                    secondary: Color(0xFF6A82FB),
                  ),
                  canvasColor: Colors.white,
                ),
                child: Stepper(
                  physics: const BouncingScrollPhysics(),
                  type: StepperType.horizontal,
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep += 1);
                    } else {
                      _submitForm();
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() => _currentStep -= 1);
                    }
                  },
                  controlsBuilder: (context, details) {
                    return Column(
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (_currentStep > 0)
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
                                    onPressed: details.onStepCancel,
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
                            const SizedBox(width: 10),
                            BlocConsumer<InspectionBloc, InspectionState>(
                              bloc: context.read<InspectionBloc>(),
                              listener: (context, state) {
                                if (state is InspectionLoaded) {
                                  context.pop();
                                }
                              },
                              builder: (context, state) {
                                if (state is InspectionLoading) {
                                  return const CircularProgressIndicator();
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
                                      onPressed: _isStepComplete(_currentStep)
                                          ? details.onStepContinue
                                          : () {
                                              MyScaffoldMessenger.scaffoldSuccessMessage(
                                                context,
                                                'Complete this step before proceeding',
                                                Colors.red,
                                              );
                                            },
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
                                        _currentStep == 2 ? "Submit" : "Next",
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
                      ],
                    );
                  },
                  steps: [
                    Step(
                      title: const Text('Step 1'),
                      content: Column(
                        children: [
                          _buildInspectionIdField(),
                          const SizedBox(height: 10),
                          _buildTextField(
                            'property_name',
                            'Property Name',
                            (val) => _propertyName = val,
                          ),
                          _buildTextField(
                            'address',
                            'Address',
                            (val) => _address = val,
                          ),
                          const SizedBox(height: 10),
                          _buildImagePicker(),
                        ],
                      ),
                      isActive: _currentStep >= 0,
                    ),
                    Step(
                      title: const Text('Step 2'),
                      content: Column(
                        children: [
                          _buildFilterChips(
                            label: 'Inspection Type',
                            options: [
                              'New Policies',
                              'Renewal',
                              'Damage Claim',
                            ],
                            selected: _inspectionType,
                            onSelected: (val) =>
                                setState(() => _inspectionType = val),
                          ),
                          _buildFilterChips(
                            label: 'Priority',
                            options: ['High', 'Medium', 'Low'],
                            selected: _priority,
                            onSelected: (val) =>
                                setState(() => _priority = val),
                          ),
                          _buildStatusField(),
                        ],
                      ),
                      isActive: _currentStep >= 1,
                    ),
                    Step(
                      title: const Text('Step 3'),
                      content: Column(
                        children: [
                          _buildDatePickerField(
                            label: 'Assigned Date',
                            selectedDate: _assignedDate,
                            onDateSelected: (date) =>
                                setState(() => _assignedDate = date),
                          ),
                          _buildDatePickerField(
                            label: 'Due Date',
                            selectedDate: _dueDate,
                            onDateSelected: (date) =>
                                setState(() => _dueDate = date),
                          ),
                        ],
                      ),
                      isActive: _currentStep >= 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyInspectionId() async {
    if (_inspectionId == null || _inspectionId!.isEmpty) {
      MyScaffoldMessenger.scaffoldSuccessMessage(
        context,
        'Please enter Inspection ID before verifying',
        Colors.red,
      );
      return;
    }
    CouchbaseServices()
        .doesInspectionIdExist(_inspectionId!)
        .then((exists) {
          ;
          if (exists) {
            MyScaffoldMessenger.scaffoldSuccessMessage(
              context,
              'Inspection ID already exists. Please enter a unique ID.',
              Colors.red,
            );
          } else {
            setState(() {
              _isVerified = true;
            });
            MyScaffoldMessenger.scaffoldSuccessMessage(
              context,
              'Inspection ID is valid and unique.',
              Colors.green,
            );
          }
        })
        .catchError((error) {
          MyScaffoldMessenger.scaffoldSuccessMessage(
            context,
            'Error verifying Inspection ID. Please try again.',
            Colors.red,
          );
        });
  }

  void _submitForm() {
    if (!_isStepComplete(0) || !_isStepComplete(1) || !_isStepComplete(2)) {
      MyScaffoldMessenger.scaffoldSuccessMessage(
        context,
        'Please fill all fields before submitting',
        Colors.red,
      );
      return;
    }

    final formattedAssignedDate = DateFormat(
      'yyyy-MM-dd',
    ).format(_assignedDate!);
    final formattedDueDate = DateFormat('yyyy-MM-dd').format(_dueDate!);
    final formattedLastUpdated = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now());

    /// Create Inspection object (adjust fields as per your model)
    final inspection = Inspection(
      inspectionId: _inspectionId!,
      propertyName: _propertyName!,
      address: _address!,
      inspectionType: _inspectionType!,
      priority: _priority!,
      status: _status,
      assignedDate: formattedAssignedDate,
      dueDate: formattedDueDate,
      lastUpdated: formattedLastUpdated,
      syncStatus: 'Not Synced',
      media: _images.map((f) => Media(type: 'image', url: f.path)).toList(),
    );

    /// Dispatch event to bloc
    context.read<InspectionBloc>().add(AddInspection(inspection));
  }

  Widget _buildTextField(String key, String label, Function(String) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextFormField(
            onChanged: onSaved,
            decoration: InputDecoration(
              hintText: 'Enter $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: const Color(0xFFF5F6FA),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildInspectionIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inspection ID',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Pinput(
                length: 6,
                keyboardType: TextInputType.text,
                onCompleted: (value) => setState(() => _inspectionId = value),
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
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: _verifyInspectionId,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isVerified ? Colors.green : Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              child: Text(
                _isVerified ? 'Verified' : 'Verify',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Media Images',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8E2DE2), Color(0xFF6A82FB)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_a_photo, color: Colors.white),
                label: const Text(
                  'Add Image',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _showImageSourceOptions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _images
              .asMap()
              .entries
              .map(
                (entry) => Stack(
                  children: [
                    Image.file(
                      entry.value,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final cropped =
                                  await ImageCropperHelper.cropImage(
                                    imageFile: entry.value,
                                    title: 'Edit Image',
                                  );
                              if (cropped != null) {
                                setState(() {
                                  _images[entry.key] = cropped;
                                });
                              } else {
                                print('Edit button was clicked');
                              }
                            },
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.blue,
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _images.remove(entry.value)),
                            child: const CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              context.pop();
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Gallery'),
            onTap: () {
              context.pop();
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _images.add(File(pickedFile.path)));
      }
    } else {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles != null) {
        setState(() => _images.addAll(pickedFiles.map((x) => File(x.path))));
      }
    }
  }

  /// for the validation
  /// Add this method inside your _NewInspectionScreenState class
  bool _isStepComplete(int step) {
    switch (step) {
      case 0:
        return _isVerified &&
            _inspectionId != null &&
            _propertyName != null &&
            _propertyName!.isNotEmpty &&
            _address != null &&
            _address!.isNotEmpty &&
            _images.isNotEmpty;
      case 1:
        return _inspectionType != null && _priority != null;
      case 2:
        return _assignedDate != null && _dueDate != null;
      default:
        return false;
    }
  }

  Widget _buildFilterChips({
    required String label,
    required List<String> options,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
              color: const Color(0xFFF5F6FA),
            ),
            width: double.infinity,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selected == option;
                return ChoiceChip(
                  label: Text(
                    option,
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                  ),
                  selected: isSelected,
                  onSelected: (_) => onSelected(isSelected ? null : option),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Colors.grey.shade200,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Status',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: _status,
            enabled: false,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? selectedDate,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) onDateSelected(picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
                color: const Color(0xFFF5F6FA),
              ),
              child: Text(
                selectedDate != null
                    ? selectedDate.toLocal().toString().split(' ')[0]
                    : 'Select $label',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

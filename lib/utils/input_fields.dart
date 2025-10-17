import 'package:flutter/material.dart';

class InputFields extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool isPassword;
  final bool? enabled;
  final FormFieldValidator<String>? validator; // ✅ optional validator

  const InputFields(
      this.controller,
      this.labelText,
      this.isPassword, {
        this.enabled = true,
        this.validator,
        super.key,
      });

  @override
  State<InputFields> createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  late bool _showPassword = !widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      enabled: widget.enabled,
      controller: widget.controller,
      obscureText: !_showPassword,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        hintStyle: Theme.of(context).textTheme.bodySmall,
          errorStyle: const TextStyle(fontSize: 12),
        suffixIcon: widget.isPassword
            ? IconButton(
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
          icon: Icon(
            _showPassword ? Icons.visibility : Icons.visibility_off,
          ),
        )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

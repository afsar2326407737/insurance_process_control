import 'package:flutter/material.dart';

class InputFields extends StatefulWidget {
  TextEditingController _controller;
  String _labeltext;
  bool isPassword;
  bool? enabled = true;
  InputFields(this._controller,this._labeltext,this.isPassword,{this.enabled , super.key});

  @override
  State<InputFields> createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  /// this field will enable when this is the password field
  late bool _showPassword = !widget.isPassword;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      controller: widget._controller,
      /// hide the text like password
      obscureText: !_showPassword,
      decoration: InputDecoration(
        labelText: widget._labeltext,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        hintStyle: Theme.of(context).textTheme.bodySmall,
        /// suffix icon when this is the password field
        suffixIcon: widget.isPassword ?? false ? IconButton(
          onPressed: () {
            setState(() {
               _showPassword = !_showPassword;
            });
          },
          icon: Icon(
            _showPassword ? Icons.visibility :  Icons.visibility_off,
          ),
        ) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.5),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class CustomTextForm extends StatefulWidget {
  const CustomTextForm({
    super.key,
    required this.labelText,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.maxLength,
  });

  final String labelText;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function(String)? onFieldSubmitted;
  final int? maxLength;

  @override
  State<CustomTextForm> createState() => _CustomTextFormState();
}

class _CustomTextFormState extends State<CustomTextForm> {
  bool isPasswordHidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      onFieldSubmitted: widget.onFieldSubmitted,
      obscureText: widget.isPassword && isPasswordHidden,
      enableSuggestions: !widget.isPassword,
      autocorrect: !widget.isPassword,
      keyboardType: widget.isPassword
          ? TextInputType.visiblePassword
          : widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        labelText: widget.labelText,
        counterText: '',
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.isPassword
            ? IconButton(
                tooltip: isPasswordHidden ? 'Show password' : 'Hide password',
                icon: Icon(
                  isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

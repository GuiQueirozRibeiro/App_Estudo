import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final bool isForm;
  final bool obscureText;
  final int maxLines;
  final String text;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final void Function(String)? onFieldSubmitted;

  CustomTextField({
    Key? key,
    required this.text,
    this.isForm = true,
    this.focusNode,
    this.controller,
    this.maxLines = 1,
    this.obscureText = false,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.inputFormatters,
    this.validator,
    this.onSaved,
    this.onFieldSubmitted,
  }) : super(key: key) {
    if (controller != null && initialValue != null) {
      controller!.text = initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        labelText: isForm ? text : null,
        hintText: text,
        errorMaxLines: 3,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2.0,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.tertiary,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),
      ),
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      validator: validator,
      onSaved: onSaved,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

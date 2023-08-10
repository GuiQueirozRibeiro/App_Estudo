import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final ValueKey? valueKey;
  final bool obscureText;
  final int maxLines;
  final String text;
  final String? initialValue;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onChanged;
  final void Function(String)? onFieldSubmitted;
  final IconData? icon;
  final VoidCallback? onIconPressed;

  const CustomTextField({
    Key? key,
    required this.text,
    this.valueKey,
    this.maxLines = 1,
    this.obscureText = false,
    this.initialValue,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.icon,
    this.onIconPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: valueKey,
      decoration: InputDecoration(
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
        suffixIcon: IconButton(
          icon: Icon(icon),
          onPressed: onIconPressed,
        ),
      ),
      maxLines: maxLines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}

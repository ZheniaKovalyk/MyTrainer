import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  const InputField(
      {super.key,
      required this.controller,
      required this.hint,
      this.obscure = false,
      this.keyboardType = TextInputType.text,
      this.validator});
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(hintText: hint),
        validator: validator);
  }
}

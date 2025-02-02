import 'dart:ui';
import 'package:flutter/services.dart';

const Color goldColor = Color(0xFFFFD700);
const Color blackColor = Color(0xFF000000);
const Color darkBlueColor = Color(0xFF1E3A8A);
final RegExp allowedChars = RegExp(r'[a-zA-Z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF\u3000@_]+');
final inputFormatter = CustomInputFormatter(allowedChars);

class CustomInputFormatter extends TextInputFormatter {
  final RegExp allowedChars;

  CustomInputFormatter(this.allowedChars);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final filteredText = newValue.text.replaceAll(
      RegExp(r'[^a-zA-Z0-9\u3040-\u309F\u30A0-\u30FF\u4E00-\u9FFF\u3000\u3001\u3002@_]'),
      '',
    );
    return TextEditingValue(
      text: filteredText,
      selection: TextSelection.collapsed(offset: filteredText.length),
    );
  }
}

import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If field is cleared
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Extract only digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Max 10 digits
    if (digitsOnly.length > 10) {
      return oldValue;
    }

    // Format to: xxxx xxx xxx
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digitsOnly.length; i++) {
      // Add space before 5th digit (index 4) and 8th digit (index 7)
      if (i == 4 || i == 7) {
        buffer.write(' ');
      }
      buffer.write(digitsOnly[i]);
    }

    String formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

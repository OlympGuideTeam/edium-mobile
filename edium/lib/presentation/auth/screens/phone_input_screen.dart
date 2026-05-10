import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/shared/widgets/edium_notification.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

part 'phone_input_screen_phone_input_screen.dart';



String _formatPhoneDigits(String digits) {
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i == 3 || i == 6 || i == 8) buf.write(' ');
    buf.write(digits[i]);
  }
  return buf.toString();
}


String _cleanPhoneInput(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 11 &&
      (digits.startsWith('7') || digits.startsWith('8'))) {
    digits = digits.substring(1);
  }
  if (digits.length > 10) digits = digits.substring(0, 10);
  return digits;
}

/// Возвращает 10 цифр номера РФ из произвольного текста или null, если цифр меньше 10.
String? _parseClipboardPhone(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final digits = _cleanPhoneInput(raw);
  return digits.length == 10 ? digits : null;
}

class _PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = _cleanPhoneInput(newValue.text);
    final formatted = _formatPhoneDigits(digits);

    var rawCursor = newValue.selection.baseOffset;
    var digitCount = 0;
    for (var i = 0; i < rawCursor && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9]').hasMatch(newValue.text[i])) digitCount++;
    }

    final rawDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (rawDigits.length == 11 &&
        (rawDigits.startsWith('7') || rawDigits.startsWith('8'))) {
      digitCount = (digitCount - 1).clamp(0, 10);
    }
    digitCount = digitCount.clamp(0, digits.length);

    var cursorPos = 0;
    var counted = 0;
    for (var i = 0; i < formatted.length; i++) {
      if (counted == digitCount) break;
      cursorPos = i + 1;
      if (formatted[i] != ' ') counted++;
    }
    cursorPos = cursorPos.clamp(0, formatted.length);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPos),
    );
  }
}


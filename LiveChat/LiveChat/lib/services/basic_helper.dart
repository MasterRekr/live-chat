import 'package:flutter/material.dart';

class BasicHelper {
  static const String snackBarSuccess = "SUCCESS";
  static const String snackBarError = 'ERROR';

  // SHOW SNACK BAR FUN
  static showSnackBar(BuildContext context, String msg, String? type) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: type == snackBarSuccess
            ? Colors.greenAccent
            : type == snackBarError
                ? Colors.redAccent
                : null,
        content: Text(msg)));
  }

  // IS NULL OR EMPTY CHECKER FUN
  static bool isNullOrEmpty(String? value) {
    if (value == null) {
      return true;
    }
    return value.trim().isEmpty;
  }

  // IS EMAIL VALID CHECKER FUN
  static bool isEmailValid(String email) {
    return !RegExp(r'\S+@\S+\.\S+').hasMatch(email);
  }
}

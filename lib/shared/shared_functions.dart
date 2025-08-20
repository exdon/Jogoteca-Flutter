import 'package:flutter/material.dart';

class SharedFunctions {

  static String capitalize(String text) {
    if (text.isEmpty) return '';
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  static void showSnackMessage({
    required String message,
    required bool mounted,
    required BuildContext context,
  }) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

}
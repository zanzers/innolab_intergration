import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar(String s);

  static void success(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        borderRadius: 12,
        snackPosition: SnackPosition.TOP,

    ));
  }

  static void error(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        borderRadius: 12,
        snackPosition: SnackPosition.TOP,

    ));
  }
  static void info(String message) {
    Get.showSnackbar(
      GetSnackBar(
        message: message,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.blue,
        margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
        borderRadius: 12,
        snackPosition: SnackPosition.TOP,

    ));
  }
}


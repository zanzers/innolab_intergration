// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AAppLoading {
  AAppLoading._();

  static Future<T> showWhile<T>(
    BuildContext context,
    Future<T> Function() futureFn, {
    String? message,
  }) async {
    print('[AAppLoading] SHOW with context');

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black26,
      builder: (_) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    message,
                    style: const TextStyle(color: Colors.white),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );

    try {
      final result = await futureFn();
      return result;
    } finally {
      print('[AAppLoading] HIDE with context');
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  static Future<void> showSuccess(
  BuildContext context,
  String message,
) async {
  late BuildContext dialogContext;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      dialogContext = ctx;

      return Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check, color: Colors.white, size: 40),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    },
  );

  await Future.delayed(const Duration(seconds: 1));

  if (Navigator.canPop(dialogContext)) {
    Navigator.of(dialogContext).pop();
  }
}
}
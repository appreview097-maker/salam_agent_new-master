import 'package:flutter/material.dart';

void showSyncDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // prevent closing by tapping outside
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  strokeWidth: 6.0,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Syncing...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

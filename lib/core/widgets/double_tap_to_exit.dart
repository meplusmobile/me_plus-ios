import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleTapToExit extends StatefulWidget {
  final Widget child;
  final String message;
  final Duration duration;

  const DoubleTapToExit({
    super.key,
    required this.child,
    this.message = 'Press back again to exit',
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<DoubleTapToExit> createState() => _DoubleTapToExitState();
}

class _DoubleTapToExitState extends State<DoubleTapToExit> {
  DateTime? _lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final now = DateTime.now();
        if (_lastBackPressed == null ||
            now.difference(_lastBackPressed!) > widget.duration) {
          _lastBackPressed = now;
          
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.message),
                duration: widget.duration,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }

        // Second press within time window - exit app
        SystemNavigator.pop();
      },
      child: widget.child,
    );
  }
}

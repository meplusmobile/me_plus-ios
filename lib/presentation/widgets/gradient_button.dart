import 'package:flutter/material.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';

class GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool enabled;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.enabled = true,
    this.isLoading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color buttonColor;
    if (!widget.enabled || widget.onPressed == null || widget.isLoading) {
      buttonColor = AppColors.primaryLight; // Disabled
    } else if (_isPressed) {
      buttonColor = AppColors.primaryDark; // Clicked
    } else {
      buttonColor = AppColors.primary; // Default - #FAA72A
    }

    return GestureDetector(
      onTapDown:
          (widget.enabled && widget.onPressed != null && !widget.isLoading)
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: (widget.enabled && widget.onPressed != null && !widget.isLoading)
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel:
          (widget.enabled && widget.onPressed != null && !widget.isLoading)
          ? () => setState(() => _isPressed = false)
          : null,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: buttonColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap:
                  (widget.enabled &&
                      widget.onPressed != null &&
                      !widget.isLoading)
                  ? widget.onPressed
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: Center(
                child: widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

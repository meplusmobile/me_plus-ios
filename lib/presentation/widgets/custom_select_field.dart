import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';

class CustomSelectField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final List<String>? itemLabels; // Optional labels to display
  final ValueChanged<String?> onChanged;
  final bool enabled;

  const CustomSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    this.itemLabels,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use itemLabels if provided, otherwise use items
    final labels = itemLabels ?? items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.disabled,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: enabled ? const Color(0xFFFBFBFB) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE6E6E6), width: 1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE4E5E7).withValues(alpha: 0.24),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: ButtonTheme(
              alignedDropdown: true,
              child: DropdownButton<String>(
                value: value,
                hint: Text(
                  enabled ? 'Select $label' : 'Select school first',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.disabled,
                  ),
                ),
                isExpanded: true,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled ? AppColors.textPrimary : AppColors.disabled,
                  size: 20,
                ),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                borderRadius: BorderRadius.circular(10),
                items: enabled
                    ? List.generate(items.length, (index) {
                        return DropdownMenuItem<String>(
                          value: items[index],
                          child: Text(labels[index]),
                        );
                      })
                    : null,
                onChanged: enabled ? onChanged : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

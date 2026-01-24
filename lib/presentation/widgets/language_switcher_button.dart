import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/presentation/theme/app_colors.dart';

/// A widget that displays a language switcher button
/// Switches between English and Arabic
class LanguageSwitcherButton extends StatelessWidget {
  final Color? iconColor;
  final double? iconSize;
  final EdgeInsets? padding;

  const LanguageSwitcherButton({
    super.key,
    this.iconColor,
    this.iconSize = 24.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showLanguageDialog(context, localeProvider),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.language,
                    color: iconColor ?? AppColors.primary,
                    size: iconSize,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    localeProvider.isArabic ? 'ع' : 'EN',
                    style: TextStyle(
                      color: iconColor ?? AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    LocaleProvider localeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.language, color: AppColors.primary, size: 28),
            const SizedBox(width: 12),
            Text(
              localeProvider.isArabic ? 'اختر اللغة' : 'Select Language',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              title: 'English',
              isSelected: localeProvider.isEnglish,
              onTap: () {
                localeProvider.setLocale('en');
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 12),
            _LanguageOption(
              title: 'العربية',
              isSelected: localeProvider.isArabic,
              onTap: () {
                localeProvider.setLocale('ar');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.secondary,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

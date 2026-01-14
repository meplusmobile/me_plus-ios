import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class MarketBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const MarketBottomNavBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            'dsa 2.png',
            AppLocalizations.of(context)!.t('orders'),
            0,
            context,
          ),
          _buildNavItem(
            'Group 481853.png',
            AppLocalizations.of(context)!.t('notifications'),
            1,
            context,
          ),
          _buildNavItem(
            'Group 481841.png',
            AppLocalizations.of(context)!.t('home'),
            2,
            context,
          ),
          _buildNavItem(
            'Simplification.png',
            AppLocalizations.of(context)!.t('profile'),
            3,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    String imagePath,
    String label,
    int index,
    BuildContext context,
  ) {
    final isSelected = selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          switch (index) {
            case 0:
              context.push('/market-owner/orders');
              break;
            case 1:
              context.push('/market-owner/notifications');
              break;
            case 2:
              context.push('/market-owner/home');
              break;
            case 3:
              context.push('/market-owner/profile');
              break;
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Opacity(
              opacity: isSelected ? 1.0 : 0.5,
              child: Image.asset(
                'assets/images/$imagePath',
                width: 24,
                height: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFFAA72A)
                    : const Color(0xFF8B8B8B),
              ),
            ),
            const SizedBox(height: 8),
            if (isSelected)
              Container(
                height: 5,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.white, Color(0xFFFAA72A), Colors.white],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

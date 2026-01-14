import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 156,
      decoration: BoxDecoration(
        color: const Color(0xFFFBEFDF),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8BCA).withValues(alpha: 0.23),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 13,
            child: TextButton(
              onPressed: () {
                context.go('/student/top10');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'See Top 10',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6B8BCA),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right, size: 12, color: Color(0xFF6B8BCA)),
                ],
              ),
            ),
          ),
          const Positioned(
            top: 33,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Mohamad Ahmad',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFAA72A),
                ),
              ),
            ),
          ),
          Positioned(
            top: 51,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'assets/images/Group 481856.png',
                width: 254,
                height: 93,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 254, height: 93, color: Colors.grey[300]),
              ),
            ),
          ),
          Positioned(
            top: 78,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 17,
                height: 21,
                decoration: const BoxDecoration(
                  color: Color(0xFFFAA72A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LevelCardWidget extends StatelessWidget {
  const LevelCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/box 1.png',
              width: 68,
              height: 79,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 68,
                height: 79,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAA72A).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  size: 40,
                  color: Color(0xFFFAA72A),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level 1',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '80  Expert Points to next level',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildProgressBar(),
      ],
    );
  }

  Widget _buildProgressBar() {
    return SizedBox(
      width: 294,
      height: 28,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFAA72A), Color(0xFFFCC36E)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          Positioned(
            left: 0,
            top: 2,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFFFAA72A),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Center(
                child: Text(
                  '1',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF815C23),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 2,
            child: Opacity(
              opacity: 0.5,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAA72A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Text(
                    '2',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF815C23),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: '520',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: '/',
                    style: TextStyle(color: Color(0xFFF8F8F8)),
                  ),
                  TextSpan(
                    text: '600',
                    style: TextStyle(color: Color(0xFFF9A62A)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

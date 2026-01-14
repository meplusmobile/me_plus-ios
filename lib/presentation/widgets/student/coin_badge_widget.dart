import 'package:flutter/material.dart';

class CoinBadgeWidget extends StatelessWidget {
  final int coins;

  const CoinBadgeWidget({super.key, required this.coins});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B8BCA).withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.5),
                radius: 1.0,
                colors: [Color(0xFFFAA72A), Color(0xFFFCC36E)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.monetization_on,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 4),
          ShaderMask(
            shaderCallback: (bounds) => const RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.0,
              colors: [Color(0xFFFAA72A), Color(0xFFFCC36E)],
            ).createShader(bounds),
            child: Text(
              coins.toString(),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

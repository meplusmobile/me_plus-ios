import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:me_plus/presentation/widgets/student/store_item_card.dart';

class StorePreviewWidget extends StatelessWidget {
  const StorePreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.store, size: 24, color: Color(0xFF6B8BCA)),
                SizedBox(width: 8),
                Text(
                  'Store',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                context.go('/student/store');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAA72A),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                minimumSize: const Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(52),
                ),
              ),
              child: const Text(
                'See more',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 139,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              const StoreItemCard(name: 'Pen', price: 200),
              const SizedBox(width: 16),
              Container(
                width: 122,
                height: 139,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFAA72A), Color(0xFFFCC36E)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.card_giftcard,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const StoreItemCard(name: 'Pen', price: 200),
            ],
          ),
        ),
      ],
    );
  }
}

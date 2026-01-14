import 'package:flutter/material.dart';

class WeekDetailDialog extends StatelessWidget {
  final String weekNumber;
  final String weekLabel;
  final Color color;

  const WeekDetailDialog({
    super.key,
    required this.weekNumber,
    required this.weekLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weekNumber,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.thumb_down,
              title: 'bad behavior',
              description: 'Talking during class',
              points: '-10 XP',
              date: 'MON - 2nd Oct',
              color: const Color(0xFFFF4444),
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.thumb_up,
              title: 'good behavior',
              description: 'submiting homework on time',
              points: '+30 XP',
              date: 'TUE - 3rd Oct',
              color: const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.emoji_events,
              title: 'reward',
              description: 'stayed quiet all class, no interaction.',
              points: '',
              date: 'WED - 4th Oct',
              color: const Color(0xFFFAA72A),
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.thumb_down,
              title: 'bad behavior',
              description: 'Talking during class',
              points: '-10 XP',
              date: 'FRI - 6th Oct',
              color: const Color(0xFFFF4444),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String description,
    required String points,
    required String date,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Color(0xFF8B8B8B),
                      ),
                    ),
                  ],
                ),
              ),
              if (points.isNotEmpty)
                Text(
                  points,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            date,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              color: Color(0xFF8B8B8B),
            ),
          ),
        ],
      ),
    );
  }
}

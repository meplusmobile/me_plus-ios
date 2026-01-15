import 'package:flutter/material.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class FilterModal extends StatefulWidget {
  final RangeValues currentCostRange;
  final String currentStatus;
  final String currentRewardType;
  final Function(RangeValues, String, String) onApply;
  final VoidCallback onReset;
  final List<String>? statusOptions;
  final List<String> rewardTypeOptions;

  const FilterModal({
    super.key,
    required this.currentCostRange,
    required this.currentStatus,
    required this.currentRewardType,
    required this.onApply,
    required this.onReset,
    this.statusOptions,
    this.rewardTypeOptions = const [
      'All',
      'Stationery',
      'Food & Snacks',
      'School Supplies',
      'Others',
    ],
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  late RangeValues _costRange;
  late String _status;
  late String _rewardType;

  @override
  void initState() {
    super.initState();
    _costRange = widget.currentCostRange;
    _status = widget.currentStatus;
    _rewardType = widget.currentRewardType;
  }

  // Helper to translate options if they are keys, or return as is
  String _translateOption(BuildContext context, String option) {
    // Otherwise, return it directly.
    // You might want to map specific English strings to keys if needed.
    final t = AppLocalizations.of(context)!;
    switch (option.toLowerCase()) {
      case 'all':
        return t.t('all');
      case 'owned':
        return t.t('owned');
      case 'on the way':
        return t.t('on_the_way');
      case 'rejected':
        return t.t('rejected');
      case 'pending':
        return t.t('pending');
      case 'stationery':
        return t.t('stationery');
      case 'food & snacks':
        return t.t('food_snacks');
      case 'school supplies':
        return t.t('school_supplies');
      case 'others':
        return t.t('others');
      default:
        return option;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 60,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // Spacer to center title
              Text(
                t.t('filters'), // Ensure this key returns "Filters" (Capital F)
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.onReset();
                  Navigator.pop(context);
                },
                child: Text(
                  t.t('reset'),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                t.t('cost'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF505050),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Increased spacing for better visual
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFFF0F0F0), // Light grey track
              inactiveTrackColor: const Color(0xFFF0F0F0),
              thumbColor: const Color(0xFF6B8BCA), // Blue thumb
              overlayColor: const Color(0xFF6B8BCA).withValues(alpha: 0.1),
              trackHeight: 8, // Thicker track
              rangeThumbShape: const RoundRangeSliderThumbShape(
                enabledThumbRadius: 14,
                elevation: 2,
                pressedElevation: 4,
              ),
              rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
              valueIndicatorColor: const Color(0xFF6B8BCA),
              valueIndicatorTextStyle: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
            child: RangeSlider(
              values: _costRange,
              min: 0,
              max: 600,
              labels: RangeLabels(
                _costRange.start.round().toString(),
                _costRange.end.round().toString(),
              ),
              onChanged: (RangeValues values) {
                setState(() {
                  _costRange = values;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _costRange.start.round().toString(),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
                const Text(
                  '600',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (widget.statusOptions != null &&
              widget.statusOptions!.isNotEmpty) ...[
            Text(
              t.t('status'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8B8B8B),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE6E6E6)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _status,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF8B8B8B),
                  ),
                  items: widget.statusOptions!.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        _translateOption(context, value),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2E2E2E),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _status = newValue!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          Text(
            t.t('reward_type'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF8B8B8B),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE6E6E6)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _rewardType,
                isExpanded: true,
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Color(0xFF8B8B8B),
                ),
                items: widget.rewardTypeOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      _translateOption(context, value),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _rewardType = newValue!;
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_costRange, _status, _rewardType);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAA72A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                t.t('apply'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

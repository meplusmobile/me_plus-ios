import 'package:flutter/material.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String _selectedStatus = 'All';
  String _selectedType = 'All';
  String _selectedSort = 'Newest';
  String _selectedPrice = 'Low - High';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 40), // Spacer to center title
              Text(
                AppLocalizations.of(context)!.t('filters'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = 'All';
                    _selectedType = 'All';
                    _selectedSort = 'Newest';
                    _selectedPrice = 'Low - High';
                  });
                },
                child: Text(
                  AppLocalizations.of(context)!.t('reset'),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Color(0xFF8B8B8B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(AppLocalizations.of(context)!.t('status')),
          const SizedBox(height: 12),
          _buildDropdown(
            value: _selectedStatus,
            items: [
              AppLocalizations.of(context)!.t('all'),
              AppLocalizations.of(context)!.t('active'),
              AppLocalizations.of(context)!.t('out_of_stock'),
            ],
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(AppLocalizations.of(context)!.t('reward_type')),
          const SizedBox(height: 12),
          _buildDropdown(
            value: _selectedType,
            items: [
              AppLocalizations.of(context)!.t('all'),
              AppLocalizations.of(context)!.t('stationery'),
              AppLocalizations.of(context)!.t('snacks'),
              AppLocalizations.of(context)!.t('school_supplies'),
              AppLocalizations.of(context)!.t('others'),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(AppLocalizations.of(context)!.t('sort_by')),
          const SizedBox(height: 12),
          _buildDropdown(
            value: _selectedSort,
            items: [
              AppLocalizations.of(context)!.t('newest'),
              AppLocalizations.of(context)!.t('oldest'),
              AppLocalizations.of(context)!.t('most_popular'),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSort = value!;
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(AppLocalizations.of(context)!.t('price')),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildRadioOption(
                AppLocalizations.of(context)!.t('low_to_high'),
                _selectedPrice == 'Low - High',
                () {
                  setState(() {
                    _selectedPrice = 'Low - High';
                  });
                },
              ),
              const SizedBox(width: 24),
              _buildRadioOption(
                AppLocalizations.of(context)!.t('high_to_low'),
                _selectedPrice == 'High - Low',
                () {
                  setState(() {
                    _selectedPrice = 'High - Low';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFAA72A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.t('apply'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF8B8B8B),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE0E0E0)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF8B8B8B)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Color(0xFF2E2E2E),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRadioOption(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFAA72A)
                    : const Color(0xFFE0E0E0),
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFFAA72A),
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Color(0xFF2E2E2E),
            ),
          ),
        ],
      ),
    );
  }
}

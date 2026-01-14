import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:me_plus/data/models/child_model.dart';
import 'package:me_plus/data/models/child_reward_model.dart';
import 'package:me_plus/data/repositories/parent_repository.dart';
import 'package:me_plus/presentation/providers/children_provider.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class ParentChildPurchasesScreen extends StatefulWidget {
  final String kidId;
  final String? selectedMonth; // Format: "YYYY-MM"

  const ParentChildPurchasesScreen({
    super.key,
    required this.kidId,
    this.selectedMonth,
  });

  @override
  State<ParentChildPurchasesScreen> createState() =>
      _ParentChildPurchasesScreenState();
}

class _ParentChildPurchasesScreenState
    extends State<ParentChildPurchasesScreen> {
  final ParentRepository _repository = ParentRepository();
  List<ChildReward> _rewards = [];
  List<ChildReward> _filteredRewards = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  Child? _child;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRewards);
    _parseSelectedMonth();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChild();
      _loadRewards();
    });
  }

  @override
  void didUpdateWidget(ParentChildPurchasesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data if month parameter changed
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _parseSelectedMonth();
      _loadChild();
      _loadRewards();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _parseSelectedMonth() {
    // Parse the selected month from widget parameter or use current month
    if (widget.selectedMonth != null) {
      try {
        final parts = widget.selectedMonth!.split('-');
        _selectedMonth = DateTime(int.parse(parts[0]), int.parse(parts[1]));
      } catch (e) {
        _selectedMonth = DateTime.now();
      }
    } else {
      _selectedMonth = DateTime.now();
    }
  }

  void _loadChild() {
    final childrenProvider = context.read<ChildrenProvider>();
    _child = childrenProvider.getChildById(widget.kidId);
  }

  void _filterRewards() {
    setState(() {
      final String query = _searchController.text.toLowerCase();
      _filteredRewards = _rewards.where((reward) {
        return reward.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _loadRewards() async {
    if (_child == null) return;

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final monthStrShort = DateFormat('yyyy-M').format(_selectedMonth);

      final rewards = await _repository.getChildRewardInfo(
        schoolId: _child!.schoolId,
        classId: _child!.classId,
        childId: widget.kidId,
        date: monthStrShort,
      );

      if (mounted) {
        setState(() {
          _rewards = rewards;
          _filteredRewards = rewards;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildSearchAndFilter(context),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              )
                            : _error != null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(_error!),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _loadRewards,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : _filteredRewards.isEmpty
                            ? Center(
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.t('no_purchases_found'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 0.8,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                    ),
                                itemCount: _filteredRewards.length,
                                itemBuilder: (context, index) {
                                  final reward = _filteredRewards[index];
                                  return _buildRewardItem(reward);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;
    final childName = _child?.fullName ?? 'Child';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'مشتريات $childName' : "$childName's Purchases",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const Icon(Icons.info_outline, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 20,
          ),
          hintText: AppLocalizations.of(context)!.t('search_here'),
          hintStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textSecondary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildRewardItem(ChildReward reward) {
    return GestureDetector(
      onTap: () => _showRewardDetails(reward),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: reward.image.isNotEmpty
                  ? Image.network(
                      'https://meplus2.blob.core.windows.net/images/${reward.image}',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.card_giftcard,
                          size: 40,
                          color: AppColors.primary,
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2,
                          ),
                        );
                      },
                    )
                  : const Icon(
                      Icons.card_giftcard,
                      size: 40,
                      color: AppColors.primary,
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              reward.name,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Group 481842.png',
                  width: 14,
                  height: 14,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/Group 481842.png',
                    width: 14,
                    height: 14,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.monetization_on,
                      size: 14,
                      color: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${reward.credits}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRewardDetails(ChildReward reward) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Image
                SizedBox(
                  width: 120,
                  height: 120,
                  child: reward.image.isNotEmpty
                      ? Image.network(
                          'https://meplusbh.online/uploads/${reward.image}',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.card_giftcard,
                              size: 60,
                              color: AppColors.primary,
                            );
                          },
                        )
                      : const Icon(
                          Icons.card_giftcard,
                          size: 60,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(height: 16),
                // Item Name
                Text(
                  reward.name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Price
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Group 481842.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => Image.asset(
                        'assets/images/Group 481842.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.monetization_on,
                          size: 20,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${reward.credits}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.t('close'),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

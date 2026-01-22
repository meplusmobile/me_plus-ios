import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/widgets/student/bottom_nav_bar.dart';
import 'package:me_plus/presentation/widgets/student/store_item_card.dart';
import 'package:me_plus/data/repositories/student_repository.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/presentation/providers/profile_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

import 'package:me_plus/presentation/widgets/student/filter_modal.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final StudentRepository _repository = StudentRepository();
  List<StoreReward> _rewards = [];
  List<StoreReward> _filteredRewards = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  final String _sortOrder = 'none'; // 'none', 'low_to_high', 'high_to_low'
  RangeValues _costRange = const RangeValues(0, 600);
  String _rewardTypeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterRewards);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterRewards() {
    setState(() {
      final String query = _searchController.text.toLowerCase();
      _filteredRewards = _rewards.where((reward) {
        final bool matchesSearch = reward.name.toLowerCase().contains(query);
        final bool matchesCost =
            reward.price >= _costRange.start && reward.price <= _costRange.end;

        bool matchesType = true;
        if (_rewardTypeFilter != 'All') {
          final String nameLower = reward.name.toLowerCase();

          if (_rewardTypeFilter == 'Stationery') {
            matchesType =
                nameLower.contains('pen') ||
                nameLower.contains('pencil') ||
                nameLower.contains('notebook') ||
                nameLower.contains('eraser') ||
                nameLower.contains('ruler');
          } else if (_rewardTypeFilter == 'Food & Snacks') {
            matchesType =
                nameLower.contains('snack') ||
                nameLower.contains('food') ||
                nameLower.contains('drink') ||
                nameLower.contains('candy') ||
                nameLower.contains('juice');
          } else if (_rewardTypeFilter == 'School Supplies') {
            matchesType =
                nameLower.contains('bag') ||
                nameLower.contains('book') ||
                nameLower.contains('calculator');
          } else {
            matchesType = true;
          }
        }

        return matchesSearch && matchesCost && matchesType;
      }).toList();
      _applySorting();
    });
  }

  void _applySorting() {
    if (_sortOrder == 'low_to_high') {
      _filteredRewards.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOrder == 'high_to_low') {
      _filteredRewards.sort((a, b) => b.price.compareTo(a.price));
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        currentCostRange: _costRange,
        currentStatus: 'All', // Not used in Store
        currentRewardType: _rewardTypeFilter,
        statusOptions: null, // Hide status in Store
        onApply: (range, status, type) {
          setState(() {
            _costRange = range;
            _rewardTypeFilter = type;
            _filterRewards();
          });
        },
        onReset: () {
          setState(() {
            _costRange = const RangeValues(0, 600);
            _rewardTypeFilter = 'All';
            _filterRewards();
          });
        },
      ),
    );
  }

  Future<void> _loadData({int retryCount = 0}) async {
    if (!mounted) return;

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    if (!profileProvider.hasProfile) {
      await profileProvider.loadProfile();
    }

    if (profileProvider.schoolId == null || profileProvider.classId == null) {
      if (mounted) {
        setState(() {
          _error = 'المتجر غير متاح. بيانات المدرسة أو الصف مفقودة';
          _isLoading = false;
        });
      }
      return;
    }

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final schoolId = profileProvider.schoolId!;
      final classId = profileProvider.classId!;

      final rewards = await _repository.getStoreRewards(
        schoolId: schoolId,
        classId: classId,
        pageSize: 20,
        pageNumber: 1,
      );

      if (mounted) {
        setState(() {
          _rewards = rewards;
          _filteredRewards = rewards;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading store: $e');
      
      // Retry logic for network errors (max 2 retries)
      if (retryCount < 2 && _shouldRetry(e.toString())) {
        debugPrint('🔄 Retrying store load (attempt ${retryCount + 1})...');
        await Future.delayed(Duration(seconds: 1 + retryCount));
        return _loadData(retryCount: retryCount + 1);
      }
      
      if (mounted) {
        setState(() {
          _error = _getUserFriendlyError(e.toString());
          _isLoading = false;
        });
      }
    }
  }
  
  /// Check if error should trigger a retry
  bool _shouldRetry(String error) {
    final lowerError = error.toLowerCase();
    return lowerError.contains('timeout') ||
           lowerError.contains('connection') ||
           lowerError.contains('socket') ||
           lowerError.contains('network');
  }
  
  /// Convert technical errors to user-friendly messages
  String _getUserFriendlyError(String error) {
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('timeout')) {
      return 'انتهت مهلة الاتصال';
    }
    if (lowerError.contains('socket') || lowerError.contains('connection')) {
      return 'لا يوجد اتصال بالإنترنت';
    }
    if (lowerError.contains('401') || lowerError.contains('unauthorized')) {
      return 'انتهت صلاحية الجلسة';
    }
    if (lowerError.contains('404')) {
      return 'لم يتم العثور على المتجر';
    }
    if (lowerError.contains('500') || lowerError.contains('server')) {
      return 'خطأ في الخادم';
    }
    
    // Remove "Exception: " prefix if present
    if (error.startsWith('Exception: ')) {
      return error.substring(11);
    }
    
    return 'خطأ في تحميل المتجر';
  }

  Future<void> _purchaseItem(StoreReward reward) async {
    if (!mounted) return;

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final hasEnoughCredits = profileProvider.credits >= reward.price;

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
                SizedBox(
                  width: 200,
                  height: 80,
                  child: hasEnoughCredits
                      ? Image.asset(
                          'assets/images/Loading1.png',
                          height: 80,
                          fit: BoxFit.contain,
                        )
                      : const Icon(Icons.error_outline, size: 60, color: Colors.red),
                ),
                const SizedBox(height: 24),
                // Confirmation or error text
                if (hasEnoughCredits)
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${AppLocalizations.of(context)!.t('are_you_sure_redeem')}\n',
                        ),
                        TextSpan(
                          text:
                              '${reward.price} ${AppLocalizations.of(context)!.t('coins')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' ${AppLocalizations.of(context)!.t('for_this_reward')}',
                        ),
                      ],
                    ),
                  )
                else
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      children: [
                        TextSpan(
                          text:
                              '${AppLocalizations.of(context)!.t('not_enough_coins')}\n',
                        ),
                        TextSpan(
                          text:
                              '${AppLocalizations.of(context)!.t('you_need')} ',
                        ),
                        TextSpan(
                          text:
                              '${reward.price} ${AppLocalizations.of(context)!.t('coins')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' ${AppLocalizations.of(context)!.t('but_you_have')} ',
                        ),
                        TextSpan(
                          text:
                              '${profileProvider.credits} ${AppLocalizations.of(context)!.t('coins')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),
                // Buttons
                if (hasEnoughCredits)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.t('cancel'),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.t('confirm'),
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
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.t('ok'),
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

    if (confirmed != true) return;

    if (profileProvider.schoolId == null ||
        profileProvider.classId == null ||
        profileProvider.studentId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Purchase not available. Please contact your school administrator.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final schoolId = profileProvider.schoolId!;
      final classId = profileProvider.classId!;
      final studentId = profileProvider.studentId!;

      await _repository.purchaseReward(
        schoolId: schoolId,
        classId: classId,
        studentId: studentId,
        rewardId: reward.id,
      );

      if (mounted) {
        // Don't subtract credits here - will be done after market owner approval
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.t('purchase_request_sent'),
            ),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 3),
          ),
        );

        // Reload data
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.t('purchase_failed')}: ${e.toString()}',
            ),
            backgroundColor: AppColors.errorLight,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildStoreGrid()),
            const BottomNavBar(selectedIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.go('/student/home'),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.store, color: AppColors.secondary, size: 24),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.t('store'),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, child) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/Group 481842.png',
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      profileProvider.credits.toString(),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
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
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _showFilterDialog,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.divider),
              ),
              child: const Icon(
                Icons.tune,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreGrid() {
    return Column(
      children: [
        const SizedBox(height: 16),
        _buildSearchAndFilter(),
        const SizedBox(height: 16),
        Expanded(child: _buildStoreContent()),
      ],
    );
  }

  Widget _buildStoreContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Error loading store',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_filteredRewards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'No items available in store'
                  : 'No items found',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredRewards.length,
        itemBuilder: (context, index) {
          final reward = _filteredRewards[index];
          return StoreItemCard(
            name: reward.name,
            price: reward.price,
            imageUrl: reward.image,
            onTap: () => _purchaseItem(reward),
          );
        },
      ),
    );
  }
}

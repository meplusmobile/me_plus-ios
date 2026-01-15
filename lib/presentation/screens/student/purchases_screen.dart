import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:me_plus/presentation/widgets/student/filter_modal.dart';
import 'package:me_plus/data/repositories/student_repository.dart';
import 'package:me_plus/data/models/store_model.dart';
import 'package:me_plus/presentation/providers/profile_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final StudentRepository _repository = StudentRepository();
  List<Purchase> _purchases = [];
  List<Purchase> _filteredPurchases = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  String _statusFilter = 'All';
  RangeValues _costRange = const RangeValues(0, 600);
  String _rewardTypeFilter = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterPurchases);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPurchases();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterPurchases() {
    setState(() {
      final String query = _searchController.text.toLowerCase();
      _filteredPurchases = _purchases.where((purchase) {
        final matchesSearch =
            purchase.rewardName.toLowerCase().contains(query) ||
            (purchase.market?.toLowerCase().contains(query) ?? false);

        // Cost Filter
        final bool matchesCost =
            purchase.pointsSpent >= _costRange.start &&
            purchase.pointsSpent <= _costRange.end;

        bool matchesStatus = true;
        final String status = purchase.status.toLowerCase();

        if (_statusFilter != 'All') {
          if (_statusFilter == 'Owned') {
            matchesStatus =
                status == 'delivered' ||
                status == 'completed' ||
                status == 'owned';
          } else if (_statusFilter == 'On the way') {
            matchesStatus =
                status == 'in progress' ||
                status == 'in_progress' ||
                status == 'shipped' ||
                status == 'on the way';
          } else if (_statusFilter == 'Rejected') {
            matchesStatus = status == 'rejected' || status == 'cancelled';
          } else if (_statusFilter == 'Pending') {
            matchesStatus = status == 'pending';
          }
        }

        bool matchesType = true;
        if (_rewardTypeFilter != 'All') {
          final String nameLower = purchase.rewardName.toLowerCase();

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

        return matchesSearch && matchesStatus && matchesCost && matchesType;
      }).toList();
    });
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterModal(
        currentCostRange: _costRange,
        currentStatus: _statusFilter == 'all'
            ? 'All'
            : _statusFilter, // Handle initial lowercase 'all'
        currentRewardType: _rewardTypeFilter,
        statusOptions: const [
          'All',
          'Owned',
          'On the way',
          'Rejected',
          'Pending',
        ],
        onApply: (range, status, type) {
          setState(() {
            _costRange = range;
            _statusFilter = status;
            _rewardTypeFilter = type;
            _filterPurchases();
          });
        },
        onReset: () {
          setState(() {
            _costRange = const RangeValues(0, 600);
            _statusFilter = 'All';
            _rewardTypeFilter = 'All';
            _filterPurchases();
          });
        },
      ),
    );
  }

  Future<void> _loadPurchases() async {
    if (!mounted) return;

    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );

    if (!profileProvider.hasProfile) {
      await profileProvider.loadProfile();
    }

    if (profileProvider.schoolId == null ||
        profileProvider.classId == null ||
        profileProvider.studentId == null) {
      if (mounted) {
        setState(() {
          _error =
              'Purchase history not available. Please contact your school administrator.';
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
      final studentId = profileProvider.studentId!;

      final purchases = await _repository.getAllPurchases(
        schoolId: schoolId,
        classId: classId,
        studentId: studentId,
      );

      if (mounted) {
        setState(() {
          _purchases = purchases;
          _filteredPurchases = purchases;
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
                                      onPressed: _loadPurchases,
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              )
                            : _filteredPurchases.isEmpty
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
                                itemCount: _filteredPurchases.length,
                                itemBuilder: (context, index) {
                                  final purchase = _filteredPurchases[index];
                                  return _buildPurchaseItem(purchase);
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
  }  Widget _buildHeader(BuildContext context) {
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
                onPressed: () => context.go('/student/profile'),
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.t('my_purchases'),
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
    return Row(
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
    );
  }

  Widget _buildPurchaseItem(Purchase purchase) {
    Color statusColor;
    String statusLabel;
    final String purchaseStatus = purchase.status.toLowerCase();

    if (purchaseStatus == 'delivered' ||
        purchaseStatus == 'completed' ||
        purchaseStatus == 'owned') {
      statusColor = AppColors.success;
      statusLabel = AppLocalizations.of(context)!.t('owned');
    } else if (purchaseStatus == 'rejected' || purchaseStatus == 'cancelled') {
      statusColor = AppColors.errorDanger;
      statusLabel = AppLocalizations.of(context)!.t('rejected');
    } else if (purchaseStatus == 'in progress' ||
        purchaseStatus == 'in_progress' ||
        purchaseStatus == 'shipped' ||
        purchaseStatus == 'on the way') {
      statusColor = const Color(0xFF8B8BCA);
      statusLabel = AppLocalizations.of(context)!.t('in_progress');
    } else {
      statusColor = AppColors.textSecondary;
      statusLabel = purchase.status.toUpperCase();
    }

    return GestureDetector(
      onTap: () => _showPurchaseDetails(purchase),
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
              child: purchase.image != null && purchase.image!.isNotEmpty
                  ? Image.network(
                      purchase.image!,
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
              purchase.rewardName,
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
                ),
                const SizedBox(width: 4),
                Text(
                  '${purchase.pointsSpent}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusLabel.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDetails(Purchase purchase) {
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
                  child: purchase.image != null && purchase.image!.isNotEmpty
                      ? Image.network(
                          purchase.image!,
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
                  purchase.rewardName,
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
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${purchase.pointsSpent}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Divider
                const Divider(),
                const SizedBox(height: 16),
                // Market Info
                if (purchase.market != null && purchase.market!.isNotEmpty) ...[
                  _buildDetailRow(
                    AppLocalizations.of(context)!.t('market'),
                    purchase.market!,
                  ),
                  const SizedBox(height: 8),
                ],
                if (purchase.marketAddress != null &&
                    purchase.marketAddress!.isNotEmpty) ...[
                  _buildDetailRow(
                    AppLocalizations.of(context)!.t('address'),
                    purchase.marketAddress!,
                  ),
                  const SizedBox(height: 8),
                ],
                _buildDetailRow(
                  AppLocalizations.of(context)!.t('status'),
                  purchase.status,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  AppLocalizations.of(context)!.t('purchase_date'),
                  DateFormat('MMM dd, yyyy').format(purchase.purchaseDate),
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

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

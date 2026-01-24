import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:me_plus/data/repositories/parent_repository.dart';
import 'package:me_plus/data/models/child_report_model.dart';
import 'package:me_plus/data/models/child_model.dart';
import 'package:me_plus/data/models/child_reward_model.dart';
import 'package:me_plus/presentation/providers/children_provider.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class ChildReportScreen extends StatefulWidget {
  final String kidId;
  final String? selectedMonth; // Format: "YYYY-MM"

  const ChildReportScreen({super.key, required this.kidId, this.selectedMonth});

  @override
  State<ChildReportScreen> createState() => _ChildReportScreenState();
}

class _ChildReportScreenState extends State<ChildReportScreen> {
  final ParentRepository _repository = ParentRepository();
  Child? _child;
  ChildReport? _report;
  List<ChildReward> _rewards = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _parseSelectedMonth();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChild();
      _loadReportData();
    });
  }

  @override
  void didUpdateWidget(ChildReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data if month parameter changed
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      _parseSelectedMonth();
      _loadChild();
      _loadReportData();
    }
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

  Future<void> _loadReportData() async {
    if (_child == null) return;

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _error = null;
        });
      }

      final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);
      final monthStrShort = DateFormat(
        'yyyy-M',
      ).format(_selectedMonth); // For reward-info API

      // Fetch all report data in parallel
      final results = await Future.wait([
        _repository.getChildTotalPointsGiven(
          schoolId: _child!.schoolId,
          classId: _child!.classId,
          childId: widget.kidId,
          date: monthStr,
        ),
        _repository.getChildTotalCreditsGiven(
          schoolId: _child!.schoolId,
          classId: _child!.classId,
          childId: widget.kidId,
          date: monthStr,
        ),
        _repository.getChildTotalPointsExchanged(
          schoolId: _child!.schoolId,
          classId: _child!.classId,
          childId: widget.kidId,
          date: monthStr,
        ),
        _repository.getChildTotalCreditsExchanged(
          schoolId: _child!.schoolId,
          classId: _child!.classId,
          childId: widget.kidId,
          date: monthStr,
        ),
        _repository.getChildBehaviorCounts(
          schoolId: _child!.schoolId,
          classId: _child!.classId,
          childId: widget.kidId,
          date: monthStr,
        ),
        _repository.getChildRewardInfo(
          schoolId: _child!.schoolId,
          classId: _child!.classId,
          childId: widget.kidId,
          date: monthStrShort,
        ),
      ]);

      final counts = results[4] as Map<String, int>;
      final rewards = results[5] as List<ChildReward>;

      if (mounted) {
        setState(() {
          _report = ChildReport(
            totalPointsGiven: results[0] as int,
            totalCreditsGiven: results[1] as int,
            totalPointsExchanged: results[2] as double,
            totalCreditsExchanged: results[3] as double,
            positiveCount: counts['positiveCount'] ?? 0,
            negativeCount: counts['negativeCount'] ?? 0,
            childName: _child!.fullName,
          );
          _rewards = rewards;
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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
                            onPressed: _loadReportData,
                            child: Text(
                              AppLocalizations.of(context)!.t('retry'),
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildReportCard(),
                          const SizedBox(height: 24),
                          _buildPurchasesSection(context),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;
    final monthName = DateFormat(
      'MMMM yyyy',
      isArabic ? 'ar' : 'en',
    ).format(_selectedMonth);
    final childName = _child?.fullName ?? 'Child';

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onPressed: () => context.pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/report.png',
                      width: 20,
                      height: 20,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.assessment,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isArabic ? 'تقرير $childName' : "$childName's Report",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  monthName,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard() {
    if (_report == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.t('monthly_overview'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: AppColors.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CustomPaint(
                  painter: DonutChartPainter(
                    good: _report!.positivePercentage,
                    bad: _report!.negativePercentage,
                    average: 0,
                  ),
                  child: Center(
                    child: Text(
                      '${_report!.totalBehaviors}',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(
                    AppColors.success,
                    AppLocalizations.of(context)!.t('positive'),
                  ),
                  const SizedBox(height: 12),
                  _buildLegendItem(
                    AppColors.errorLight,
                    AppLocalizations.of(context)!.t('negative'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '${_report!.totalCreditsGiven}',
                  AppLocalizations.of(context)!.t('coins'),
                  'assets/images/Group 481842.png',
                  const Color(0xFFFF5252),
                  '${_report!.totalCreditsExchanged.toStringAsFixed(2)}%',
                  AppLocalizations.of(context)!.t('since_last_month'),
                  'assets/images/arrow-top-rightred.png',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  '${_report!.totalPointsGiven}',
                  AppLocalizations.of(context)!.t('exchanged_xps'),
                  'assets/images/xp.png',
                  AppColors.success,
                  '${_report!.totalPointsExchanged.toStringAsFixed(2)}%',
                  AppLocalizations.of(context)!.t('since_last_month'),
                  'assets/images/arrow-top-rightgreen.png',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    String iconPath,
    Color color,
    String percentage,
    String subtitle,
    String arrowPath,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                iconPath,
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.circle, color: color, size: 20),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Image.asset(
                arrowPath,
                width: 12,
                height: 12,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.arrow_upward, color: color, size: 12),
              ),
              const SizedBox(width: 4),
              Text(
                percentage,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 9,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasesSection(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;
    final childName = _child?.fullName ?? 'Child';
    final monthStr = DateFormat('yyyy-MM').format(_selectedMonth);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/storeimage.png',
                  width: 20,
                  height: 20,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.shopping_bag,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isArabic ? 'مشتريات $childName' : "$childName's Purchases",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () {
                context.push(
                  '/parent/child-purchases/${widget.kidId}?month=$monthStr',
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.t('view_all'),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _rewards.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    AppLocalizations.of(context)!.t('no_purchases_yet'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = (constraints.maxWidth - 32) / 3;
                  final isSmall = itemWidth < 100;
                  return SizedBox(
                    height: isSmall ? 120 : 140,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _rewards.length > 3 ? 3 : _rewards.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: isSmall ? 12 : 16),
                      itemBuilder: (context, index) {
                        final reward = _rewards[index];
                        return Container(
                          width: itemWidth.clamp(100, 150),
                          padding: EdgeInsets.all(isSmall ? 8 : 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFF0F0F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Center(
                                  child: reward.image.isNotEmpty
                                      ? Image.network(
                                          'https://meplus2.blob.core.windows.net/images/${reward.image}',
                                          fit: BoxFit.contain,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.card_giftcard,
                                            size: isSmall ? 36 : 48,
                                            color: Colors.grey[400],
                                          ),
                                          loadingBuilder:
                                              (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color:
                                                            AppColors.primary,
                                                        strokeWidth: 2,
                                                      ),
                                                );
                                              },
                                        )
                                      : Icon(
                                          Icons.card_giftcard,
                                          size: isSmall ? 36 : 48,
                                          color: Colors.grey[400],
                                        ),
                                ),
                              ),
                              SizedBox(height: isSmall ? 4 : 8),
                              Text(
                                reward.name,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: isSmall ? 12 : 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset(
                                        'assets/images/Group 481842.png',
                                        width: isSmall ? 12 : 14,
                                        height: isSmall ? 12 : 14,
                                        errorBuilder: (_, __, ___) => Icon(
                                          Icons.monetization_on,
                                          size: isSmall ? 12 : 14,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      Text(
                                        ' ${reward.credits}',
                                        style: TextStyle(
                                          fontSize: isSmall ? 11 : 12,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  final double good;
  final double bad;
  final double average;

  DonutChartPainter({
    required this.good,
    required this.bad,
    required this.average,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 20.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double startAngle = -pi / 2;
    final double total = good + bad + average;

    // If no data, show empty gray circle
    if (total == 0) {
      paint.color = Colors.grey.withValues(alpha: 0.2);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        0,
        2 * pi,
        false,
        paint,
      );
      return;
    }

    // Good
    if (good > 0) {
      paint.color = AppColors.success;
      final double sweepAngle = (good / 100) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Bad
    if (bad > 0) {
      paint.color = AppColors.errorLight;
      final double sweepAngle = (bad / 100) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Average
    if (average > 0) {
      paint.color = AppColors.primary;
      final double sweepAngle = (average / 100) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

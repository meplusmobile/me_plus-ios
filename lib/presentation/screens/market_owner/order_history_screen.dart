import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/providers/market_owner_provider.dart';
import 'package:me_plus/presentation/widgets/market_owner/market_bottom_nav_bar.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedMonth = 'this-month';

  List<Map<String, String>> _getMonthOptions(BuildContext context) {
    return [
      {
        'value': 'this-month',
        'label': AppLocalizations.of(context)!.t('this_month'),
      },
      {
        'value': 'last-month',
        'label': AppLocalizations.of(context)!.t('last_month'),
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders();
    });
  }

  void _loadOrders() {
    if (_selectedMonth == 'this-month') {
      context.read<MarketOwnerProvider>().loadThisMonthOrders();
    } else {
      context.read<MarketOwnerProvider>().loadLastMonthOrders();
    }
  }

  void _showMonthPicker() {
    final monthOptions = _getMonthOptions(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.t('select_month'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...monthOptions.map(
              (option) => ListTile(
                title: Text(
                  option['label']!,
                  style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
                ),
                trailing: _selectedMonth == option['value']
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedMonth = option['value']!;
                  });
                  _loadOrders();
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.history, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.t('order_history'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: GestureDetector(
              onTap: _showMonthPicker,
              child: Row(
                children: [
                  Text(
                    _getMonthOptions(context).firstWhere(
                      (opt) => opt['value'] == _selectedMonth,
                    )['label']!,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<MarketOwnerProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final orders = _selectedMonth == 'this-month'
                    ? provider.thisMonthOrders
                    : provider.lastMonthOrders;

                if (orders.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context)!.t('no_order_history'),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final imageUrl = order.reward.image.isNotEmpty
                        ? 'https://meplus2.blob.core.windows.net/images/${order.reward.image}'
                        : '';

                    final now = DateTime.now();
                    final difference = now.difference(order.createdAt);
                    String timeAgo;

                    if (difference.inDays > 0) {
                      timeAgo = AppLocalizations.of(context)!
                          .t('d_ago')
                          .replaceAll('{days}', difference.inDays.toString());
                    } else if (difference.inHours > 0) {
                      timeAgo = AppLocalizations.of(context)!
                          .t('h_ago')
                          .replaceAll('{hours}', difference.inHours.toString());
                    } else if (difference.inMinutes > 0) {
                      timeAgo = AppLocalizations.of(context)!
                          .t('m_ago')
                          .replaceAll(
                            '{minutes}',
                            difference.inMinutes.toString(),
                          );
                    } else {
                      timeAgo = AppLocalizations.of(context)!.t('just_now');
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: imageUrl.isNotEmpty
                                ? NetworkImage(imageUrl)
                                : null,
                            backgroundColor: Colors.grey[200],
                            child: imageUrl.isEmpty
                                ? const Icon(
                                    Icons.card_giftcard,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.studentName,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppLocalizations.of(context)!
                                      .t('requested_for_coins')
                                      .replaceAll('{item}', order.reward.name)
                                      .replaceAll(
                                        '{coins}',
                                        order.reward.credits.toString(),
                                      ),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            timeAgo,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const MarketBottomNavBar(selectedIndex: 0),
        ],
      ),
    );
  }
}

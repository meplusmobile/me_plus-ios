import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/providers/market_owner_provider.dart';
import 'package:me_plus/presentation/providers/market_profile_provider.dart';
import 'package:me_plus/presentation/widgets/market_owner/market_bottom_nav_bar.dart';
import 'package:me_plus/core/localization/app_localizations.dart';

class MarketOwnerHomeScreen extends StatefulWidget {
  const MarketOwnerHomeScreen({super.key});

  @override
  State<MarketOwnerHomeScreen> createState() => _MarketOwnerHomeScreenState();
}

class _MarketOwnerHomeScreenState extends State<MarketOwnerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarketOwnerProvider>().loadItems();
      context.read<MarketOwnerProvider>().loadThisMonthOrders();
      context.read<MarketProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildMyMarketHeader(),
                      const SizedBox(height: 16),
                      _buildItemsGrid(),
                      const SizedBox(height: 24),
                      _buildRecentRequestsHeader(),
                      const SizedBox(height: 16),
                      _buildRecentRequestsList(),
                      const SizedBox(height: 100), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
      bottomNavigationBar: const MarketBottomNavBar(selectedIndex: 2),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    AppLocalizations.of(context)!.t('welcome_back'),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text('👋', style: TextStyle(fontSize: 20)),
                ],
              ),
              const SizedBox(height: 4),
              Consumer<MarketProfileProvider>(
                builder: (context, profileProvider, child) {
                  final profile = profileProvider.profile;
                  final name = profile != null
                      ? '${profile.firstName} ${profile.lastName}'
                      : 'User';
                  return Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyMarketHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.store, color: AppColors.secondary, size: 24),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.t('my_market'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () => context.push('/market-owner/add-reward'),
          icon: const Icon(Icons.add, size: 28, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildItemsGrid() {
    return Column(
      children: [
        Consumer<MarketOwnerProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (provider.items.isEmpty) {
              return Center(
                child: Text(AppLocalizations.of(context)!.t('no_items_yet')),
              );
            }

            // Shuffle items and take only 6
            final shuffledItems = List.from(provider.items)..shuffle();
            final displayItems = shuffledItems.take(6).toList();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: displayItems.length,
              itemBuilder: (context, index) {
                final item = displayItems[index];
                final imageUrl = item.image?.isNotEmpty == true
                    ? item.image
                    : null;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Stack(
                    children: [
                      // Edit Icon
                      Positioned(
                        top: 8,
                        left: 8,
                        child: InkWell(
                          onTap: () {
                            context.push(
                              '/market-owner/edit-reward/${item.id}',
                              extra: item,
                            );
                          },
                          child: const Icon(
                            Icons.edit_square,
                            size: 16,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                      // Image
                      Positioned.fill(
                        top: 24,
                        bottom: 40,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: imageUrl != null
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                        Icons.card_giftcard,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                )
                              : const Icon(
                                  Icons.card_giftcard,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                        ),
                      ),
                      // Name
                      Positioned(
                        bottom: 32,
                        left: 8,
                        right: 8,
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Price
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item.price}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Delete Icon
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.t('delete_reward'),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.t('delete_reward_confirm'),
                                  style: const TextStyle(fontFamily: 'Poppins'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      AppLocalizations.of(context)!.t('cancel'),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text(
                                      AppLocalizations.of(context)!.t('delete'),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              provider.deleteItem(item.id);
                            }
                          },
                          child: const Icon(
                            Icons.delete_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => context.push('/market-owner/items'),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.t('view_all'),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRequestsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.assignment, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.t('recent_reward_requests'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () => context.go('/market-owner/orders'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryVeryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              AppLocalizations.of(context)!.t('view_all'),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRequestsList() {
    return Consumer<MarketOwnerProvider>(
      builder: (context, provider, child) {
        final inProgressOrders = provider.thisMonthOrders
            .where((order) => order.status.toUpperCase() == 'IN PROGRESS')
            .toList();

        // If no orders, show empty state
        if (inProgressOrders.isEmpty) {
          return Center(
            child: Text(AppLocalizations.of(context)!.t('no_recent_requests')),
          );
        }

        final displayCount = inProgressOrders.length > 2
            ? 2
            : inProgressOrders.length;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCount,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = inProgressOrders[index];
            final imageUrl = order.reward.image.isNotEmpty
                ? 'https://meplus2.blob.core.windows.net/images/${order.reward.image}'
                : '';

            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                    radius: 20,
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    backgroundColor: Colors.grey[200],
                    child: imageUrl.isEmpty
                        ? const Icon(
                            Icons.card_giftcard,
                            color: Colors.grey,
                            size: 18,
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
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      _buildActionButton(
                        AppLocalizations.of(context)!.t('accept'),
                        const Color(0xFF88C658),
                        () {
                          provider.approveOrder(order.id);
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildActionButton(
                        AppLocalizations.of(context)!.t('reject'),
                        AppColors.error,
                        () {
                          provider.rejectOrder(order.id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

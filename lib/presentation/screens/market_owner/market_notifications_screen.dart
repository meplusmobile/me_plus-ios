import 'package:flutter/material.dart';
import 'package:me_plus/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:me_plus/presentation/widgets/market_owner/market_bottom_nav_bar.dart';
import 'package:me_plus/data/repositories/market_repository.dart';
import 'package:me_plus/data/models/activity_model.dart';
import 'package:me_plus/core/localization/app_localizations.dart';
import 'package:me_plus/presentation/providers/locale_provider.dart';

class MarketNotificationsScreen extends StatefulWidget {
  const MarketNotificationsScreen({super.key});

  @override
  State<MarketNotificationsScreen> createState() =>
      _MarketNotificationsScreenState();
}

class _MarketNotificationsScreenState extends State<MarketNotificationsScreen> {
  final MarketRepository _repository = MarketRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload notifications every time the screen comes into view
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      if (!mounted) return;

      setState(() {
        _isLoading = true;
        _error = null;
      });

      final notifications = await _repository.getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _repository.markNotificationAsRead(id);

      if (!mounted) return;

      setState(() {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    } catch (e) {
      // Silently fail, not critical
    }
  }

  Future<void> _deleteNotification(int id) async {
    try {
      await _repository.deleteNotification(id);

      if (!mounted) return;

      setState(() {
        _notifications.removeWhere((n) => n.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.t('notification_deleted'),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.t('failed_to_delete')}: ${e.toString()}',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
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
            _buildHeader(),
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
                            onPressed: _loadNotifications,
                            child: Text(
                              AppLocalizations.of(context)!.t('retry'),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildNotificationsList(),
            ),
            const MarketBottomNavBar(selectedIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications, color: AppColors.primary, size: 24),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)!.t('notifications'),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList() {
    if (_notifications.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadNotifications,
        color: AppColors.primary,
        child: ListView(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.t('no_notifications'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          IconData icon;

          switch (notification.type.toLowerCase()) {
            case 'purchase':
            case 'order':
              icon = Icons.shopping_cart;
              break;
            case 'reward':
            case 'achievement':
              icon = Icons.emoji_events;
              break;
            case 'gift':
              icon = Icons.card_giftcard;
              break;
            default:
              icon = Icons.notifications;
          }

          final timeAgo = _getTimeAgo(notification.createdAt);

          return Dismissible(
            key: Key(notification.id.toString()),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              _deleteNotification(notification.id);
            },
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: InkWell(
              onTap: () {
                if (!notification.isRead) {
                  _markAsRead(notification.id);
                }
                context.go('/market-owner/orders');
              },
              borderRadius: BorderRadius.circular(16),
              child: _buildNotificationCard(
                icon: icon,
                messageAr: notification.messageAr ?? notification.message,
                messageEn: notification.messageEn ?? notification.message,
                time: timeAgo,
                hasButtons: notification.type.toLowerCase() == 'purchase',
                isRead: notification.isRead,
                context: context,
                notificationId: notification.id,
                imageUrl: notification.imageUrl,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}${AppLocalizations.of(context)!.t('d_ago')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}${AppLocalizations.of(context)!.t('h_ago')}';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}${AppLocalizations.of(context)!.t('m_ago')}';
    } else {
      return AppLocalizations.of(context)!.t('just_now');
    }
  }

  String _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Azure Blob Storage base URL for images
    const baseUrl = 'https://meplus2.blob.core.windows.net/images';

    final cleanPath = imageUrl.startsWith('/')
        ? imageUrl.substring(1)
        : imageUrl;

    return '$baseUrl/$cleanPath';
  }

  Widget _buildNotificationCard({
    required IconData icon,
    required String messageAr,
    required String messageEn,
    required String time,
    required bool hasButtons,
    required BuildContext context,
    required int notificationId,
    bool isRead = false,
    String? imageUrl,
  }) {
    final localeProvider = context.watch<LocaleProvider>();
    final isArabic = localeProvider.isArabic;

    final message = isArabic ? messageAr : messageEn;

    final fullImageUrl = _getFullImageUrl(imageUrl);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : AppColors.primaryPale,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead ? AppColors.divider : AppColors.primary,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              fullImageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        fullImageUrl,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image fails to load
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryVeryLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    )
                  : Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryVeryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 20),
                    ),
              if (!isRead)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Message in selected language only
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: isRead ? FontWeight.w400 : FontWeight.w500,
                    color: isRead
                        ? AppColors.textMedium
                        : AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                if (hasButtons)
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.t('yes'),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorDanger,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          minimumSize: const Size(0, 0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.t('no'),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (hasButtons) const SizedBox(height: 8),
                Text(
                  time,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

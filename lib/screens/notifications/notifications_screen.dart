// lib/screens/notifications/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bliindaidating/app_constants.dart';
import 'package:bliindaidating/controllers/theme_controller.dart';
import 'package:bliindaidating/services/notification_service.dart'; // Import NotificationService
import 'package:bliindaidating/widgets/common/loading_indicator_widget.dart'; // Assuming you have this
import 'package:bliindaidating/widgets/common/empty_state_widget.dart'; // Assuming you have this
// import 'package:bliindaidating/screens/notifications/widgets/notification_item_card.dart'; // Assuming you have this widget

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<String> _notifications = []; // Assuming notifications are strings for now
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNotifications(); // Fetch notifications when the screen initializes
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      final fetchedNotifications = await notificationService.fetchDummyNotifications(count: 10); // Request 10 dummy notifications
      setState(() {
        _notifications = fetchedNotifications;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load notifications: $e';
        debugPrint('Error fetching notifications: $e');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Provider.of<ThemeController>(context);
    final isDarkMode = themeController.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            fontSize: AppConstants.fontSizeExtraLarge,
            color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
          ),
        ),
        backgroundColor: isDarkMode ? AppConstants.cardColor.withOpacity(0.7) : AppConstants.lightCardColor.withOpacity(0.7),
        iconTheme: IconThemeData(color: isDarkMode ? AppConstants.iconColor : AppConstants.lightIconColor),
        elevation: 0, // No shadow for app bar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchNotifications,
            tooltip: 'Refresh Notifications',
          ),
        ],
      ),
      backgroundColor: isDarkMode ? AppConstants.backgroundColor : AppConstants.lightBackgroundColor,
      body: _isLoading
          ? const Center(child: LoadingIndicatorWidget())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppConstants.errorColor),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppConstants.spacingMedium),
                      ElevatedButton(
                        onPressed: _fetchNotifications,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.secondaryColor,
                          foregroundColor: AppConstants.textColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingLarge, vertical: AppConstants.paddingMedium),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: EmptyStateWidget(
                        message: 'No new notifications.',
                        subMessage: 'Check back later for updates on matches, events, and more!',
                        onRefresh: _fetchNotifications,
                        icon: Icons.notifications_active_outlined,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.paddingMedium),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        // Assuming notification_item_card.dart exists and takes a String or a simple object
                        // If it takes a complex object, you'll need to create a NotificationItem model
                        // and ensure your backend returns that structure.
                        return Card(
                          margin: const EdgeInsets.only(bottom: AppConstants.spacingSmall),
                          color: isDarkMode ? AppConstants.cardColor : AppConstants.lightCardColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(AppConstants.paddingMedium),
                            child: Text(
                              notification,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isDarkMode ? AppConstants.textColor : AppConstants.lightTextColor,
                              ),
                            ),
                          ),
                        );
                        // Example if you have NotificationItemCard:
                        // return NotificationItemCard(notification: notification);
                      },
                    ),
    );
  }
}
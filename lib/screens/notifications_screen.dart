import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Upcoming Trip',
      message: 'Your trip from Paris to Lyon is tomorrow at 10:00 AM.',
      time: '2 hours ago',
      isRead: false,
      type: NotificationType.trip,
    ),
    NotificationItem(
      title: 'Special Offer',
      message: '20% off on all bookings this weekend! Use code WEEKEND20.',
      time: '1 day ago',
      isRead: false,
      type: NotificationType.promo,
    ),
    NotificationItem(
      title: 'Booking Confirmed',
      message: 'Your booking #BUS12345 has been confirmed.',
      time: '2 days ago',
      isRead: true,
      type: NotificationType.booking,
    ),
    NotificationItem(
      title: 'Route Update',
      message:
          'The Paris-Marseille route will have additional stops starting next week.',
      time: '3 days ago',
      isRead: true,
      type: NotificationType.update,
    ),
    NotificationItem(
      title: 'Payment Successful',
      message: 'Your payment of €45.00 for booking #BUS12345 was successful.',
      time: '5 days ago',
      isRead: true,
      type: NotificationType.payment,
    ),
    NotificationItem(
      title: 'New Route Available',
      message: 'We\'ve added a new express route from Paris to Nice!',
      time: '1 week ago',
      isRead: true,
      type: NotificationType.update,
    ),
    NotificationItem(
      title: 'Rate Your Trip',
      message: 'How was your recent trip from Lyon to Marseille?',
      time: '1 week ago',
      isRead: true,
      type: NotificationType.feedback,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final int unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all),
              label: const Text('Mark all as read'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(_notifications[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We\'ll notify you when there\'s something new',
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification) {
    return Dismissible(
      key: Key(notification.title + notification.time),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _notifications.remove(notification);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification removed'),
            action: SnackBarAction(
              label: 'UNDO',
              onPressed: () {
                setState(() {
                  _notifications.add(notification);
                  _notifications.sort((a, b) => a.isRead == b.isRead
                      ? 0
                      : a.isRead
                          ? 1
                          : -1);
                });
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: notification.isRead
            ? null
            : AppTheme.primaryColor.withOpacity(0.05),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor:
                _getNotificationColor(notification.type).withOpacity(0.2),
            child: Icon(
              _getNotificationIcon(notification.type),
              color: _getNotificationColor(notification.type),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead
                        ? FontWeight.normal
                        : FontWeight.bold,
                  ),
                ),
              ),
              Text(
                notification.time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(notification.message),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!notification.isRead)
                    TextButton.icon(
                      onPressed: () => _markAsRead(notification),
                      icon: const Icon(Icons.done, size: 16),
                      label: const Text('Mark as read'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 0),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
            ],
          ),
          onTap: () {
            if (!notification.isRead) {
              _markAsRead(notification);
            }
            _showNotificationDetails(notification);
          },
        ),
      ),
    );
  }

  void _markAsRead(NotificationItem notification) {
    setState(() {
      final index = _notifications.indexOf(notification);
      _notifications[index] = notification.copyWith(isRead: true);
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        if (!_notifications[i].isRead) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
      ),
    );
  }

  void _showNotificationDetails(NotificationItem notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      _getNotificationColor(notification.type).withOpacity(0.2),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              notification.time,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              notification.message,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            if (notification.type == NotificationType.trip)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to trip details
                },
                icon: const Icon(Icons.visibility),
                label: const Text('View Trip Details'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            else if (notification.type == NotificationType.promo)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Apply promo code
                },
                icon: const Icon(Icons.local_offer),
                label: const Text('Apply Promo Code'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            else if (notification.type == NotificationType.booking)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // View booking
                },
                icon: const Icon(Icons.confirmation_number),
                label: const Text('View Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                ),
              )
            else if (notification.type == NotificationType.feedback)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Rate trip
                },
                icon: const Icon(Icons.star),
                label: const Text('Rate Your Trip'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.trip:
        return Icons.directions_bus;
      case NotificationType.promo:
        return Icons.local_offer;
      case NotificationType.booking:
        return Icons.confirmation_number;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.update:
        return Icons.update;
      case NotificationType.feedback:
        return Icons.star;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.trip:
        return AppTheme.primaryColor;
      case NotificationType.promo:
        return AppTheme.accentColor;
      case NotificationType.booking:
        return Colors.blue;
      case NotificationType.payment:
        return Colors.green;
      case NotificationType.update:
        return Colors.purple;
      case NotificationType.feedback:
        return Colors.amber;
    }
  }
}

enum NotificationType {
  trip,
  promo,
  booking,
  payment,
  update,
  feedback,
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });

  NotificationItem copyWith({
    String? title,
    String? message,
    String? time,
    bool? isRead,
    NotificationType? type,
  }) {
    return NotificationItem(
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}

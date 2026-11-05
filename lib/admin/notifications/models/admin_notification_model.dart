import 'package:flutter/material.dart';
import 'package:khadematy_web/core/theme/app_colors.dart';

class NotificationModel {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'general';
    IconData icon;
    Color iconColor;

    switch (type) {
      case 'booking':
      case 'new_booking':
        icon = Icons.calendar_today_outlined;
        iconColor = AppColors.burgundy;
        break;
      case 'review':
        icon = Icons.star_outline;
        iconColor = AppColors.gold;
        break;
      case 'status':
      case 'approval':
        icon = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
      default:
        icon = Icons.notifications_outlined;
        iconColor = AppColors.burgundy;
    }

    String timeStr = 'الآن';
    final createdAtStr = json['created_at'] as String?;
    if (createdAtStr != null) {
      try {
        final dt = DateTime.parse(createdAtStr);
        final diff = DateTime.now().difference(dt);
        if (diff.inMinutes < 60) {
          timeStr = diff.inMinutes <= 1 ? 'الآن' : 'منذ ${diff.inMinutes} دقيقة';
        } else if (diff.inHours < 24) {
          timeStr = 'منذ ${diff.inHours} ساعة';
        } else {
          timeStr = '${dt.year}/${dt.month}/${dt.day}';
        }
      } catch (_) {
        timeStr = 'مؤخراً';
      }
    }

    return NotificationModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'إشعار جديد',
      subtitle: json['body'] as String? ?? '',
      time: timeStr,
      icon: icon,
      iconColor: iconColor,
      isRead: json['is_read'] as bool? ?? false,
    );
  }
}


class ProviderSettingsModel {
  final bool newOrderNotifications;
  final bool orderUpdatesNotifications;
  final bool soundAlerts;
  final bool weeklyDigest;
  final int defaultResponseHours;

  const ProviderSettingsModel({
    this.newOrderNotifications = true,
    this.orderUpdatesNotifications = true,
    this.soundAlerts = true,
    this.weeklyDigest = false,
    this.defaultResponseHours = 24,
  });

  factory ProviderSettingsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ProviderSettingsModel();
    return ProviderSettingsModel(
      newOrderNotifications: json['new_order_notifications'] as bool? ?? true,
      orderUpdatesNotifications:
          json['order_updates_notifications'] as bool? ?? true,
      soundAlerts: json['sound_alerts'] as bool? ?? true,
      weeklyDigest: json['weekly_digest'] as bool? ?? false,
      defaultResponseHours:
          (json['default_response_hours'] as num?)?.toInt() ?? 24,
    );
  }

  Map<String, dynamic> toJson() => {
        'new_order_notifications': newOrderNotifications,
        'order_updates_notifications': orderUpdatesNotifications,
        'sound_alerts': soundAlerts,
        'weekly_digest': weeklyDigest,
        'default_response_hours': defaultResponseHours,
      };

  ProviderSettingsModel copyWith({
    bool? newOrderNotifications,
    bool? orderUpdatesNotifications,
    bool? soundAlerts,
    bool? weeklyDigest,
    int? defaultResponseHours,
  }) {
    return ProviderSettingsModel(
      newOrderNotifications:
          newOrderNotifications ?? this.newOrderNotifications,
      orderUpdatesNotifications:
          orderUpdatesNotifications ?? this.orderUpdatesNotifications,
      soundAlerts: soundAlerts ?? this.soundAlerts,
      weeklyDigest: weeklyDigest ?? this.weeklyDigest,
      defaultResponseHours:
          defaultResponseHours ?? this.defaultResponseHours,
    );
  }
}


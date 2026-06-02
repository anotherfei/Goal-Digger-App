enum AppNotificationType {
  dailyPlan,
  taskReminder,
  streakSaver,
  deadlineWarning,
  routineReminder,
  focusComplete,
  moodNudge,
  reward,
  community,
  friend,
  chat,
  important,
}

extension AppNotificationTypeX on AppNotificationType {
  String get label {
    switch (this) {
      case AppNotificationType.dailyPlan:
        return 'Daily plan';
      case AppNotificationType.taskReminder:
        return 'Task';
      case AppNotificationType.streakSaver:
        return 'Streak';
      case AppNotificationType.deadlineWarning:
        return 'Deadline';
      case AppNotificationType.routineReminder:
        return 'Routine';
      case AppNotificationType.focusComplete:
        return 'Focus';
      case AppNotificationType.moodNudge:
        return 'Mood';
      case AppNotificationType.reward:
        return 'Reward';
      case AppNotificationType.community:
        return 'Community';
      case AppNotificationType.friend:
        return 'Friend';
      case AppNotificationType.chat:
        return 'Chat';
      case AppNotificationType.important:
        return 'Important';
    }
  }
}

enum NotificationDelivery { system, inApp }

class NotificationSettings {
  const NotificationSettings({
    required this.systemNotificationsEnabled,
    required this.dailyPlanEnabled,
    required this.taskRemindersEnabled,
    required this.streakSaverEnabled,
    required this.deadlineWarningsEnabled,
    required this.routineRemindersEnabled,
    required this.focusNotificationsEnabled,
    required this.inAppNotificationsEnabled,
    required this.importantInAppEnabled,
    required this.dailyPlanHour,
    required this.dailyPlanMinute,
    required this.streakSaverHour,
    required this.streakSaverMinute,
    required this.taskReminderLeadMinutes,
    required this.deadlineWarningDays,
  });

  const NotificationSettings.defaults()
      : systemNotificationsEnabled = true,
        dailyPlanEnabled = true,
        taskRemindersEnabled = false,
        streakSaverEnabled = true,
        deadlineWarningsEnabled = true,
        routineRemindersEnabled = true,
        focusNotificationsEnabled = true,
        inAppNotificationsEnabled = true,
        importantInAppEnabled = true,
        dailyPlanHour = 8,
        dailyPlanMinute = 0,
        streakSaverHour = 20,
        streakSaverMinute = 30,
        taskReminderLeadMinutes = 15,
        deadlineWarningDays = 2;

  final bool systemNotificationsEnabled;
  final bool dailyPlanEnabled;
  final bool taskRemindersEnabled;
  final bool streakSaverEnabled;
  final bool deadlineWarningsEnabled;
  final bool routineRemindersEnabled;
  final bool focusNotificationsEnabled;
  final bool inAppNotificationsEnabled;
  final bool importantInAppEnabled;
  final int dailyPlanHour;
  final int dailyPlanMinute;
  final int streakSaverHour;
  final int streakSaverMinute;
  final int taskReminderLeadMinutes;
  final int deadlineWarningDays;

  bool get hasAnySystemNotification =>
      systemNotificationsEnabled &&
      (dailyPlanEnabled ||
          streakSaverEnabled ||
          deadlineWarningsEnabled ||
          routineRemindersEnabled ||
          focusNotificationsEnabled);

  NotificationSettings copyWith({
    bool? systemNotificationsEnabled,
    bool? dailyPlanEnabled,
    bool? taskRemindersEnabled,
    bool? streakSaverEnabled,
    bool? deadlineWarningsEnabled,
    bool? routineRemindersEnabled,
    bool? focusNotificationsEnabled,
    bool? inAppNotificationsEnabled,
    bool? importantInAppEnabled,
    int? dailyPlanHour,
    int? dailyPlanMinute,
    int? streakSaverHour,
    int? streakSaverMinute,
    int? taskReminderLeadMinutes,
    int? deadlineWarningDays,
  }) {
    return NotificationSettings(
      systemNotificationsEnabled:
          systemNotificationsEnabled ?? this.systemNotificationsEnabled,
      dailyPlanEnabled: dailyPlanEnabled ?? this.dailyPlanEnabled,
      taskRemindersEnabled:
          taskRemindersEnabled ?? this.taskRemindersEnabled,
      streakSaverEnabled: streakSaverEnabled ?? this.streakSaverEnabled,
      deadlineWarningsEnabled:
          deadlineWarningsEnabled ?? this.deadlineWarningsEnabled,
      routineRemindersEnabled:
          routineRemindersEnabled ?? this.routineRemindersEnabled,
      focusNotificationsEnabled:
          focusNotificationsEnabled ?? this.focusNotificationsEnabled,
      inAppNotificationsEnabled:
          inAppNotificationsEnabled ?? this.inAppNotificationsEnabled,
      importantInAppEnabled:
          importantInAppEnabled ?? this.importantInAppEnabled,
      dailyPlanHour: dailyPlanHour ?? this.dailyPlanHour,
      dailyPlanMinute: dailyPlanMinute ?? this.dailyPlanMinute,
      streakSaverHour: streakSaverHour ?? this.streakSaverHour,
      streakSaverMinute: streakSaverMinute ?? this.streakSaverMinute,
      taskReminderLeadMinutes:
          taskReminderLeadMinutes ?? this.taskReminderLeadMinutes,
      deadlineWarningDays: deadlineWarningDays ?? this.deadlineWarningDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'systemNotificationsEnabled': systemNotificationsEnabled,
      'dailyPlanEnabled': dailyPlanEnabled,
      'taskRemindersEnabled': taskRemindersEnabled,
      'streakSaverEnabled': streakSaverEnabled,
      'deadlineWarningsEnabled': deadlineWarningsEnabled,
      'routineRemindersEnabled': routineRemindersEnabled,
      'focusNotificationsEnabled': focusNotificationsEnabled,
      'inAppNotificationsEnabled': inAppNotificationsEnabled,
      'importantInAppEnabled': importantInAppEnabled,
      'dailyPlanHour': dailyPlanHour,
      'dailyPlanMinute': dailyPlanMinute,
      'streakSaverHour': streakSaverHour,
      'streakSaverMinute': streakSaverMinute,
      'taskReminderLeadMinutes': taskReminderLeadMinutes,
      'deadlineWarningDays': deadlineWarningDays,
    };
  }

  factory NotificationSettings.fromMap(Map<String, dynamic>? map) {
    const defaults = NotificationSettings.defaults();
    if (map == null) return defaults;

    int intValue(String key, int fallback, {int min = 0, int max = 59}) {
      final value = (map[key] as num?)?.toInt() ?? fallback;
      return value.clamp(min, max).toInt();
    }

    return NotificationSettings(
      systemNotificationsEnabled:
          map['systemNotificationsEnabled'] as bool? ??
              defaults.systemNotificationsEnabled,
      dailyPlanEnabled:
          map['dailyPlanEnabled'] as bool? ?? defaults.dailyPlanEnabled,
      taskRemindersEnabled:
          map['taskRemindersEnabled'] as bool? ??
              defaults.taskRemindersEnabled,
      streakSaverEnabled:
          map['streakSaverEnabled'] as bool? ?? defaults.streakSaverEnabled,
      deadlineWarningsEnabled:
          map['deadlineWarningsEnabled'] as bool? ??
              defaults.deadlineWarningsEnabled,
      routineRemindersEnabled:
          map['routineRemindersEnabled'] as bool? ??
              defaults.routineRemindersEnabled,
      focusNotificationsEnabled:
          map['focusNotificationsEnabled'] as bool? ??
              defaults.focusNotificationsEnabled,
      inAppNotificationsEnabled:
          map['inAppNotificationsEnabled'] as bool? ??
              defaults.inAppNotificationsEnabled,
      importantInAppEnabled:
          map['importantInAppEnabled'] as bool? ??
              defaults.importantInAppEnabled,
      dailyPlanHour: intValue('dailyPlanHour', defaults.dailyPlanHour, max: 23),
      dailyPlanMinute:
          intValue('dailyPlanMinute', defaults.dailyPlanMinute),
      streakSaverHour:
          intValue('streakSaverHour', defaults.streakSaverHour, max: 23),
      streakSaverMinute:
          intValue('streakSaverMinute', defaults.streakSaverMinute),
      taskReminderLeadMinutes: intValue(
        'taskReminderLeadMinutes',
        defaults.taskReminderLeadMinutes,
        max: 180,
      ),
      deadlineWarningDays: intValue(
        'deadlineWarningDays',
        defaults.deadlineWarningDays,
        max: 14,
      ),
    );
  }
}

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.delivery,
    required this.createdAt,
    this.important = false,
    this.readAt,
    this.sourceId,
    this.payload,
  });

  final String id;
  final String title;
  final String body;
  final AppNotificationType type;
  final NotificationDelivery delivery;
  final DateTime createdAt;
  final bool important;
  final DateTime? readAt;
  final String? sourceId;
  final Map<String, dynamic>? payload;

  bool get isUnread => readAt == null;

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    AppNotificationType? type,
    NotificationDelivery? delivery,
    DateTime? createdAt,
    bool? important,
    DateTime? readAt,
    String? sourceId,
    Map<String, dynamic>? payload,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      delivery: delivery ?? this.delivery,
      createdAt: createdAt ?? this.createdAt,
      important: important ?? this.important,
      readAt: readAt ?? this.readAt,
      sourceId: sourceId ?? this.sourceId,
      payload: payload ?? this.payload,
    );
  }
}

extension AppNotificationX on AppNotification {
  bool get isPetRelated {
    if (type != AppNotificationType.reward) return false;

    final source = sourceId?.toLowerCase() ?? '';
    if (source.startsWith('pet_')) return true;

    final content = '${title.toLowerCase()} ${body.toLowerCase()}';
    return content.contains('pet') ||
        content.contains('companion') ||
        content.contains('chest') ||
        content.contains('gift') ||
        content.contains('skin') ||
        content.contains('accessory');
  }
}

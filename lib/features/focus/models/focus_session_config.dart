import '../../../models/models.dart';

enum FocusTargetType { task, custom }

enum FocusAppBlockingMode { blockSelected, allowSelected }

FocusTargetType _targetTypeFromName(String? name) {
  for (final type in FocusTargetType.values) {
    if (type.name == name) return type;
  }
  return FocusTargetType.custom;
}

FocusAppBlockingMode _blockingModeFromName(String? name) {
  for (final mode in FocusAppBlockingMode.values) {
    if (mode.name == name) return mode;
  }
  return FocusAppBlockingMode.blockSelected;
}

extension FocusAppBlockingModeX on FocusAppBlockingMode {
  String get label {
    switch (this) {
      case FocusAppBlockingMode.blockSelected:
        return 'Block';
      case FocusAppBlockingMode.allowSelected:
        return 'Allow';
    }
  }

  String get summaryLabel {
    switch (this) {
      case FocusAppBlockingMode.blockSelected:
        return 'Blocking selected apps';
      case FocusAppBlockingMode.allowSelected:
        return 'Allowing selected apps only';
    }
  }

  String get listLabel {
    switch (this) {
      case FocusAppBlockingMode.blockSelected:
        return 'Blocked during focus';
      case FocusAppBlockingMode.allowSelected:
        return 'Allowed during focus';
    }
  }
}

class FocusAppDescriptor {
  const FocusAppDescriptor({
    required this.id,
    required this.displayName,
    this.androidPackageNames = const [],
  });

  factory FocusAppDescriptor.fromJson(Map<String, dynamic> json) {
    final rawPackageNames = json['androidPackageNames'];
    return FocusAppDescriptor(
      id: json['id']?.toString() ?? '',
      displayName: json['displayName']?.toString() ?? '',
      androidPackageNames: rawPackageNames is List
          ? rawPackageNames.map((name) => name.toString()).toList()
          : const [],
    );
  }

  final String id;
  final String displayName;
  final List<String> androidPackageNames;

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'androidPackageNames': androidPackageNames,
      };
}

class FocusAppBlockingPolicy {
  FocusAppBlockingPolicy({
    required this.mode,
    List<FocusAppDescriptor> selectedApps = const [],
  }) : selectedApps = List<FocusAppDescriptor>.unmodifiable(selectedApps);

  factory FocusAppBlockingPolicy.fromJson(Map<String, dynamic> json) {
    final rawApps = json['selectedApps'];
    return FocusAppBlockingPolicy(
      mode: _blockingModeFromName(json['mode']?.toString()),
      selectedApps: rawApps is List
          ? rawApps
              .whereType<Map>()
              .map((app) => FocusAppDescriptor.fromJson(
                    Map<String, dynamic>.from(app),
                  ))
              .toList()
          : const [],
    );
  }

  final FocusAppBlockingMode mode;
  final List<FocusAppDescriptor> selectedApps;

  bool get hasSelectedApps => selectedApps.isNotEmpty;

  List<String> get selectedAppNames =>
      selectedApps.map((app) => app.displayName).toList(growable: false);

  List<String> get selectedAndroidPackageNames => selectedApps
      .expand((app) => app.androidPackageNames)
      .toSet()
      .toList(growable: false);

  String get summary {
    if (selectedApps.isEmpty) return 'No apps selected';
    return mode.summaryLabel;
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'selectedApps': selectedApps.map((app) => app.toJson()).toList(),
      };
}

class FocusSessionConfig {
  FocusSessionConfig({
    String? id,
    required this.targetType,
    required this.title,
    required this.durationMinutes,
    required this.appPolicy,
    this.taskId,
    this.goalId,
    DateTime? createdAt,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt = createdAt ?? DateTime.now();

  factory FocusSessionConfig.forTask({
    required MicroTask task,
    required FocusAppBlockingPolicy appPolicy,
    int? durationMinutes,
  }) {
    return FocusSessionConfig(
      targetType: FocusTargetType.task,
      title: task.title,
      durationMinutes: durationMinutes ?? task.durationMinutes,
      appPolicy: appPolicy,
      taskId: task.id.toString(),
      goalId: task.goalId.toString(),
    );
  }

  factory FocusSessionConfig.custom({
    required String title,
    required int durationMinutes,
    required FocusAppBlockingPolicy appPolicy,
  }) {
    return FocusSessionConfig(
      targetType: FocusTargetType.custom,
      title: title.trim().isEmpty ? 'Custom focus session' : title.trim(),
      durationMinutes: durationMinutes,
      appPolicy: appPolicy,
    );
  }

  factory FocusSessionConfig.fromJson(Map<String, dynamic> json) {
    final appPolicyJson = json['appPolicy'];
    return FocusSessionConfig(
      id: json['id']?.toString(),
      targetType: _targetTypeFromName(json['targetType']?.toString()),
      title: json['title']?.toString() ?? 'Custom focus session',
      durationMinutes: (json['durationMinutes'] as num?)?.toInt() ?? 25,
      appPolicy: appPolicyJson is Map<String, dynamic>
          ? FocusAppBlockingPolicy.fromJson(appPolicyJson)
          : FocusAppBlockingPolicy(
              mode: FocusAppBlockingMode.blockSelected,
            ),
      taskId: json['taskId']?.toString(),
      goalId: json['goalId']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    );
  }

  final String id;
  final FocusTargetType targetType;
  final String title;
  final int durationMinutes;
  final FocusAppBlockingPolicy appPolicy;
  final String? taskId;
  final String? goalId;
  final DateTime createdAt;

  bool get targetsExistingTask => taskId != null && goalId != null;

  String get targetCaption {
    switch (targetType) {
      case FocusTargetType.task:
        return 'Task focus';
      case FocusTargetType.custom:
        return '$durationMinutes minute focus';
    }
  }

  String get blockingSummary => appPolicy.summary;

  Map<String, dynamic> toJson() => {
        'id': id,
        'targetType': targetType.name,
        'title': title,
        'durationMinutes': durationMinutes,
        'taskId': taskId,
        'goalId': goalId,
        'appPolicy': appPolicy.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };
}

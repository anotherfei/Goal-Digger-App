part of goal_digger;

class GoalDiggerRoot extends StatefulWidget {
  const GoalDiggerRoot({super.key});

  @override
  State<GoalDiggerRoot> createState() => _GoalDiggerRootState();
}

class _GoalDiggerRootState extends State<GoalDiggerRoot> {
  final DateTime today = dateOnly(DateTime.now());
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _communityController = TextEditingController();

  bool _onboarded = false;
  String _signedInWith = 'Guest';
  int _selectedIndex = 2;
  int _nextGoalId = 3;
  int _nextTaskId = 300;
  late List<GoalProject> _goals;
  late List<CommunityGroup> _communities;

  DateTime _newGoalDeadline = addDays(DateTime.now(), 14);
  int _newGoalPriority = 3;
  String _newGoalCategory = 'Study';

  bool _isProcessing = false;
  double _processingProgress = 0;
  Timer? _processingTimer;

  String _selectedMood = 'Okay';
  int _petHappiness = 62;
  int _coins = 140;
  int _streak = 7;
  final List<String> _friends = ['Maya Chen', 'Leo Tan', 'Ari Putra'];
  final List<String> _friendSuggestions = ['Nina Rahman', 'Jay Lim', 'Sofia Hart'];
  PetSkin _activePetSkin = defaultPet;
  String _activeAccessory = 'Cap';

  FocusSessionConfig? _activeFocusConfig;
  int _focusRemainingSeconds = 0;
  bool _focusPaused = false;
  Timer? _focusTimer;

  bool get _hasActiveFocus => _activeFocusConfig != null && _focusRemainingSeconds > 0;
  bool get _focusComplete => _activeFocusConfig != null && _focusRemainingSeconds <= 0;

  @override
  void initState() {
    super.initState();
    _goals = seedGoals(today);
    _communities = [
      CommunityGroup(
        name: 'Study Sprint Club',
        members: 89,
        tag: 'Exam prep',
        similarity: 94,
        description: 'Short daily sprints for students who want accountability.',
      ),
      CommunityGroup(
        name: 'Portfolio Builders',
        members: 142,
        tag: 'Career',
        similarity: 88,
        description: 'Share portfolio progress and get feedback from builders.',
      ),
      CommunityGroup(
        name: 'Calm Wellness Crew',
        members: 76,
        tag: 'Wellness',
        similarity: 81,
        description: 'Build low-pressure routines around sleep, movement, and reflection.',
      ),
    ];
  }

  @override
  void dispose() {
    _processingTimer?.cancel();
    _focusTimer?.cancel();
    _goalController.dispose();
    _communityController.dispose();
    super.dispose();
  }

  List<MicroTask> get _allTasks => _goals.expand((goal) => goal.tasks).toList();

  List<MicroTask> get _todayTasks => _allTasks
      .where((task) => dateOnly(task.scheduledDate) == today)
      .toList();

  GoalProject _goalForTask(MicroTask task) {
    return _goals.firstWhere((goal) => goal.id == task.goalId);
  }

  int get _todayCompleted => _todayTasks.where((task) => task.done).length;

  double get _todayProgress => _todayTasks.isEmpty ? 0 : _todayCompleted / _todayTasks.length;

  int get _remainingMinutes => _todayTasks
      .where((task) => !task.done)
      .fold(0, (sum, task) => sum + task.durationMinutes);

  String _formatFocusTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  void _completeOnboarding(String provider) {
    setState(() {
      _signedInWith = provider;
      _onboarded = true;
    });
    _showMessage('Welcome! You signed in with $provider.');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  void _showHelpfulError({
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          icon: const Icon(Icons.error_outline_rounded, color: gdError),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                onAction();
              },
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newGoalDeadline,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );
    if (picked != null) setState(() => _newGoalDeadline = picked);
  }

  void _createGoalWithProgress() {
    final title = _goalController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(
        title: 'Goal name is missing',
        message: 'Please write one clear goal first. Example: “Prepare for midterm” or “Build my portfolio”.',
        actionLabel: 'Write goal',
        onAction: () {},
      );
      return;
    }
    _openGoalBreakdownDialog(title);
  }

  Future<void> _openGoalBreakdownDialog(String title) async {
    final chatController = TextEditingController();
    var draftTitles = _generateTaskTitles(title).toList();
    final messages = <Map<String, dynamic>>[
      {
        'role': 'assistant',
        'text':
            "Great! Let\'s break down \"$title\" into actionable steps. I\'ve drafted ${draftTitles.length} micro-tasks below. If you want, ask me to make them easier, more detailed, or change the order.",
        'tasks': List<String>.from(draftTitles),
      },
    ];

    final result = await showDialog<List<String>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setLocalState) {
            Future<void> sendMessage() async {
              final request = chatController.text.trim();
              if (request.isEmpty) return;
              setLocalState(() {
                messages.add({'role': 'user', 'text': request});
                draftTitles = _refineTaskTitlesFromPrompt(draftTitles, request, title);
                messages.add({
                  'role': 'assistant',
                  'text':
                      "Absolutely — I refined the plan. Here\'s an updated version you can review before scheduling.",
                  'tasks': List<String>.from(draftTitles),
                });
                chatController.clear();
              });
            }

            Widget buildMessageBubble(Map<String, dynamic> message) {
              final isUser = message['role'] == 'user';
              final bubbleColor = isUser ? gdPrimary : const Color(0xFFF3F5F8);
              final textColor = isUser ? Colors.white : gdInk;
              final tasks = (message['tasks'] as List?)?.cast<String>();

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 680),
                  margin: EdgeInsets.only(left: isUser ? 44 : 0, right: isUser ? 0 : 44),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(26),
                      topRight: const Radius.circular(26),
                      bottomLeft: Radius.circular(isUser ? 26 : 8),
                      bottomRight: Radius.circular(isUser ? 8 : 26),
                    ),
                    border: !isUser ? Border.all(color: gdBorder) : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser)
                        Row(
                          children: const [
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: gdPrimarySoft,
                              child: Icon(Icons.auto_awesome_rounded, size: 16, color: gdPrimary),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Assistant',
                              style: TextStyle(color: gdMuted, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      if (!isUser) const SizedBox(height: 10),
                      Text(
                        message['text'] as String,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          height: 1.55,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (tasks != null && tasks.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        for (var i = 0; i < tasks.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isUser ? Colors.white.withOpacity(0.14) : Colors.white,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: isUser ? Colors.white24 : gdBorder,
                                    ),
                                  ),
                                  child: Text(
                                    '${i + 1}',
                                    style: TextStyle(
                                      color: isUser ? Colors.white : gdPrimary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      tasks[i],
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 15,
                                        height: 1.45,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 880,
                  maxHeight: MediaQuery.of(dialogContext).size.height * 0.86,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: gdSurface,
                    borderRadius: BorderRadius.circular(34),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'GOAL BREAKDOWN',
                                    style: TextStyle(
                                      color: Color(0xFF7C8AA5),
                                      fontSize: 13,
                                      letterSpacing: 3,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: gdInk,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F3F6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: IconButton(
                                tooltip: 'Close',
                                onPressed: () => Navigator.pop(dialogContext),
                                icon: const Icon(Icons.close_rounded, color: gdMuted),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFBFCFE),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: gdBorder),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: ListView.separated(
                              itemCount: messages.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) => buildMessageBubble(messages[index]),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: chatController,
                                minLines: 1,
                                maxLines: 4,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => sendMessage(),
                                decoration: InputDecoration(
                                  hintText: 'Adjust the plan...',
                                  filled: true,
                                  fillColor: const Color(0xFFF7F5EF),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(color: Color(0xFFE6DFD2)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(color: gdPrimary, width: 1.6),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              height: 56,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: gdPrimary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: sendMessage,
                                child: const Text('Send'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(64),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            ),
                            onPressed: () => Navigator.pop(dialogContext, List<String>.from(draftTitles)),
                            child: const Text('Looks good, finalize!'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    // Dispose after the dialog has fully unmounted.
    WidgetsBinding.instance.addPostFrameCallback((_) => chatController.dispose());
    if (result != null) {
      // Let Flutter finish removing the dialog route before rebuilding this page.
      // This prevents the framework `_dependents.isEmpty` assertion on finalize.
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      _finishCreateGoal(title, approvedTaskTitles: result);
    }
  }

  void _finishCreateGoal(String title, {List<String>? approvedTaskTitles}) {
    final goalId = _nextGoalId++;
    final colors = _categoryColors(_newGoalCategory);
    final steps = approvedTaskTitles == null
        ? _generateMicroTasks(title, goalId)
        : _generateMicroTasksFromTitles(approvedTaskTitles, goalId);
    setState(() {
      _goals.insert(
        0,
        GoalProject(
          id: goalId,
          title: title,
          importance: _newGoalPriority,
          category: _newGoalCategory,
          deadline: _newGoalDeadline,
          from: colors[0],
          to: colors[1],
          tasks: steps,
        ),
      );
      _isProcessing = false;
      _processingProgress = 0;
      _goalController.clear();
      _newGoalPriority = 3;
      _newGoalCategory = 'Study';
      _newGoalDeadline = addDays(today, 14);
    });
    _showMessage('Goal created. Your subtasks are scheduled.');
  }

  List<Color> _categoryColors(String category) {
    switch (category) {
      case 'Career': return [gdGradientCareerFrom, gdGradientCareerTo];
      case 'Wellness': return [gdGradientWellnessFrom, gdGradientWellnessTo];
      case 'Finance': return [gdGradientFinanceFrom, gdGradientFinanceTo];
      case 'Creative': return [gdGradientCreativeFrom, gdGradientCreativeTo];
      default: return [gdGradientStudyFrom, gdGradientStudyTo];
    }
  }

  List<String> _generateTaskTitles(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('exam') || lower.contains('midterm') || lower.contains('study')) {
      return ['List topics to review', 'Study the hardest topic for 20 minutes', 'Solve practice questions', 'Review mistakes and make flashcards'];
    } else if (lower.contains('portfolio') || lower.contains('project')) {
      return ['Define the project outcome', 'Create the first rough draft', 'Improve one visible section', 'Share for feedback'];
    }
    return ['Write the desired outcome', 'Break the goal into 3 milestones', 'Do the smallest first action', 'Review progress and adjust tomorrow'];
  }

  List<String> _refineTaskTitlesFromPrompt(List<String> currentTitles, String request, String goalTitle) {
    final lower = request.toLowerCase();
    List<String> updated = List<String>.from(currentTitles);

    final wantsSimpler = lower.contains('easy') ||
        lower.contains('easier') ||
        lower.contains('simple') ||
        lower.contains('smaller') ||
        lower.contains('busy');
    final wantsMoreDetail = lower.contains('detail') ||
        lower.contains('specific') ||
        lower.contains('clearer') ||
        lower.contains('more info');
    final wantsReorder = lower.contains('order') ||
        lower.contains('reorder') ||
        lower.contains('sequence');

    if (goalTitle.toLowerCase().contains('youtube')) {
      if (wantsSimpler) {
        return [
          'Pick one video idea for your first upload',
          'Write a short outline or talking points',
          'Record a simple first draft',
          'Upload it and note what to improve next',
        ];
      }
      if (wantsMoreDetail) {
        return [
          'Choose your niche and the topic for your first video',
          'Write your first script or recording outline',
          'Film the video and edit the best parts',
          'Publish it and review the response for your next upload',
        ];
      }
    }

    if (wantsSimpler) {
      updated = [
        'Define one small win for $goalTitle',
        'Work on the smallest part for 10 minutes',
        'Finish one visible improvement',
        'Review progress and set the next tiny step',
      ];
    } else if (wantsMoreDetail) {
      updated = [
        'Clarify the outcome and success metric',
        'Prepare the tools, files, or materials you need',
        'Complete the main work session',
        'Review results and plan the next follow-up action',
      ];
    } else if (wantsReorder && updated.length > 1) {
      final first = updated.removeAt(0);
      updated.insert(1, first);
    } else if (lower.contains('add')) {
      updated = List<String>.from(updated.take(3))
        ..add('Review progress and lock in the next step');
    } else {
      updated = [
        'Clarify the first concrete milestone',
        'Do the smallest useful action',
        'Improve one meaningful part',
        'Review the result and plan the next session',
      ];
    }

    return updated;
  }

  List<MicroTask> _generateMicroTasks(String title, int goalId) {
    return _generateMicroTasksFromTitles(_generateTaskTitles(title), goalId);
  }

  List<MicroTask> _generateMicroTasksFromTitles(List<String> taskTitles, int goalId) {
    return List.generate(taskTitles.length, (index) {
      return MicroTask(
        id: _nextTaskId++,
        goalId: goalId,
        title: taskTitles[index],
        durationMinutes: index == 0 ? 8 : 15 + index * 5,
        load: index == 0 ? TaskLoad.light : index == taskTitles.length - 1 ? TaskLoad.stretch : TaskLoad.focus,
        scheduledDate: addDays(today, index),
        points: 10 + index * 5,
      );
    });
  }

  void _toggleTask(MicroTask task) {
    setState(() {
      task.done = !task.done;
      if (task.done) {
        _coins += task.points;
        _petHappiness = min(100, _petHappiness + 8);
      } else {
        _coins = max(0, _coins - task.points);
        _petHappiness = max(0, _petHappiness - 8);
      }
    });
  }

  void _deleteGoal(GoalProject goal) {
    setState(() => _goals.removeWhere((item) => item.id == goal.id));
    _showMessage('Removed ${goal.title}.');
  }

  void _addCommunity() {
    final title = _communityController.text.trim();
    if (title.isEmpty) {
      _showHelpfulError(
        title: 'Community name is missing',
        message: 'Write a short community name first, then you can invite people later.',
        actionLabel: 'Try again',
        onAction: () {},
      );
      return;
    }
    setState(() {
      _communities.insert(0, CommunityGroup(
        name: title,
        members: 1,
        tag: 'Created by you',
        similarity: 100,
        joined: true,
        description: 'A new accountability group for people working on similar goals.',
      ));
      _communityController.clear();
    });
    _showMessage('Community created.');
  }

  void _joinCommunity(CommunityGroup group) {
    setState(() => group.joined = true);
    _showMessage('Joined ${group.name}.');
  }

  void _deleteCommunity(CommunityGroup group) {
    setState(() => _communities.remove(group));
    _showMessage('Removed ${group.name}.');
  }

  void _addFriend(String name) {
    if (_friends.contains(name)) return;
    setState(() => _friends.add(name));
    _showMessage('$name added as a friend.');
  }

  void _deleteFriend(String name) {
    setState(() => _friends.remove(name));
    _showMessage('Removed $name from friends.');
  }

  void _openPetChest() {
    if (_coins < 50) {
      _showHelpfulError(
        title: 'Not enough coins',
        message: 'A mystery chest costs 50 coins. Complete a few tasks first, then try again.',
        actionLabel: 'Got it',
        onAction: () {},
      );
      return;
    }
    final skins = [
      defaultPet,
      const PetSkin(name: 'Peach', from: Color(0xFFFFB4A2), to: Color(0xFFFFD6A5), accent: Color(0xFFFFF1E6)),
      const PetSkin(name: 'Lunar', from: Color(0xFF64748B), to: Color(0xFF1E293B), accent: Color(0xFFE2E8F0)),
    ];
    final accessories = ['Cap', 'Star badge', 'Tiny scarf', 'Focus glasses'];
    final skin = skins[Random().nextInt(skins.length)];
    final accessory = accessories[Random().nextInt(accessories.length)];
    setState(() {
      _coins -= 50;
      _activePetSkin = skin;
      _activeAccessory = accessory;
      _petHappiness = min(100, _petHappiness + 6);
    });
    _showMessage('Chest opened: ${skin.name} skin + $accessory unlocked!');
  }

  void _feedPet() {
    if (_coins < 10) {
      _showHelpfulError(
        title: 'Not enough coins',
        message: 'Complete one task first. Each completed task gives coins you can use for your companion.',
        actionLabel: 'Go to home',
        onAction: () => setState(() => _selectedIndex = 2),
      );
      return;
    }
    setState(() {
      _coins -= 10;
      _petHappiness = min(100, _petHappiness + 12);
    });
  }

  void _interactWithPet() {
    final reactions = [
      '${_activePetSkin.name} is cheering for you!',
      '${_activePetSkin.name} did a happy little bounce.',
      '${_activePetSkin.name} says: one tiny step counts!',
      '${_activePetSkin.name} feels closer to you.',
    ];
    setState(() => _petHappiness = min(100, _petHappiness + 2));
    _showMessage(reactions[Random().nextInt(reactions.length)]);
  }

  Future<void> _openFocusMode() async {
    if (_hasActiveFocus || _focusComplete) {
      _openActiveFocusDialog();
      return;
    }
    final unfinishedToday = _todayTasks.where((task) => !task.done).toList();
    final config = await showModalBottomSheet<FocusSessionConfig>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: gdSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => FocusSetupSheet(todayTasks: unfinishedToday),
    );
    if (!mounted || config == null) return;
    _startFocusSession(config);
  }

  void _startFocusSession(FocusSessionConfig config) {
    _focusTimer?.cancel();
    setState(() {
      _activeFocusConfig = config;
      _focusRemainingSeconds = config.durationMinutes * 60;
      _focusPaused = false;
    });
    _focusTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_focusPaused) return;
      setState(() => _focusRemainingSeconds = max(0, _focusRemainingSeconds - 1));
      if (_focusRemainingSeconds == 0) timer.cancel();
    });
    _openActiveFocusDialog();
  }

  void _openActiveFocusDialog() {
    final config = _activeFocusConfig;
    if (config == null) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.18),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FocusCountdownDialog(
          config: config,
          remainingSecondsProvider: () => _focusRemainingSeconds,
          pausedProvider: () => _focusPaused,
          onPauseToggle: _toggleFocusPause,
          onMinimize: () => Navigator.of(context).pop(),
          onStop: _stopFocusSession,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(opacity: curved, child: ScaleTransition(scale: Tween<double>(begin: 0.98, end: 1).animate(curved), child: child));
      },
    );
  }

  void _toggleFocusPause() => setState(() => _focusPaused = !_focusPaused);

  void _stopFocusSession() {
    _focusTimer?.cancel();
    setState(() {
      _activeFocusConfig = null;
      _focusRemainingSeconds = 0;
      _focusPaused = false;
    });
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
          backgroundColor: gdBackground,
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Profile'),
            leading: IconButton(
              tooltip: 'Close profile',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              children: [
                AppCard(
                  color: gdSurface,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 36,
                              backgroundColor: gdPrimarySoft,
                              child: Icon(Icons.account_circle_rounded, size: 42, color: gdPrimary),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Goal Digger User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: gdInk)),
                                  const SizedBox(height: 4),
                                  Text('Signed in with $_signedInWith', style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(children: [
                          Expanded(child: StatMiniCard(icon: Icons.paid_rounded, label: 'Coins', value: '$_coins')),
                          const SizedBox(width: 10),
                          Expanded(child: StatMiniCard(icon: Icons.local_fire_department_rounded, label: 'Streak', value: '$_streak days')),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: gdInk)),
                        SizedBox(height: 10),
                        ListTile(leading: Icon(Icons.mail_rounded), title: Text('Email / login method'), subtitle: Text('Manage account connection from settings.')),
                        ListTile(leading: Icon(Icons.shield_rounded), title: Text('Privacy'), subtitle: Text('Control what friends and communities can see.')),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  color: gdPrimarySoft,
                  child: const Padding(
                    padding: EdgeInsets.all(18),
                    child: Text(
                      'Friends are now managed from the Community page under the Friends tab.',
                      style: TextStyle(color: gdInk, fontWeight: FontWeight.w800, height: 1.4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  Future<void> _editGoalDeadline(GoalProject goal) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: goal.deadline.isBefore(today) ? today : goal.deadline,
      firstDate: today,
      lastDate: DateTime(today.year + 5),
    );
    if (picked == null) return;
    setState(() => goal.deadline = picked);
    _showMessage('Deadline updated to ${shortDate(picked)}.');
  }

  Future<void> _editGoalPriority(GoalProject goal) async {
    var draftPriority = goal.importance;
    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          backgroundColor: gdSurface,
          title: const Text('Edit priority'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goal.title, style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              PrioritySelector(
                value: draftPriority,
                onChanged: (value) => setLocalState(() => draftPriority = value),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, draftPriority), child: const Text('Save priority')),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() => goal.importance = result);
    _showMessage('Priority updated.');
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboarded) {
      return OnboardingScreen(
        onGoogle: () => _completeOnboarding('Google'),
        onLinkedIn: () => _completeOnboarding('LinkedIn'),
        onGuest: () => _completeOnboarding('Guest'),
      );
    }

    final pages = [
      _PlannerPage(
        goals: _goals,
        today: today,
        goalController: _goalController,
        deadline: _newGoalDeadline,
        priority: _newGoalPriority,
        category: _newGoalCategory,
        isProcessing: _isProcessing,
        processingProgress: _processingProgress,
        onDeadlinePick: _pickDeadline,
        onPriorityChanged: (value) => setState(() => _newGoalPriority = value),
        onCategoryChanged: (value) => setState(() => _newGoalCategory = value),
        onCreateGoal: _createGoalWithProgress,
        onDeleteGoal: _deleteGoal,
        onEditGoalDeadline: _editGoalDeadline,
        onEditGoalPriority: _editGoalPriority,
        onCreateFirstGoal: () => setState(() => _selectedIndex = 0),
      ),
      _CalendarPage(
        tasks: _allTasks,
        goalForTask: _goalForTask,
        today: today,
        onCreateGoal: () => setState(() => _selectedIndex = 0),
      ),
      _TasksPage(
        mood: _selectedMood,
        todayTasks: _todayTasks,
        todayProgress: _todayProgress,
        todayCompleted: _todayCompleted,
        todayTotal: _todayTasks.length,
        remainingMinutes: _remainingMinutes,
        goalForTask: _goalForTask,
        onMoodChanged: (value) => setState(() => _selectedMood = value),
        onToggleTask: _toggleTask,
        onCreateGoal: () => setState(() => _selectedIndex = 0),
      ),
      _CommunityPage(
        controller: _communityController,
        communities: _communities,
        friends: _friends,
        friendSuggestions: _friendSuggestions,
        streak: _streak,
        onAddCommunity: _addCommunity,
        onJoinCommunity: _joinCommunity,
        onDeleteCommunity: _deleteCommunity,
        onAddFriend: _addFriend,
        onDeleteFriend: _deleteFriend,
      ),
      _CompanionPage(
        coins: _coins,
        happiness: _petHappiness,
        pet: _activePetSkin,
        accessory: _activeAccessory,
        onFeed: _feedPet,
        onOpenChest: _openPetChest,
        onPetInteract: _interactWithPet,
      ),
    ];

    return ResponsiveGoalShell(
      selectedIndex: _selectedIndex,
      signedInWith: _signedInWith,
      pages: pages,
      onSelect: (index) => setState(() => _selectedIndex = index),
      onFocusMode: _openFocusMode,
      onProfile: _openProfile,
      onSettings: _openSettings,
      hasActiveFocus: _hasActiveFocus || _focusComplete,
      focusLabel: _activeFocusConfig == null ? null : (_focusComplete ? 'Done' : _formatFocusTime(_focusRemainingSeconds)),
    );
  }
}

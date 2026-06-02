import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../core/theme/gd_colors.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class CompanionPage extends StatefulWidget {
  const CompanionPage({
    super.key,
    required this.coins,
    required this.happiness,
    required this.pet,
    required this.accessory,
    required this.todayTasks,
    required this.goalForTask,
    required this.onFeed,
    required this.onOpenChest,
    required this.onPetInteract,
    required this.onToggleTask,
    required this.onEquipSkin,
    required this.onEquipAccessory,
  });

  final int coins;
  final int happiness;
  final PetSkin pet;
  final String accessory;
  final List<MicroTask> todayTasks;
  final GoalProject Function(MicroTask task) goalForTask;
  final VoidCallback onFeed;
  final VoidCallback onOpenChest;
  final VoidCallback onPetInteract;
  final ValueChanged<MicroTask> onToggleTask;
  final ValueChanged<PetSkin> onEquipSkin;
  final ValueChanged<String> onEquipAccessory;

  @override
  State<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage>
    with SingleTickerProviderStateMixin {
  static const String _modelPath = 'assets/models/goal_spirit_companion.glb';

  late final AnimationController _floatController;
  late final Animation<double> _floatOffset;

  String _selectedSkin = 'Mint';
  String _selectedAura = 'Focus glow';
  String _selectedSuit = 'Goal suit';

  @override
  void initState() {
    super.initState();
    _selectedSkin = widget.pet.name;
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);

    _floatOffset = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant CompanionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.name != widget.pet.name) {
      _selectedSkin = widget.pet.name;
    }
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 72, 18, 112),
            children: [
              const SizedBox(height: 16),
              AppCard(
                color: const Color(0xFFEAF1FF),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          '3D GOAL COMPANION',
                          style: TextStyle(
                            color: gdPrimary,
                            letterSpacing: 3,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _CompanionModelStage(
                        floatOffset: _floatOffset,
                        selectedAura: _selectedAura,
                        accessory: widget.accessory,
                        modelPath: _modelPath,
                      ),
                      const SizedBox(height: 18),
                      _HappinessPanel(
                        happiness: widget.happiness,
                        onCheer: widget.onPetInteract,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: widget.onPetInteract,
                              icon: const Icon(Icons.auto_awesome_rounded),
                              label: const Text('Cheer companion'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: widget.onFeed,
                              icon: const Icon(Icons.restaurant_rounded),
                              label: const Text('Feed -10'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle(title: 'Customize look', trailing: 'Preview'),
              const SizedBox(height: 10),
              AppCard(
                color: gdSurface,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Use this area for future unlocks such as skins, suits, auras, and accessories.',
                        style: TextStyle(
                          color: gdInk,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _TinyLabel('Skin color'),
                      const SizedBox(height: 10),
                      _ChoiceWrap(
                        values: const ['Mint', 'Peach', 'Lunar', 'Nova'],
                        selected: _selectedSkin,
                        onSelected: (value) => setState(() => _selectedSkin = value),
                      ),
                      const SizedBox(height: 16),
                      const _TinyLabel('Suit'),
                      const SizedBox(height: 10),
                      _ChoiceWrap(
                        values: const [
                          'Goal suit',
                          'Focus hoodie',
                          'Explorer cape',
                          'Golden armor',
                        ],
                        selected: _selectedSuit,
                        onSelected: (value) => setState(() => _selectedSuit = value),
                      ),
                      const SizedBox(height: 16),
                      const _TinyLabel('Aura'),
                      const SizedBox(height: 10),
                      _ChoiceWrap(
                        values: const [
                          'Focus glow',
                          'Streak spark',
                          'Calm orbit',
                        ],
                        selected: _selectedAura,
                        onSelected: (value) => setState(() => _selectedAura = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle(title: 'Mystery chest', trailing: '50 coins'),
              const SizedBox(height: 10),
              AppCard(
                color: gdSurface,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          CircleAvatar(
                            backgroundColor: gdPrimarySoft,
                            child: Icon(
                              Icons.inventory_2_rounded,
                              color: gdPrimary,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Open a chest to unlock future 3D suits, skins, and accessories.',
                              style: TextStyle(
                                color: gdInk,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: widget.onOpenChest,
                          icon: const Icon(Icons.redeem_rounded),
                          label: const Text('Open chest -50 coins'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 14,
            left: 18,
            child: _FloatingWallet(coins: widget.coins),
          ),
        ],
      ),
    );
  }
}

class _CompanionModelStage extends StatelessWidget {
  const _CompanionModelStage({
    required this.floatOffset,
    required this.selectedAura,
    required this.accessory,
    required this.modelPath,
  });

  final Animation<double> floatOffset;
  final String selectedAura;
  final String accessory;
  final String modelPath;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 330,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7FBFF), Color(0xFFE5F2FF)],
        ),
        border: Border.all(color: gdBorder),
        boxShadow: [
          BoxShadow(
            color: gdPrimary.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34),
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 0.95,
                  colors: _auraColors(selectedAura),
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: _StageBadge(
              icon: Icons.workspace_premium_rounded,
              label: accessory,
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: _StageBadge(
              icon: Icons.threed_rotation_rounded,
              label: 'Drag to rotate',
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: floatOffset,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, floatOffset.value),
                  child: child,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(34),
                child: ModelViewer(
                  backgroundColor: Colors.transparent,
                  src: modelPath,
                  alt: 'A 3D goal spirit companion for Goal Digger',
                  autoRotate: true,
                  cameraControls: true,
                  disableZoom: true,
                  ar: false,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _auraColors(String aura) {
    switch (aura) {
      case 'Streak spark':
        return [
          const Color(0x33FFBF48),
          const Color(0x11FF94B5),
          Colors.transparent,
        ];
      case 'Calm orbit':
        return [
          const Color(0x3362AAFF),
          const Color(0x1168ECCA),
          Colors.transparent,
        ];
      case 'Focus glow':
      default:
        return [
          const Color(0x3368ECCA),
          const Color(0x1162AAFF),
          Colors.transparent,
        ];
    }
  }
}

class _HappinessPanel extends StatelessWidget {
  const _HappinessPanel({required this.happiness, required this.onCheer});

  final int happiness;
  final VoidCallback onCheer;

  @override
  Widget build(BuildContext context) {
    final safeHappiness = happiness.clamp(0, 100);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gdCardLight,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: gdBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: gdAccent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Happiness $safeHappiness%',
                  style: const TextStyle(
                    color: gdInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: onCheer,
                child: const Text('Cheer up'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: safeHappiness / 100,
            minHeight: 10,
            backgroundColor: gdPrimarySoft,
            color: gdPrimary,
            borderRadius: BorderRadius.circular(999),
          ),
        ],
      ),
    );
  }
}

class _ChoiceWrap extends StatelessWidget {
  const _ChoiceWrap({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: values.map((value) {
        final isSelected = selected == value;
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onSelected(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF071022) : gdCardLight,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: isSelected ? gdInk : gdBorder),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: isSelected ? Colors.white : gdMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TinyLabel extends StatelessWidget {
  const _TinyLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: gdMuted,
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: gdSurface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: gdBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: gdPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: gdInk,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingWallet extends StatelessWidget {
  const _FloatingWallet({required this.coins});

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gdBorder),
        boxShadow: [
          BoxShadow(
            color: gdPrimary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: gdStarGold,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text(
              'C',
              style: TextStyle(
                color: Color(0xFF5B3200),
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Wallet',
                style: TextStyle(
                  color: gdMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                '$coins coins',
                style: const TextStyle(
                  color: gdInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

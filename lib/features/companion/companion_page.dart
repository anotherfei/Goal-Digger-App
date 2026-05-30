import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/gd_colors.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';

class CompanionPage extends StatefulWidget {
  const CompanionPage({
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
    super.key,
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
  final void Function(MicroTask task) onToggleTask;
  final void Function(PetSkin skin) onEquipSkin;
  final void Function(String accessory) onEquipAccessory;

  @override
  State<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;
  late String _selectedSkin;
  late String _selectedSuit;
  late String _selectedAccessory;

  static const List<String> _skins = ['Mint', 'Peach', 'Lunar', 'Nova'];
  static const List<String> _suits = [
    'None',
    'Focus hoodie',
    'Explorer cape',
    'Golden armor',
  ];

  @override
  void initState() {
    super.initState();
    _selectedSkin = widget.pet.name;
    _selectedSuit = 'Focus hoodie';
    _selectedAccessory = _normalisedAccessory(widget.accessory);
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant CompanionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pet.name != widget.pet.name) {
      _selectedSkin = widget.pet.name;
    }
    if (oldWidget.accessory != widget.accessory) {
      _selectedAccessory = _normalisedAccessory(widget.accessory);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  double get _happinessValue => (widget.happiness.clamp(0, 100)) / 100;

  List<String> get _accessoryOptions {
    final current = _normalisedAccessory(widget.accessory);
    return <String>{
      'None',
      if (current != 'None') current,
      'Star crown',
      'Focus headphones',
      'Tiny backpack',
    }.toList();
  }

  static String _normalisedAccessory(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'none') return 'None';
    return trimmed;
  }

  _CompanionLook get _look => _CompanionLook.fromName(_selectedSkin, widget.pet);

  @override
  Widget build(BuildContext context) {
    final look = _look;

    return PageScaffold(
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(18, 72, 18, 112),
            children: [
              AppCard(
                color: Colors.transparent,
                child: _CompanionStage(
                  look: look,
                  happiness: widget.happiness,
                  happinessValue: _happinessValue,
                  accessory: _selectedAccessory,
                  suit: _selectedSuit,
                  idleController: _idleController,
                  onPetInteract: widget.onPetInteract,
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle(
                title: 'Customize companion',
                trailing: 'Preview only',
              ),
              const SizedBox(height: 10),
              AppCard(
                color: gdSurface,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _PanelLabel(
                        icon: Icons.palette_rounded,
                        title: 'Skin color',
                        subtitle: 'Make the companion feel like your own.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final skin in _skins)
                            _ChoiceBubble(
                              label: skin,
                              selected: _selectedSkin == skin,
                              onTap: () => setState(() => _selectedSkin = skin),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _PanelLabel(
                        icon: Icons.checkroom_rounded,
                        title: 'Suit',
                        subtitle: 'Use outfits as progress rewards later.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final suit in _suits)
                            _ChoiceBubble(
                              label: suit,
                              selected: _selectedSuit == suit,
                              onTap: () => setState(() => _selectedSuit = suit),
                            ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const _PanelLabel(
                        icon: Icons.auto_awesome_rounded,
                        title: 'Accessory',
                        subtitle: 'Equip small items earned from chests.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final item in _accessoryOptions)
                            _ChoiceBubble(
                              label: item,
                              selected: _selectedAccessory == item,
                              onTap: () => setState(() => _selectedAccessory = item),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle(title: 'Care & rewards', trailing: '50 coins'),
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
                            child: Icon(Icons.inventory_2_rounded, color: gdPrimary),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Open chests to unlock new suits, skins, and accessories.',
                              style: TextStyle(
                                color: gdInk,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                height: 1.25,
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
                          icon: const Icon(Icons.auto_awesome_rounded),
                          label: const Text('Open chest -50 coins'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: widget.onFeed,
                          icon: const Icon(Icons.restaurant_rounded),
                          label: const Text('Feed companion -10 coins'),
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

class _CompanionStage extends StatelessWidget {
  const _CompanionStage({
    required this.look,
    required this.happiness,
    required this.happinessValue,
    required this.accessory,
    required this.suit,
    required this.idleController,
    required this.onPetInteract,
  });

  final _CompanionLook look;
  final int happiness;
  final double happinessValue;
  final String accessory;
  final String suit;
  final AnimationController idleController;
  final VoidCallback onPetInteract;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            look.from.withOpacity(0.18),
            const Color(0xFFEAF1FF),
            look.to.withOpacity(0.20),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: gdSurface.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: gdBorder),
                  ),
                  child: const Text(
                    'GOAL COMPANION',
                    style: TextStyle(
                      color: gdPrimary,
                      letterSpacing: 2.6,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(Icons.favorite_rounded, color: look.to),
                const SizedBox(width: 4),
                Text(
                  '$happiness%',
                  style: const TextStyle(
                    color: gdInk,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: gdSurface.withOpacity(0.78),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: gdBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: look.from.withOpacity(0.18),
                    child: Icon(Icons.flag_rounded, color: look.to),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I grow stronger when you complete your daily goals. Tap me when you need motivation.',
                      style: TextStyle(
                        color: gdInk,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onPetInteract,
              child: _CompanionAvatar3D(
                look: look,
                happinessValue: happinessValue,
                accessory: accessory,
                suit: suit,
                animation: idleController,
              ),
            ),
            const SizedBox(height: 14),
            _HappinessPanel(value: happinessValue, happiness: happiness),
          ],
        ),
      ),
    );
  }
}

class _CompanionAvatar3D extends StatelessWidget {
  const _CompanionAvatar3D({
    required this.look,
    required this.happinessValue,
    required this.accessory,
    required this.suit,
    required this.animation,
  });

  final _CompanionLook look;
  final double happinessValue;
  final String accessory;
  final String suit;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final wave = math.sin(animation.value * math.pi * 2);
          final tilt = math.sin(animation.value * math.pi * 2) * 0.045;

          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 18,
                child: Transform.scale(
                  scaleX: 1.0 + wave.abs() * 0.05,
                  child: Container(
                    width: 172,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: look.to.withOpacity(0.18),
                          blurRadius: 24,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                child: Transform.translate(
                  offset: Offset(0, wave * 6),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(-0.12)
                      ..rotateY(tilt),
                    child: SizedBox(
                      width: 224,
                      height: 232,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _GlowRing(color: look.to),
                          _SideOrb(left: true, color: look.from),
                          _SideOrb(left: false, color: look.to),
                          _CompanionBody(look: look),
                          _SuitLayer(suit: suit, look: look),
                          _CompanionFace(happinessValue: happinessValue),
                          _AccessoryLayer(accessory: accessory, look: look),
                          Positioned(
                            bottom: 24,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: gdSurface.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: gdBorder),
                              ),
                              child: Text(
                                look.name,
                                style: const TextStyle(
                                  color: gdInk,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompanionBody extends StatelessWidget {
  const _CompanionBody({required this.look});

  final _CompanionLook look;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 28,
      child: Container(
        width: 168,
        height: 184,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(86),
          gradient: RadialGradient(
            center: const Alignment(-0.38, -0.48),
            radius: 1.08,
            colors: [
              Colors.white.withOpacity(0.98),
              look.from,
              look.to,
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: look.to.withOpacity(0.36),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.75),
              blurRadius: 18,
              offset: const Offset(-16, -14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 28,
              top: 22,
              child: Container(
                width: 54,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Positioned(
              right: 22,
              bottom: 34,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: look.accent.withOpacity(0.38),
                  border: Border.all(color: Colors.white.withOpacity(0.62), width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionFace extends StatelessWidget {
  const _CompanionFace({required this.happinessValue});

  final double happinessValue;

  @override
  Widget build(BuildContext context) {
    final mouthHeight = happinessValue > 0.55 ? 14.0 : 5.0;

    return Positioned(
      top: 88,
      child: SizedBox(
        width: 100,
        height: 70,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned(left: 18, top: 10, child: _Eye()),
            const Positioned(right: 18, top: 10, child: _Eye()),
            Positioned(
              bottom: 12,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 36,
                height: mouthHeight,
                decoration: BoxDecoration(
                  color: gdSurface.withOpacity(0.95),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(happinessValue > 0.55 ? 22 : 4),
                    bottomRight: Radius.circular(happinessValue > 0.55 ? 22 : 4),
                    topLeft: const Radius.circular(4),
                    topRight: const Radius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Eye extends StatelessWidget {
  const _Eye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 24,
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.only(top: 5),
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(color: gdInk, shape: BoxShape.circle),
      ),
    );
  }
}

class _GlowRing extends StatelessWidget {
  const _GlowRing({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      child: Container(
        width: 198,
        height: 198,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.10),
          border: Border.all(color: Colors.white.withOpacity(0.65), width: 2),
        ),
      ),
    );
  }
}

class _SideOrb extends StatelessWidget {
  const _SideOrb({required this.left, required this.color});

  final bool left;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 112,
      left: left ? 18 : null,
      right: left ? null : 18,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: const Alignment(-0.5, -0.6),
            colors: [Colors.white, color],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.26),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuitLayer extends StatelessWidget {
  const _SuitLayer({required this.suit, required this.look});

  final String suit;
  final _CompanionLook look;

  @override
  Widget build(BuildContext context) {
    switch (suit) {
      case 'Focus hoodie':
        return Positioned(
          top: 54,
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(70),
              border: Border.all(color: gdInk.withOpacity(0.15), width: 10),
            ),
          ),
        );
      case 'Explorer cape':
        return Positioned(
          top: 72,
          child: Transform.rotate(
            angle: -0.05,
            child: Container(
              width: 142,
              height: 112,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [look.accent.withOpacity(0.55), gdPrimary.withOpacity(0.55)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(34),
                  topRight: Radius.circular(34),
                  bottomLeft: Radius.circular(70),
                  bottomRight: Radius.circular(70),
                ),
              ),
            ),
          ),
        );
      case 'Golden armor':
        return Positioned(
          top: 116,
          child: Container(
            width: 116,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFE8A3), gdStarGold]),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.72), width: 2),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.shield_rounded, color: Color(0xFF7C4A03)),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _AccessoryLayer extends StatelessWidget {
  const _AccessoryLayer({required this.accessory, required this.look});

  final String accessory;
  final _CompanionLook look;

  @override
  Widget build(BuildContext context) {
    final lower = accessory.toLowerCase();
    if (lower == 'none') return const SizedBox.shrink();

    if (lower.contains('crown') || lower.contains('star')) {
      return Positioned(
        top: 8,
        child: Transform.rotate(
          angle: -0.12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFF3C4), gdStarGold]),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: gdStarGold.withOpacity(0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Color(0xFF7C4A03)),
          ),
        ),
      );
    }

    if (lower.contains('head')) {
      return Positioned(
        top: 76,
        child: SizedBox(
          width: 158,
          height: 58,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 16,
                child: _HeadphoneCup(color: look.accent),
              ),
              Positioned(
                right: 0,
                top: 16,
                child: _HeadphoneCup(color: look.accent),
              ),
              Positioned(
                left: 35,
                right: 35,
                top: 0,
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    border: Border.all(color: gdInk.withOpacity(0.55), width: 5),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(60)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (lower.contains('backpack')) {
      return Positioned(
        right: 22,
        bottom: 64,
        child: Container(
          width: 44,
          height: 58,
          decoration: BoxDecoration(
            color: gdPrimaryDark.withOpacity(0.92),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.work_rounded, color: Colors.white, size: 22),
        ),
      );
    }

    return Positioned(
      top: 8,
      right: 28,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: gdSurface.withOpacity(0.94),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: gdBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          accessory,
          style: const TextStyle(color: gdInk, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _HeadphoneCup extends StatelessWidget {
  const _HeadphoneCup({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 42,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.white, color]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: gdInk.withOpacity(0.20), width: 2),
      ),
    );
  }
}

class _HappinessPanel extends StatelessWidget {
  const _HappinessPanel({required this.value, required this.happiness});

  final double value;
  final int happiness;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gdSurface.withOpacity(0.86),
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
                  'Happiness $happiness%',
                  style: const TextStyle(color: gdInk, fontWeight: FontWeight.w900),
                ),
              ),
              const Text(
                'Tap companion to cheer up',
                style: TextStyle(
                  color: gdMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: gdPrimarySoft,
            color: gdPrimary,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          const Text(
            'Complete daily tasks to keep your companion energized and unlock more cosmetics later.',
            style: TextStyle(color: gdMuted, fontWeight: FontWeight.w700, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _PanelLabel extends StatelessWidget {
  const _PanelLabel({required this.icon, required this.title, required this.subtitle});

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: gdPrimarySoft,
          child: Icon(icon, color: gdPrimary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: gdInk, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: gdMuted, fontWeight: FontWeight.w700, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChoiceBubble extends StatelessWidget {
  const _ChoiceBubble({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? gdPrimaryDark : gdCardLight,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: selected ? gdPrimaryDark : gdBorder),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: gdPrimaryDark.withOpacity(0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : gdMuted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
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
            decoration: const BoxDecoration(color: gdStarGold, shape: BoxShape.circle),
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
                style: const TextStyle(color: gdInk, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompanionLook {
  const _CompanionLook({
    required this.name,
    required this.from,
    required this.to,
    required this.accent,
  });

  final String name;
  final Color from;
  final Color to;
  final Color accent;

  factory _CompanionLook.fromName(String name, PetSkin fallback) {
    switch (name) {
      case 'Mint':
        return const _CompanionLook(
          name: 'Mint',
          from: gdPetMintFrom,
          to: gdPetMintTo,
          accent: gdPetAccent,
        );
      case 'Peach':
        return const _CompanionLook(
          name: 'Peach',
          from: Color(0xFFFFA07A),
          to: Color(0xFFE66A6A),
          accent: Color(0xFFFFF1F2),
        );
      case 'Lunar':
        return const _CompanionLook(
          name: 'Lunar',
          from: Color(0xFF8B5CF6),
          to: Color(0xFF315C9D),
          accent: Color(0xFFEDE9FE),
        );
      case 'Nova':
        return const _CompanionLook(
          name: 'Nova',
          from: Color(0xFFF59E0B),
          to: Color(0xFFD946EF),
          accent: Color(0xFFFFF7ED),
        );
      default:
        return _CompanionLook(
          name: fallback.name,
          from: fallback.from,
          to: fallback.to,
          accent: fallback.accent,
        );
    }
  }
}

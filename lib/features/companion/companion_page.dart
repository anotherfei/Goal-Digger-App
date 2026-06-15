import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'companion_sprite.dart';

class CompanionPage extends StatefulWidget {
  const CompanionPage({
    super.key,
    required this.coins,
    required this.happiness,
    required this.streakTier,
    required this.activeCompanion,
    required this.unlockedCompanions,
    required this.onCompanionSelected,
    required this.onGachaPull,
    required this.onFeed,
    required this.onPetInteract,
  });

  final int coins;
  final int happiness;
  final CompanionStreakTier streakTier;
  final CompanionKind activeCompanion;
  final Set<CompanionKind> unlockedCompanions;
  final ValueChanged<CompanionKind> onCompanionSelected;
  final Future<CompanionGachaResult?> Function() onGachaPull;
  final VoidCallback onFeed;
  final VoidCallback onPetInteract;

  @override
  State<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage> {
  bool _isPulling = false;
  int _pullSerial = 0;
  CompanionGachaResult? _pullResult;

  Future<void> _handleGachaPull() async {
    if (_isPulling) return;
    setState(() {
      _isPulling = true;
      _pullResult = null;
      _pullSerial++;
    });

    await Future<void>.delayed(const Duration(milliseconds: 850));
    final result = await widget.onGachaPull();
    if (!mounted) return;

    if (result == null) {
      setState(() => _isPulling = false);
      return;
    }

    setState(() => _pullResult = result);
  }

  void _dismissPullResult() {
    setState(() {
      _isPulling = false;
      _pullResult = null;
    });
  }

  Future<void> _openCompanionPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: gdSurface,
      builder: (sheetContext) {
        return _CompanionPickerSheet(
          activeCompanion: widget.activeCompanion,
          unlockedCompanions: widget.unlockedCompanions,
          onSelected: (companion) {
            Navigator.pop(sheetContext);
            widget.onCompanionSelected(companion);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      child: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(
              18,
              72,
              18,
              GoalShellInsets.bottomOf(context),
            ),
            children: [
              const SizedBox(height: 16),
              AppCard(
                color: gdPrimarySoft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          widget.activeCompanion.label.toUpperCase(),
                          style: TextStyle(
                            color: gdPrimary,
                            letterSpacing: 3,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: gdCardLight,
                            shape: BoxShape.circle,
                            border: Border.all(color: gdBorder),
                          ),
                          child: CompanionSprite(
                            kind: widget.activeCompanion,
                            tier: widget.streakTier,
                            size: 178,
                            onTap: widget.onPetInteract,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
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
                                Icon(
                                  Icons.favorite_rounded,
                                  color: gdAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Happiness ${widget.happiness}%',
                                    style: TextStyle(
                                      color: gdInk,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Text(
                                  'Tap to cheer up',
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
                              value: widget.happiness / 100,
                              minHeight: 10,
                              backgroundColor: gdPrimarySoft,
                              color: gdPrimary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            const SizedBox(height: 14),
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SectionTitle(
                title: 'Companion gacha',
                trailing: '$companionGachaCost coins',
              ),
              const SizedBox(height: 10),
              AppCard(
                color: gdSurface,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _GachaPullPanel(
                        unlockedCompanions: widget.unlockedCompanions,
                        isPulling: _isPulling,
                        onPull: _handleGachaPull,
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
          Positioned(
            top: 14,
            right: 18,
            child: _CompanionChooserButton(
              companion: widget.activeCompanion,
              onTap: _openCompanionPicker,
            ),
          ),
          if (_isPulling)
            Positioned.fill(
              child: _GachaRevealOverlay(
                key: ValueKey(_pullSerial),
                result: _pullResult,
                onDismiss: _pullResult == null ? null : _dismissPullResult,
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
            color: gdPrimary.withValues(alpha: 0.08),
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
            decoration: BoxDecoration(
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
              Text(
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
                style: TextStyle(
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

class _CompanionChooserButton extends StatelessWidget {
  const _CompanionChooserButton({
    required this.companion,
    required this.onTap,
  });

  final CompanionKind companion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Tooltip(
          message: 'Choose companion',
          child: Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gdSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: gdBorder),
              boxShadow: [
                BoxShadow(
                  color: gdPrimary.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CompanionPortrait(kind: companion, size: 40),
          ),
        ),
      ),
    );
  }
}

class _GachaPullPanel extends StatelessWidget {
  const _GachaPullPanel({
    required this.unlockedCompanions,
    required this.isPulling,
    required this.onPull,
  });

  final Set<CompanionKind> unlockedCompanions;
  final bool isPulling;
  final VoidCallback onPull;

  bool _isUnlocked(CompanionKind companion) {
    return companion == CompanionKind.lumi ||
        unlockedCompanions.contains(companion);
  }

  @override
  Widget build(BuildContext context) {
    final lockedCount = gachaCompanions
        .where((companion) => !_isUnlocked(companion))
        .length;
    final allUnlocked = lockedCount == 0;
    final hiddenText = lockedCount == 0
        ? 'All companions discovered'
        : '$lockedCount companions still hidden';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: gdPrimarySoft,
              child: Icon(Icons.casino_rounded, color: gdPrimary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hiddenText,
                    style: TextStyle(
                      color: gdInk,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Common 50% | Uncommon 30% | Rare 15% | Epic 5%',
                    style: TextStyle(
                      color: gdMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duplicate refund: $companionDuplicateRefund coins',
                    style: TextStyle(
                      color: gdMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final companion in gachaCompanions)
              _RosterPortrait(
                companion: companion,
                unlocked: _isUnlocked(companion),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isPulling || allUnlocked ? null : onPull,
            icon: Icon(
              allUnlocked
                  ? Icons.check_circle_rounded
                  : Icons.auto_awesome_rounded,
            ),
            label: Text(
              allUnlocked
                  ? 'All companions unlocked'
                  : 'Pull capsule -$companionGachaCost coins',
            ),
          ),
        ),
      ],
    );
  }
}

class _RosterPortrait extends StatelessWidget {
  const _RosterPortrait({
    required this.companion,
    required this.unlocked,
  });

  final CompanionKind companion;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: unlocked
          ? '${companion.label} unlocked'
          : '${companion.rarity!.label} companion',
      child: Container(
        width: 58,
        height: 58,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: gdPrimarySoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: unlocked ? gdPrimary : gdBorder),
        ),
        child: CompanionPortrait(
          kind: companion,
          size: 50,
          silhouette: !unlocked,
        ),
      ),
    );
  }
}

class _GachaRevealOverlay extends StatelessWidget {
  const _GachaRevealOverlay({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  final CompanionGachaResult? result;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.36),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            child: result == null
                ? const _GachaRollingCard()
                : _GachaResultCard(
                    key: ValueKey(result!.companion.id),
                    result: result!,
                    onDismiss: onDismiss!,
                  ),
          ),
        ),
      ),
    );
  }
}

class _GachaRollingCard extends StatelessWidget {
  const _GachaRollingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('rolling'),
      width: 260,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: gdSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: gdBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 820),
            curve: Curves.easeInOutCubic,
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * math.pi * 4,
                child: Transform.scale(
                  scale: 0.9 + math.sin(value * math.pi) * 0.18,
                  child: child,
                ),
              );
            },
            child: Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: gdPrimarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: gdPrimary, width: 2),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: gdPrimary,
                size: 52,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Drawing capsule...',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: gdInk,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _GachaResultCard extends StatelessWidget {
  const _GachaResultCard({
    super.key,
    required this.result,
    required this.onDismiss,
  });

  final CompanionGachaResult result;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final companion = result.companion;
    final statusText = result.duplicate
        ? 'Duplicate pull'
        : '${result.rarity.label} companion';
    final detailText = result.duplicate
        ? 'Refunded ${result.refund} coins. Net cost ${result.netCost}.'
        : 'Added to your roster and equipped.';

    return TweenAnimationBuilder<double>(
      key: ValueKey('result-${companion.id}-${result.duplicate}'),
      tween: Tween(begin: 0.84, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: Container(
        width: 310,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: gdSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: gdPrimary),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: result.duplicate ? gdMuted : gdPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: 190,
              height: 190,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: gdPrimarySoft,
                shape: BoxShape.circle,
                border: Border.all(color: gdBorder),
              ),
              child: CompanionPortrait(kind: companion, size: 168),
            ),
            const SizedBox(height: 14),
            Text(
              companion.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: gdInk,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detailText,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: gdMuted,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onDismiss,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionPickerSheet extends StatelessWidget {
  const _CompanionPickerSheet({
    required this.activeCompanion,
    required this.unlockedCompanions,
    required this.onSelected,
  });

  final CompanionKind activeCompanion;
  final Set<CompanionKind> unlockedCompanions;
  final ValueChanged<CompanionKind> onSelected;

  bool _isUnlocked(CompanionKind companion) {
    return companion == CompanionKind.lumi ||
        unlockedCompanions.contains(companion);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Companions', style: GdText.titleLarge),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final companion in CompanionKind.values) ...[
              _CompanionPickerRow(
                companion: companion,
                selected: activeCompanion == companion,
                unlocked: _isUnlocked(companion),
                onSelected: () => onSelected(companion),
              ),
              if (companion != CompanionKind.values.last)
                Divider(color: gdBorder),
            ],
          ],
        ),
      ),
    );
  }
}

class _CompanionPickerRow extends StatelessWidget {
  const _CompanionPickerRow({
    required this.companion,
    required this.selected,
    required this.unlocked,
    required this.onSelected,
  });

  final CompanionKind companion;
  final bool selected;
  final bool unlocked;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final rarityLabel = companion.rarity?.label ?? 'Default';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: gdPrimarySoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? gdPrimary : gdBorder),
            ),
            child: CompanionPortrait(
              kind: companion,
              size: 50,
              silhouette: !unlocked,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companion.label,
                  style: TextStyle(
                    color: gdInk,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  unlocked ? rarityLabel : 'Locked | $rarityLabel',
                  style: TextStyle(
                    color: gdMuted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Icon(Icons.check_circle_rounded, color: gdPrimary)
          else if (unlocked)
            IconButton(
              tooltip: 'Show ${companion.label}',
              onPressed: onSelected,
              icon: Icon(Icons.visibility_rounded, color: gdPrimary),
            )
          else
            Icon(Icons.lock_rounded, color: gdMuted),
        ],
      ),
    );
  }
}

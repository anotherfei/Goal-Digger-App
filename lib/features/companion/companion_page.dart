import 'package:flutter/material.dart';

import '../../core/theme/gd_design.dart';
import '../../models/models.dart';
import '../../shared/widgets/shared_widgets.dart';
import 'lumi_sprite.dart';

class CompanionPage extends StatefulWidget {
  const CompanionPage({
    super.key,
    required this.coins,
    required this.happiness,
    required this.lumiTier,
    required this.pet,
    required this.accessory,
    required this.onFeed,
    required this.onOpenChest,
    required this.onPetInteract,
  });

  final int coins;
  final int happiness;
  final LumiStreakTier lumiTier;
  final PetSkin pet;
  final String accessory;
  final VoidCallback onFeed;
  final VoidCallback onOpenChest;
  final VoidCallback onPetInteract;

  @override
  State<CompanionPage> createState() => _CompanionPageState();
}

class _CompanionPageState extends State<CompanionPage> {
  String _selectedSkin = 'Mint';

  @override
  void didUpdateWidget(covariant CompanionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedSkin = widget.pet.name;
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
                          'PET PREVIEW',
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
                        child: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: gdCardLight,
                                shape: BoxShape.circle,
                                border: Border.all(color: gdBorder),
                              ),
                              child: LumiCompanionSprite(
                                tier: widget.lumiTier,
                                size: 178,
                                onTap: widget.onPetInteract,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: gdSurface,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: gdBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Text(
                                widget.accessory,
                                style: TextStyle(
                                  color: gdInk,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
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
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: _SkinPill(
                              label: 'Mint',
                              selected: _selectedSkin == 'Mint',
                              onTap: () {
                                setState(() => _selectedSkin = 'Mint');
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SkinPill(
                              label: 'Peach',
                              selected: _selectedSkin == 'Peach',
                              onTap: () {
                                setState(() => _selectedSkin = 'Peach');
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SkinPill(
                              label: 'Lunar',
                              selected: _selectedSkin == 'Lunar',
                              onTap: () {
                                setState(() => _selectedSkin = 'Lunar');
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const SectionTitle(
                title: 'Mystery chest',
                trailing: '50 coins',
              ),

              const SizedBox(height: 10),

              AppCard(
                color: gdSurface,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: gdPrimarySoft,
                            child: Icon(
                              Icons.inventory_2_rounded,
                              color: gdPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Open a chest for random pet skins or accessories.',
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

class _FloatingWallet extends StatelessWidget {
  const _FloatingWallet({
    required this.coins,
  });

  final int coins;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
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

class _SkinPill extends StatelessWidget {
  const _SkinPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 62,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? gdPrimary : gdSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: selected
              ? null
              : [
                  BoxShadow(
                    color: gdShadow.withValues(alpha: GdAlpha.faint),
                    blurRadius: 12,
                  ),
                ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? gdOnDark : gdMuted,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

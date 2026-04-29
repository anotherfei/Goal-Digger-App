import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pet_look.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import '../widgets/glass_card.dart';

class _ShopItem {
  final String name;
  final int price;
  final String note;
  const _ShopItem({required this.name, required this.price, required this.note});
}

const _shopItems = [
  _ShopItem(name: 'Cloud Bed', price: 120, note: 'Rest bonus'),
  _ShopItem(name: 'Focus Lamp', price: 80, note: 'Deep work glow'),
  _ShopItem(name: 'Trail Cape', price: 150, note: 'Streak style'),
];

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3400))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pet = state.activePet;
    final doneTasks = state.todayTasks.where((t) => t.done).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PET CUSTOMIZATION & SHOP', style: AppTextStyles.labelTeal),
          const SizedBox(height: 16),
          Text('Companion', style: AppTextStyles.heading1),
          const SizedBox(height: 16),
          Text('Your pet grows through completed micro-tasks.', style: AppTextStyles.body),

          const SizedBox(height: 28),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.dark, borderRadius: BorderRadius.circular(36),
              boxShadow: [BoxShadow(color: AppColors.dark.withValues(alpha: 0.28), blurRadius: 90, offset: const Offset(0, 32))],
            ),
            child: Column(children: [
              Text('ACTIVE COMPANION', style: AppTextStyles.label.copyWith(color: Colors.white38)),
              const SizedBox(height: 10),
              Text(pet.name, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.5, color: Colors.white)),
              const SizedBox(height: 24),
              AnimatedBuilder(
                animation: _idleController,
                builder: (context, _) => Transform.translate(
                  offset: Offset(0, -10 * _idleController.value),
                  child: Transform.scale(scaleY: 1 + (0.02 * _idleController.value), alignment: Alignment.bottomCenter, child: _PetAvatar(pet: pet)),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: petLooks.map((p) {
                  final isActive = state.selectedPetId == p.id;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => state.setSelectedPet(p.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: p.id != 'lunar' ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(child: Text(p.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: isActive ? AppColors.dark : Colors.white60))),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // Feed It
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFAF2),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: AppColors.amberLight.withValues(alpha: 0.6)),
              boxShadow: [BoxShadow(color: const Color(0xFF4A3D27).withValues(alpha: 0.12), blurRadius: 60, offset: const Offset(0, 24))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('FEED IT!', style: AppTextStyles.label.copyWith(color: const Color(0xFF92400E))),
                    const SizedBox(height: 4),
                    const Text('Please feed me! 🥺', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.6, color: AppColors.textPrimary)),
                  ]),
                  Text(
                    state.petHunger < 30 ? '😢' : state.petHunger < 60 ? '😐' : state.petHunger < 85 ? '😊' : '😍',
                    style: const TextStyle(fontSize: 36),
                  ),
                ]),
                const SizedBox(height: 16),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Hunger', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textTertiary)),
                  Text('${state.petHunger}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                ]),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 18,
                    child: LinearProgressIndicator(
                      value: state.petHunger / 100,
                      backgroundColor: AppColors.dark.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation(
                        state.petHunger < 30 ? Colors.red : state.petHunger < 60 ? AppColors.amberWarm : AppColors.emerald,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (doneTasks.isNotEmpty)
                  Row(
                    children: doneTasks.take(3).map((t) => Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                        child: Column(children: [
                          const Text('✅', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('TASK', style: AppTextStyles.label.copyWith(fontSize: 8)),
                          Text('${t.points} Pts', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.emerald)),
                        ]),
                      ),
                    )).toList(),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(16)),
                    child: const Center(child: Text('Complete tasks to feed your pet!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textTertiary))),
                  ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: (state.earnedPointsToday >= 10 && state.petHunger < 100) ? state.feedPet : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: (state.earnedPointsToday >= 10 && state.petHunger < 100) ? AppColors.dark : AppColors.dark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(child: Text(
                      state.petHunger >= 100 ? 'Pet is full! 😊' : state.earnedPointsToday < 10 ? 'Complete tasks to feed' : 'Feed pet (10 coins)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900,
                          color: (state.earnedPointsToday >= 10 && state.petHunger < 100) ? Colors.white : AppColors.textTertiary),
                    )),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          GlassCard(
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('WALLET', style: AppTextStyles.label),
                const SizedBox(height: 8),
                Text('${state.petCoins} coins', style: AppTextStyles.heading4),
              ]),
              Container(width: 56, height: 56, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.amberLight),
                child: const Center(child: Text('C', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF78350F))))),
            ]),
          ),

          const SizedBox(height: 20),

          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Shop', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              ..._shopItems.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                    Text(item.note, style: AppTextStyles.bodySmall.copyWith(fontSize: 12)),
                  ])),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                      child: Text('${item.price} C', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ]),
              )),
            ]),
          ),
        ],
      ),
    );
  }
}

class _PetAvatar extends StatelessWidget {
  final PetLook pet;
  const _PetAvatar({required this.pet});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180, height: 180,
      child: Stack(alignment: Alignment.center, children: [
        Positioned(left: 18, top: 8, child: Transform.rotate(angle: -0.4, child: Container(width: 52, height: 70,
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: pet.bodyGradient),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)))))),
        Positioned(right: 18, top: 8, child: Transform.rotate(angle: 0.4, child: Container(width: 52, height: 70,
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: pet.bodyGradient),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(36), topRight: Radius.circular(36), bottomLeft: Radius.circular(18), bottomRight: Radius.circular(18)))))),
        Positioned(bottom: 8, child: Container(width: 140, height: 130,
          decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: pet.bodyGradient),
            borderRadius: BorderRadius.circular(70), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.16), blurRadius: 30, offset: const Offset(0, 16))]),
          child: Stack(children: [
            Positioned(left: 34, top: 44, child: Container(width: 14, height: 14, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.dark))),
            Positioned(right: 34, top: 44, child: Container(width: 14, height: 14, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.dark))),
            Positioned(left: 0, right: 0, top: 66, child: Center(child: Container(width: 22, height: 10, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: AppColors.dark.withValues(alpha: 0.7))))),
            Positioned(bottom: 14, left: 0, right: 0, child: Center(child: Container(width: 76, height: 46, decoration: BoxDecoration(borderRadius: BorderRadius.circular(36), color: pet.accent)))),
          ]))),
      ]),
    );
  }
}

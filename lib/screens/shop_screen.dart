import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/colors.dart';
import '../models/pet_look.dart';
import '../widgets/glass_card.dart';
import '../widgets/pet_widget.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final pet = s.activePet;

    final items = [
      ('Cloud Bed', 120, 'Rest bonus', '☁️', 'Furniture'),
      ('Focus Lamp', 80, 'Deep work glow', '💡', 'Room'),
      ('Trail Cape', 150, 'Streak style', '🧣', 'Costume'),
      ('Star Hat', 95, 'Motivation charm', '🎩', 'Costume'),
      ('Tiny Backpack', 110, 'Adventure gear', '🎒', 'Costume'),
      ('Snack Bowl', 70, 'Happy pet boost', '🥣', 'Food'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _PageBuddy(from: pet.from, to: pet.to, accent: pet.accent, title: 'Shopkeeper',
          text: 'Spend the coins your tasks earned on costumes and items.'),
        const SizedBox(height: 16),

        // Wallet
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.dark, Color(0xFF1E293B)]),
            borderRadius: BorderRadius.circular(32),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('WALLET', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white.withValues(alpha: 0.5))),
              const SizedBox(height: 6),
              Text('${s.coins}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
              Text('coins earned', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.5))),
            ]),
            Container(width: 56, height: 56,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)])),
              child: const Center(child: Text('C', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF78350F))))),
          ]),
        ),
        const SizedBox(height: 16),

        // Pet preview
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [pet.from.withValues(alpha: 0.15), pet.to.withValues(alpha: 0.1)]),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          ),
          child: Column(children: [
            Text('PET PREVIEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: pet.from)),
            const SizedBox(height: 12),
            PetWidget(size: 140, from: pet.from, to: pet.to, accent: pet.accent, animate: false),
            const SizedBox(height: 16),
            Row(children: petLooks.map((p) => Expanded(child: GestureDetector(
              onTap: () => s.setPetId(p.id),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: s.petId == p.id ? AppColors.dark : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text(p.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: s.petId == p.id ? Colors.white : AppColors.textSecondary))),
              ),
            ))).toList()),
          ]),
        ),
        const SizedBox(height: 16),

        // Shop grid
        const Text('Customize pet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12,
          childAspectRatio: 0.72, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: items.map((it) => Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))]),
            child: Column(children: [
              Expanded(child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFFFFF2D6), Color(0xFFE0F2FE)]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Center(child: Text(it.$4, style: const TextStyle(fontSize: 40))),
              )),
              Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(it.$1, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.textPrimary))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.dark.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(100)),
                    child: Text(it.$5, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: AppColors.textTertiary)),
                  ),
                ]),
                Text(it.$3, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textTertiary)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(color: AppColors.dark, borderRadius: BorderRadius.circular(100)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(width: 20, height: 20,
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFFFCD34D), Color(0xFFF59E0B)])),
                      child: const Center(child: Text('C', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF78350F))))),
                    const SizedBox(width: 6),
                    Text('${it.$2}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                  ]),
                ),
              ])),
            ]),
          )).toList(),
        ),
      ]),
    );
  }
}

class _PageBuddy extends StatelessWidget {
  final Color from, to, accent;
  final String title, text;
  const _PageBuddy({required this.from, required this.to, required this.accent, required this.title, required this.text});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(gradient: LinearGradient(colors: [from.withValues(alpha: 0.15), to.withValues(alpha: 0.1)]), borderRadius: BorderRadius.circular(28), border: Border.all(color: Colors.white.withValues(alpha: 0.7))),
    child: Row(children: [
      PetWidget(size: 72, from: from, to: to, accent: accent, animate: false),
      const SizedBox(width: 12),
      Expanded(child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: from)),
          const SizedBox(height: 4),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.5, color: AppColors.textSecondary)),
        ]))),
    ]),
  );
}

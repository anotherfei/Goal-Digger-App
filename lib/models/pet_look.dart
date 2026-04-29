import 'package:flutter/material.dart';

class PetLook {
  final String id;
  final String name;
  final List<Color> bodyGradient;
  final Color accent;

  const PetLook({
    required this.id,
    required this.name,
    required this.bodyGradient,
    required this.accent,
  });
}

const List<PetLook> petLooks = [
  PetLook(
    id: 'mint',
    name: 'Mint',
    bodyGradient: [Color(0xFF7DD3FC), Color(0xFF34D399)],
    accent: Color(0xFFD1FAE5),
  ),
  PetLook(
    id: 'peach',
    name: 'Peach',
    bodyGradient: [Color(0xFFFDBA74), Color(0xFFFB7185)],
    accent: Color(0xFFFFEDD5),
  ),
  PetLook(
    id: 'lunar',
    name: 'Lunar',
    bodyGradient: [Color(0xFFA78BFA), Color(0xFF475569)],
    accent: Color(0xFFEDE9FE),
  ),
];

import 'package:flutter/material.dart';

class PetLook {
  final String id;
  final String name;
  final Color from;
  final Color to;
  final Color accent;

  const PetLook({required this.id, required this.name, required this.from, required this.to, required this.accent});
}

const List<PetLook> petLooks = [
  PetLook(id: 'mint', name: 'Mint', from: Color(0xFF7DD3FC), to: Color(0xFF34D399), accent: Color(0xFFD1FAE5)),
  PetLook(id: 'peach', name: 'Peach', from: Color(0xFFFDBA74), to: Color(0xFFFB7185), accent: Color(0xFFFFEDD5)),
  PetLook(id: 'lunar', name: 'Lunar', from: Color(0xFFA78BFA), to: Color(0xFF475569), accent: Color(0xFFEDE9FE)),
];

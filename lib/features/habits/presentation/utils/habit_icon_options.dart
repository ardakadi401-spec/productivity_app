import 'package:flutter/material.dart';

/// DATABASE.md §6.2 `icon` — "İkon seti içindeki referans anahtar". Sabit,
/// küçük bir alışkanlık ikon seti (Projects'in renk paleti gibi sabit bir
/// seçim listesi, ROADMAP.md FAZ 9 "isim, ikon, tekrar sıklığı").
const List<String> habitIconOptions = [
  'water_drop',
  'book',
  'directions_run',
  'self_improvement',
  'bedtime',
  'restaurant',
  'fitness_center',
  'smoke_free',
];

const _iconMap = {
  'water_drop': Icons.water_drop_outlined,
  'book': Icons.menu_book_outlined,
  'directions_run': Icons.directions_run,
  'self_improvement': Icons.self_improvement,
  'bedtime': Icons.bedtime_outlined,
  'restaurant': Icons.restaurant_outlined,
  'fitness_center': Icons.fitness_center,
  'smoke_free': Icons.smoke_free,
};

IconData habitIconFor(String? key) => _iconMap[key] ?? Icons.check_circle_outline;

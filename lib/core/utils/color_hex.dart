import 'package:flutter/material.dart';

/// `#RRGGBB` hex kod → [Color]. DATABASE.md §3.2 `Project.color` alanı
/// Firestore/Isar'da string olarak saklanır; Projects VE Tasks (ilişkili
/// proje rozeti, SCREENS.md §4.10) bu dönüşümü kullandığından `core/utils/`
/// altında feature-bağımsız tutulur (ARCHITECTURE.md §10.2 madde 3).
Color hexToColor(String hex) {
  final normalized = hex.replaceFirst('#', '');
  return Color(int.parse('FF$normalized', radix: 16));
}

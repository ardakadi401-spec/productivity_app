import 'package:flutter/material.dart';

/// Project Color Badge — COMPONENTS.md §7.3: 12dp çap, tam yuvarlak nokta.
/// Project Card'da (Projects feature) VE Task Detail'de (ilişkili proje
/// bilgisi, SCREENS.md §4.10) kullanıldığından (2+ feature eşiği,
/// FOLDER_STRUCTURE.md §6.3) `shared/components/`'te; herhangi bir domain
/// entity'sine değil yalnızca bir [Color]'a bağımlıdır.
class ProjectColorBadge extends StatelessWidget {
  const ProjectColorBadge({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

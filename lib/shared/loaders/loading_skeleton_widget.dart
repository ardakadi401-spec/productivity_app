import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Loading State — COMPONENTS.md Bölüm 11.1. Jenerik spinner **kullanılmaz**
/// (UI_GUIDELINES.md Bölüm 13.5); bunun yerine gerçek ekranın yapısını taklit
/// eden soluk bloklar + hafif shimmer animasyonu kullanılır. Bu widget tek
/// bir bloğu temsil eder — ekranlar, kendi kart/liste yapısını bu blokları
/// bir araya getirerek (`Column`/`Row` içinde) oluşturur; sabit tek bir
/// "genel" iskelet şekli doküman tarafından tanımlanmamıştır.
class LoadingSkeleton extends StatefulWidget {
  const LoadingSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius = 8,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final sweep = _controller.value * 2 - 1; // -1 -> 1
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(sweep - 0.3, 0),
              end: Alignment(sweep + 0.3, 0),
              colors: [tokens.border, tokens.surfaceElevated, tokens.border],
            ),
          ),
        );
      },
    );
  }
}

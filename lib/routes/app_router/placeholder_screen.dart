import 'package:flutter/material.dart';

/// FAZ 1.4 kapsamında tüm route'lar için geçici hedef.
///
/// Her feature fazı tamamlandıkça (bkz. ROADMAP.md FAZ 5-13), ilgili route
/// burada değil, o feature'ın kendi `presentation/pages/` ekranına yönlenir.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.routeName});

  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(routeName)),
      body: Center(
        child: Text(
          '$routeName\n(placeholder — FAZ 1.4)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}

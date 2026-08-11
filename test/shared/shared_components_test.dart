import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/core/theme/app_theme.dart';
import 'package:productivity_app/shared/buttons/app_button_widget.dart';
import 'package:productivity_app/shared/dialogs/app_bottom_sheet.dart';
import 'package:productivity_app/shared/dialogs/app_dialog.dart';
import 'package:productivity_app/shared/forms/app_text_field_widget.dart';
import 'package:productivity_app/shared/loaders/loading_skeleton_widget.dart';
import 'package:productivity_app/shared/widgets/app_snackbar_widget.dart';
import 'package:productivity_app/shared/widgets/empty_state_widget.dart';
import 'package:productivity_app/shared/widgets/error_state_widget.dart';

Widget _withTheme(ThemeData theme, Widget child) {
  return MaterialApp(theme: theme, home: Scaffold(body: child));
}

void main() {
  final themes = {
    'Light': AppTheme.light,
    'Dark': AppTheme.dark,
    'AMOLED': AppTheme.amoled,
  };

  for (final entry in themes.entries) {
    group('${entry.key} theme', () {
      final theme = entry.value;

      testWidgets('AppButton renders all variants without error', (tester) async {
        await tester.pumpWidget(_withTheme(
          theme,
          Column(
            children: [
              AppButton(label: 'Primary', onPressed: () {}),
              AppButton(label: 'Secondary', variant: AppButtonVariant.secondary, onPressed: () {}),
              AppButton(label: 'Outline', variant: AppButtonVariant.outline, onPressed: () {}),
              AppButton(label: 'Text', variant: AppButtonVariant.text, onPressed: () {}),
              const AppButton(label: 'Disabled', onPressed: null),
              AppButton(label: 'Loading', isLoading: true, onPressed: () {}),
              AppIconButton(icon: Icons.add, semanticLabel: 'Ekle', onPressed: () {}),
              AppFabButton(icon: Icons.add, semanticLabel: 'Ekle', onPressed: () {}),
            ],
          ),
        ));

        expect(find.text('Primary'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.tap(find.text('Primary'));
        await tester.pump();
      });

      testWidgets('AppTextField shows label and error text', (tester) async {
        await tester.pumpWidget(_withTheme(
          theme,
          const AppTextField(label: 'E-posta', errorText: 'Geçersiz'),
        ));

        expect(find.text('E-posta'), findsOneWidget);
        expect(find.text('Geçersiz'), findsOneWidget);
      });

      testWidgets('LoadingSkeleton renders and animates', (tester) async {
        await tester.pumpWidget(_withTheme(theme, const LoadingSkeleton(width: 100)));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(LoadingSkeleton), findsOneWidget);
      });

      testWidgets('EmptyState renders message and action', (tester) async {
        await tester.pumpWidget(_withTheme(
          theme,
          EmptyState(
            icon: Icons.inbox,
            message: 'Boş',
            actionLabel: 'Ekle',
            onAction: () {},
          ),
        ));
        expect(find.text('Boş'), findsOneWidget);
        expect(find.text('Ekle'), findsOneWidget);
      });

      testWidgets('ErrorState renders message and retry', (tester) async {
        await tester.pumpWidget(_withTheme(
          theme,
          ErrorState(message: 'Hata', onRetry: () {}),
        ));
        expect(find.text('Hata'), findsOneWidget);
        expect(find.text('Tekrar Dene'), findsOneWidget);
      });

      testWidgets('AppSnackbar shows message on trigger', (tester) async {
        await tester.pumpWidget(_withTheme(
          theme,
          Builder(
            builder: (context) => AppButton(
              label: 'Göster',
              onPressed: () => AppSnackbar.show(context, message: 'Kaydedildi'),
            ),
          ),
        ));

        await tester.tap(find.text('Göster'));
        await tester.pump();
        expect(find.text('Kaydedildi'), findsOneWidget);
      });

      testWidgets('AppDialog opens with title and actions', (tester) async {
        await tester.pumpWidget(_withTheme(
          theme,
          Builder(
            builder: (context) => AppButton(
              label: 'Aç',
              onPressed: () => AppDialog.show(
                context,
                title: 'Başlık',
                description: 'Açıklama',
                confirmLabel: 'Onayla',
              ),
            ),
          ),
        ));

        await tester.tap(find.text('Aç'));
        await tester.pumpAndSettle();
        expect(find.text('Başlık'), findsOneWidget);
        expect(find.text('Onayla'), findsOneWidget);

        await tester.tap(find.text('Onayla'));
        await tester.pumpAndSettle();
        expect(find.text('Başlık'), findsNothing);
      });

      testWidgets('AppBottomSheet opens with child content', (tester) async {
        await tester.pumpWidget(_withTheme(
          theme,
          Builder(
            builder: (context) => AppButton(
              label: 'Aç',
              onPressed: () => AppBottomSheet.show(
                context,
                child: const Text('Sheet İçeriği'),
              ),
            ),
          ),
        ));

        await tester.tap(find.text('Aç'));
        await tester.pumpAndSettle();
        expect(find.text('Sheet İçeriği'), findsOneWidget);
      });
    });
  }
}

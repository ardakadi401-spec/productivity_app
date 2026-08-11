import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_mode.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_mode_provider.dart';
import '../../../../routes/route_paths/route_paths.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/components/app_top_bar.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/loaders/loading_skeleton_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../shared/widgets/error_state_widget.dart';
import '../../../tasks/presentation/pages/create_task_page.dart';
import '../../domain/entities/calendar_event.dart';
import '../providers/calendar_providers.dart';
import '../widgets/calendar_header_widget.dart';
import '../widgets/event_card_widget.dart';
import '../widgets/month_grid_widget.dart';

DateTime _normalizeDay(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime _normalizeMonth(DateTime date) => DateTime(date.year, date.month);

/// Tab 3 — Calendar Screen — SCREENS.md §4.13: aylık takvim grid'i + seçili
/// güne ait günlük ajanda listesi, tek ekranda. Haftalık görünüm bu fazın
/// kapsamı dışındadır (ROADMAP.md FAZ 7 notu, MVP+ kapsamı). Goals
/// entegrasyonu FAZ 8 tamamlandıktan sonra eklenecektir (ROADMAP.md FAZ 7
/// notu) — bu fazda yalnızca Tasks verisi gösterilir.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  DateTime _selectedDate = _normalizeDay(DateTime.now());
  DateTime _visibleMonth = _normalizeMonth(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final isAmoled = ref.watch(themeModeProvider) == AppThemeMode.amoled;
    final monthEventsAsync = ref.watch(calendarMonthEventsProvider(_visibleMonth));
    final dayEventsAsync = ref.watch(calendarDayEventsProvider(_selectedDate));

    final eventDates = monthEventsAsync.valueOrNull
            ?.map((e) => _normalizeDay(e.date))
            .toSet() ??
        const <DateTime>{};

    return Scaffold(
      body: Column(
        children: [
          AppTopBar(
            title: 'Takvim',
            isAmoled: isAmoled,
            actions: [
              AppIconButton(
                icon: Icons.search,
                semanticLabel: 'Ara',
                onPressed: () => context.push(RoutePaths.search),
              ),
            ],
          ),
          Expanded(
            // Aylık grid + günlük ajanda tek bir kaydırılabilir listede
            // birleştirilir — Task/Project Detail ekranlarındaki desenle
            // aynı (sabit yükseklikli iç içe Expanded/ListView, düşük
            // ekranlarda taşmaya yol açar).
            child: ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: CalendarHeaderWidget(
                    month: _visibleMonth,
                    onPreviousMonth: () => setState(
                      () => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1),
                    ),
                    onNextMonth: () => setState(
                      () => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1),
                    ),
                    onToday: () => setState(() {
                      _selectedDate = _normalizeDay(DateTime.now());
                      _visibleMonth = _normalizeMonth(DateTime.now());
                    }),
                    onMonthYearTap: _showMonthYearPicker,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: MonthGridWidget(
                    month: _visibleMonth,
                    selectedDate: _selectedDate,
                    eventDates: eventDates,
                    onDaySelected: (date) => setState(() => _selectedDate = date),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Text(
                    _selectedDate.relativeAgendaLabel,
                    style: AppTypography.h3.copyWith(color: Theme.of(context).colorScheme.onSurface),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: dayEventsAsync.when(
                    loading: () => const Column(
                      children: [
                        LoadingSkeleton(height: 52, borderRadius: 12),
                        SizedBox(height: AppSpacing.sm),
                        LoadingSkeleton(height: 52, borderRadius: 12),
                      ],
                    ),
                    error: (error, _) {
                      final message = error is Failure ? error.message : 'Ajanda yüklenemedi.';
                      return ErrorState(
                        message: message,
                        onRetry: () => ref.invalidate(calendarDayEventsProvider(_selectedDate)),
                      );
                    },
                    data: (events) {
                      if (events.isEmpty) {
                        return EmptyState(
                          icon: Icons.event_available_outlined,
                          message: 'Bu gün için planlanan bir şey yok',
                          actionLabel: 'Görev Ekle',
                          onAction: () => context.push(
                            RoutePaths.createTask,
                            extra: CreateTaskArgs(dueDate: _selectedDate),
                          ),
                        );
                      }
                      return Column(
                        children: [
                          for (final event in events) ...[
                            EventCardWidget(
                              title: event.title,
                              time: event.time,
                              source: event.source,
                              isCompleted: event.isCompleted,
                              onTap: () => _openEventDetail(context, event),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: AppFabButton(
        icon: Icons.add,
        semanticLabel: 'Bu Güne Görev Ekle',
        onPressed: () => context.push(
          RoutePaths.createTask,
          extra: CreateTaskArgs(dueDate: _selectedDate),
        ),
      ),
    );
  }

  void _openEventDetail(BuildContext context, CalendarEvent event) {
    switch (event.source) {
      case CalendarEventSource.task:
        context.push(RoutePaths.taskDetail.replaceFirst(':taskId', event.id));
      case CalendarEventSource.goal:
        // Calendar'ın kendi hedef detay ekranı yoktur; SCREENS.md §4.13
        // "Sonraki Ekran Bağlantıları: → Goals Screen (hedef öğesine
        // dokunma)" — hedef detay/düzenleme etkileşimi Goals Screen'in
        // kendi Bottom Sheet'i üzerinden çözülür (bkz. SCREENS.md §4.14).
        context.go(RoutePaths.goals);
    }
  }

  void _showMonthYearPicker() {
    AppBottomSheet.show<void>(
      context,
      child: _MonthYearPicker(
        initialYear: _visibleMonth.year,
        onSelected: (year, month) {
          setState(() => _visibleMonth = DateTime(year, month));
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

/// COMPONENTS.md §8.1 "başlığa dokunma → hızlı yıl/ay seçici (Bottom Sheet)".
class _MonthYearPicker extends StatefulWidget {
  const _MonthYearPicker({required this.initialYear, required this.onSelected});

  final int initialYear;
  final void Function(int year, int month) onSelected;

  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  late int _year = widget.initialYear;

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;

    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => setState(() => _year -= 1),
              ),
              Text('$_year', style: AppTypography.h2.copyWith(color: tokens.textSecondary)),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => setState(() => _year += 1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 2.4,
            children: [
              for (var month = 1; month <= 12; month++)
                TextButton(
                  onPressed: () => widget.onSelected(_year, month),
                  child: Text(_monthShortNames[month - 1]),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

const _monthShortNames = [
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

extension _AgendaLabel on DateTime {
  String get relativeAgendaLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = DateTime(year, month, day).difference(today).inDays;
    return switch (diff) {
      0 => 'Bugün',
      1 => 'Yarın',
      -1 => 'Dün',
      _ => '$day.$month.$year',
    };
  }
}

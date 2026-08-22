import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/extensions/duration_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/buttons/app_button_widget.dart';
import '../../../../shared/components/app_chip.dart';
import '../../../../shared/components/circular_progress_gauge_widget.dart';
import '../../../../shared/dialogs/app_bottom_sheet.dart';
import '../../../../shared/widgets/app_snackbar_widget.dart';
import '../../../tasks/domain/entities/task.dart';
import '../../../tasks/domain/entities/task_filter.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../domain/utils/pomodoro_timer_state.dart';
import '../controllers/pomodoro_timer_controller.dart';

/// Pomodoro Screen — SCREENS.md §4.17.
class PomodoroPage extends ConsumerStatefulWidget {
  const PomodoroPage({super.key, this.initialTaskId});

  /// Task Detail Screen'in "Pomodoro ile Çalış" eylemiyle önceden seçilen
  /// görev (SCREENS.md §4.10).
  final String? initialTaskId;

  @override
  ConsumerState<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends ConsumerState<PomodoroPage> {
  @override
  void initState() {
    super.initState();
    final initialTaskId = widget.initialTaskId;
    if (initialTaskId == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(pomodoroTimerControllerProvider.notifier);
      if (ref.read(pomodoroTimerControllerProvider).isIdle) {
        controller.setTaskId(initialTaskId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final controller = ref.read(pomodoroTimerControllerProvider.notifier);
    final status = ref.watch(pomodoroTimerControllerProvider.select((s) => s.status));
    final isIdle = status == PomodoroRunStatus.idle;
    final isRunning = status == PomodoroRunStatus.running;
    final taskId = ref.watch(pomodoroTimerControllerProvider.select((s) => s.taskId));
    final completedCount =
        ref.watch(pomodoroTimerControllerProvider.select((s) => s.completedWorkSessionCount));

    return Scaffold(
      appBar: AppBar(title: const Text('Pomodoro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              const _CountdownDisplay(),
              const SizedBox(height: AppSpacing.lg),
              if (taskId != null) _LinkedTaskLabel(taskId: taskId),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: AppButton(
                      label: isRunning ? 'Duraklat' : (isIdle ? 'Başlat' : 'Devam Et'),
                      onPressed: () => _onPrimaryAction(context, controller, isRunning, isIdle),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppButton(
                    label: 'Sıfırla',
                    variant: AppButtonVariant.text,
                    onPressed: isIdle
                        ? null
                        : () async {
                            final result = await controller.reset();
                            if (!context.mounted) return;
                            if (result case Err(:final failure)) {
                              AppSnackbar.show(context, message: failure.message);
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Tamamlanan Oturum: $completedCount',
                style: AppTypography.caption.copyWith(color: tokens.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              _TaskPickerField(taskId: taskId, onChanged: controller.setTaskId),
              if (isIdle) ...[
                const SizedBox(height: AppSpacing.lg),
                const _DurationPresets(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPrimaryAction(
    BuildContext context,
    PomodoroTimerController controller,
    bool isRunning,
    bool isIdle,
  ) async {
    if (isRunning) {
      controller.pause();
      return;
    }
    if (isIdle) {
      final result = await controller.start();
      if (!context.mounted) return;
      if (result case Err(:final failure)) {
        AppSnackbar.show(context, message: failure.message);
      }
      return;
    }
    controller.resume();
  }
}

/// `select` ile yalnızca geri sayım metnine/fazına izole abone olur
/// (STATE_MANAGEMENT.md §12.1/§12.2 — saniyelik tick, ekranın geri kalanını
/// yeniden derlememeli).
class _CountdownDisplay extends ConsumerWidget {
  const _CountdownDisplay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final display = ref.watch(
      pomodoroTimerControllerProvider.select(
        (s) => (remaining: s.remaining, phaseDuration: s.phaseDuration, phase: s.phase),
      ),
    );
    final isBreak = display.phase == PomodoroPhase.breakTime;
    final elapsed = display.phaseDuration - display.remaining;
    final progress = display.phaseDuration.inMilliseconds == 0
        ? 0.0
        : elapsed.inMilliseconds / display.phaseDuration.inMilliseconds;
    final theme = Theme.of(context);

    return CircularProgressGaugeWidget(
      progress: progress,
      centerLabel: display.remaining.mmss,
      subLabel: isBreak ? 'MOLA' : 'ÇALIŞMA',
      color: isBreak ? theme.colorScheme.secondary : theme.colorScheme.primary,
    );
  }
}

class _LinkedTaskLabel extends ConsumerWidget {
  const _LinkedTaskLabel({required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final task = ref.watch(taskDetailProvider(taskId)).valueOrNull;
    if (task == null) return const SizedBox.shrink();
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    return Text(
      'Görev: ${task.title}',
      style: AppTypography.bodyMd.copyWith(color: tokens.textSecondary),
    );
  }
}

class _TaskPickerField extends ConsumerWidget {
  const _TaskPickerField({required this.taskId, required this.onChanged});

  final String? taskId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider(TaskFilter.none)).valueOrNull ?? const <Task>[];
    final selectedTitle = _selectedTaskTitle(tasks);

    return AppButton(
      label: selectedTitle == null ? 'Göreve Bağla (opsiyonel)' : 'Görev: $selectedTitle',
      variant: AppButtonVariant.outline,
      onPressed: () => _pickTask(context, tasks),
    );
  }

  String? _selectedTaskTitle(List<Task> tasks) {
    if (taskId == null) return null;
    for (final task in tasks) {
      if (task.taskId == taskId) return task.title;
    }
    return null;
  }

  Future<void> _pickTask(BuildContext context, List<Task> tasks) {
    return AppBottomSheet.show<void>(
      context,
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.block),
            title: const Text('Bağlantısız'),
            selected: taskId == null,
            onTap: () {
              onChanged(null);
              Navigator.of(context).pop();
            },
          ),
          for (final task in tasks)
            ListTile(
              title: Text(task.title),
              selected: task.taskId == taskId,
              onTap: () {
                onChanged(task.taskId);
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
    );
  }
}

class _DurationPresets extends ConsumerWidget {
  const _DurationPresets();

  static const _workPresets = [15, 25, 45, 60];
  static const _breakPresets = [5, 10, 15];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = Theme.of(context).extension<AppColorsExtension>()!;
    final controller = ref.read(pomodoroTimerControllerProvider.notifier);
    final workDuration = ref.watch(pomodoroTimerControllerProvider.select((s) => s.workDuration));
    final breakDuration = ref.watch(pomodoroTimerControllerProvider.select((s) => s.breakDuration));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Çalışma Süresi (dk)', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final minutes in _workPresets)
              AppChip(
                label: '$minutes',
                selected: workDuration.inMinutes == minutes,
                onTap: () => controller.setWorkDuration(Duration(minutes: minutes)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text('Mola Süresi (dk)', style: AppTypography.caption.copyWith(color: tokens.textSecondary)),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.sm,
          children: [
            for (final minutes in _breakPresets)
              AppChip(
                label: '$minutes',
                selected: breakDuration.inMinutes == minutes,
                onTap: () => controller.setBreakDuration(Duration(minutes: minutes)),
              ),
          ],
        ),
      ],
    );
  }
}

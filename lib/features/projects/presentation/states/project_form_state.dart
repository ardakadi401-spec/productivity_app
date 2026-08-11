import '../../../../core/errors/failure.dart';
import '../../domain/entities/project.dart';

/// Yeni Proje Bottom Sheet / düzenleme formunun ortak durumu
/// (SCREENS.md §6.3) — Tasks'ın `TaskFormState`'i ile aynı desen.
///
/// Varsayılan renk, `projectColorPalette`'in ilk öğesiyle aynı sabit hex
/// koddur (`const` kurucu parametresi list indeksleme kabul etmediğinden
/// burada literal olarak tekrarlanır).
class ProjectFormState {
  const ProjectFormState({
    this.color = '#FF8A8A',
    this.isSaving = false,
    this.error,
  });

  /// Hex kod — UI_GUIDELINES.md §3.3 pastel setinden seçilir.
  final String color;
  final bool isSaving;
  final Failure? error;

  factory ProjectFormState.fromProject(Project project) {
    return ProjectFormState(color: project.color);
  }

  ProjectFormState copyWith({String? color, bool? isSaving, Failure? error, bool clearError = false}) {
    return ProjectFormState(
      color: color ?? this.color,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

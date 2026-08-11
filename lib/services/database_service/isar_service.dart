import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/goals/data/models/goal_local_model.dart';
import '../../features/projects/data/models/project_local_model.dart';
import '../../features/tasks/data/models/sub_task_local_model.dart';
import '../../features/tasks/data/models/task_local_model.dart';

/// ARCHITECTURE.md Bölüm 6.2 "Service" katmanı — ham Isar SDK'sını sarmalar.
/// FOLDER_STRUCTURE.md'nin `core/storage/` için öngördüğü "tek paylaşılan
/// Isar örneği, merkezi başlatma" kuralı burada uygulanır; `core/storage/`
/// yalnızca bu tek örneğe erişim noktasıdır (bkz. `core/storage/isar_provider.dart`
/// henüz feature'a özel şema barındırmaz), şemaların kendisi (Task/SubTask)
/// ilgili feature'ın `data/models/` klasöründe yaşar.
///
/// Yeni bir feature yeni bir Isar koleksiyonu eklediğinde, şeması burada
/// `Isar.open` çağrısına eklenir — tüm uygulama için tek bir merkezi liste.
class IsarService {
  IsarService._();

  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      [TaskLocalModelSchema, SubTaskLocalModelSchema, ProjectLocalModelSchema, GoalLocalModelSchema],
      directory: dir.path,
    );
  }
}

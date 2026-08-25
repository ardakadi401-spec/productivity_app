import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/notes/presentation/utils/note_formatting_actions.dart';

/// `note_formatting_actions.dart` (SCREENS.md §4.19 biçimlendirme araç
/// çubuğu), ROADMAP.md FAZ 16 — coverage denetiminde %0 bulunan saf yardımcı
/// fonksiyonlar.
void main() {
  group('insertBoldMarker', () {
    test('seçili metin yoksa imleç konumuna **** ekler, imleç ortada kalır', () {
      final controller = TextEditingController(text: 'Merhaba dünya')
        ..selection = const TextSelection.collapsed(offset: 7);

      insertBoldMarker(controller);

      expect(controller.text, 'Merhaba**** dünya');
      expect(controller.selection.baseOffset, 9);
    });

    test('metin seçiliyse seçimi ** ** ile sarar, imleç sonuna gider', () {
      final controller = TextEditingController(text: 'Merhaba dünya')
        ..selection = const TextSelection(baseOffset: 0, extentOffset: 7);

      insertBoldMarker(controller);

      expect(controller.text, '**Merhaba** dünya');
      expect(controller.selection.baseOffset, 11);
    });

    test('seçim yoksa (-1) metnin sonuna eklenir', () {
      final controller = TextEditingController(text: 'Merhaba');

      insertBoldMarker(controller);

      expect(controller.text, 'Merhaba****');
    });
  });

  group('insertBulletMarker', () {
    test('boş metinde satır başına "- " ekler', () {
      final controller = TextEditingController(text: '')
        ..selection = const TextSelection.collapsed(offset: 0);

      insertBulletMarker(controller);

      expect(controller.text, '- ');
      expect(controller.selection.baseOffset, 2);
    });

    test('yeni satırın başına "- " ekler (önceki satırlar etkilenmez)', () {
      final controller = TextEditingController(text: 'İlk madde\n')
        ..selection = const TextSelection.collapsed(offset: 10);

      insertBulletMarker(controller);

      expect(controller.text, 'İlk madde\n- ');
    });

    test('satır zaten "- " ile başlıyorsa tekrar eklenmez', () {
      final controller = TextEditingController(text: '- Zaten madde')
        ..selection = const TextSelection.collapsed(offset: 13);

      insertBulletMarker(controller);

      expect(controller.text, '- Zaten madde');
    });
  });
}

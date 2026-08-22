import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/notes/domain/utils/note_formatting.dart';

void main() {
  test('düz metin, biçimlendirme işaretçisi yoksa tek span döner', () {
    final lines = parseSimpleNoteFormatting('merhaba dünya');

    expect(lines, hasLength(1));
    expect(lines.single.isBullet, isFalse);
    expect(lines.single.spans, hasLength(1));
    expect(lines.single.spans.single.text, 'merhaba dünya');
    expect(lines.single.spans.single.isBold, isFalse);
  });

  test('**kalın** işaretçisi kalın span üretir, işaretçiler metinden çıkarılır', () {
    final lines = parseSimpleNoteFormatting('bu **önemli** bir not');

    final spans = lines.single.spans;
    expect(spans.map((s) => s.text).join(), 'bu önemli bir not');
    expect(spans[0].isBold, isFalse);
    expect(spans[1].text, 'önemli');
    expect(spans[1].isBold, isTrue);
    expect(spans[2].isBold, isFalse);
  });

  test('bir satırda birden fazla kalın span doğru ayrıştırılır', () {
    final lines = parseSimpleNoteFormatting('**a** ve **b**');

    final boldTexts = lines.single.spans.where((s) => s.isBold).map((s) => s.text).toList();
    expect(boldTexts, ['a', 'b']);
  });

  test('satır başında "- " madde işaretini satırı bullet olarak işaretler, işaretçi metinden çıkar', () {
    final lines = parseSimpleNoteFormatting('- ilk madde');

    expect(lines.single.isBullet, isTrue);
    expect(lines.single.spans.single.text, 'ilk madde');
  });

  test('madde içinde kalın metin birlikte çalışır', () {
    final lines = parseSimpleNoteFormatting('- **önemli** madde');

    expect(lines.single.isBullet, isTrue);
    expect(lines.single.spans[0].text, 'önemli');
    expect(lines.single.spans[0].isBold, isTrue);
  });

  test('çok satırlı içerik satır satır ayrıştırılır, her satır bağımsız değerlendirilir', () {
    final lines = parseSimpleNoteFormatting('Başlık\n- madde 1\n- **kalın** madde 2\ndüz satır');

    expect(lines, hasLength(4));
    expect(lines[0].isBullet, isFalse);
    expect(lines[1].isBullet, isTrue);
    expect(lines[2].isBullet, isTrue);
    expect(lines[2].spans[0].isBold, isTrue);
    expect(lines[3].isBullet, isFalse);
  });

  test('boş içerik tek boş satır döner, hata fırlatmaz', () {
    final lines = parseSimpleNoteFormatting('');

    expect(lines, hasLength(1));
    expect(lines.single.spans.single.text, '');
  });

  test('kapanmayan ** işaretçisi düz metin olarak kalır (eşleşme yoksa değişmez)', () {
    final lines = parseSimpleNoteFormatting('bu **kapanmamış');

    expect(lines.single.spans.single.text, 'bu **kapanmamış');
    expect(lines.single.spans.single.isBold, isFalse);
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:productivity_app/features/search/presentation/controllers/recent_searches_controller.dart';

void main() {
  late ProviderContainer container;

  setUp(() => container = ProviderContainer());
  tearDown(() => container.dispose());

  test('addQuery en yeni aramayı başa ekler', () {
    final notifier = container.read(recentSearchesControllerProvider.notifier);
    notifier.addQuery('elma');
    notifier.addQuery('armut');

    expect(container.read(recentSearchesControllerProvider), ['armut', 'elma']);
  });

  test('aynı sorgu (büyük/küçük harf duyarsız) tekrar eklenirse yalnızca başa taşınır, çoğaltılmaz', () {
    final notifier = container.read(recentSearchesControllerProvider.notifier);
    notifier.addQuery('elma');
    notifier.addQuery('armut');
    notifier.addQuery('ELMA');

    expect(container.read(recentSearchesControllerProvider), ['ELMA', 'armut']);
  });

  test('boş/yalnızca boşluk sorgu eklenmez', () {
    final notifier = container.read(recentSearchesControllerProvider.notifier);
    notifier.addQuery('   ');

    expect(container.read(recentSearchesControllerProvider), isEmpty);
  });

  test('en fazla 10 kayıt tutulur, en eskiler düşer', () {
    final notifier = container.read(recentSearchesControllerProvider.notifier);
    for (var i = 0; i < 12; i++) {
      notifier.addQuery('sorgu$i');
    }

    final state = container.read(recentSearchesControllerProvider);
    expect(state, hasLength(10));
    expect(state.first, 'sorgu11');
    expect(state.contains('sorgu0'), isFalse);
    expect(state.contains('sorgu1'), isFalse);
  });

  test('removeQuery belirli bir aramayı listeden çıkarır', () {
    final notifier = container.read(recentSearchesControllerProvider.notifier);
    notifier.addQuery('elma');
    notifier.addQuery('armut');
    notifier.removeQuery('elma');

    expect(container.read(recentSearchesControllerProvider), ['armut']);
  });

  test('clear tüm geçmişi temizler', () {
    final notifier = container.read(recentSearchesControllerProvider.notifier);
    notifier.addQuery('elma');
    notifier.clear();

    expect(container.read(recentSearchesControllerProvider), isEmpty);
  });
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:productivity_app/core/network/connectivity_service.dart';

class _MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late _MockConnectivityService service;
  late ProviderContainer container;

  setUp(() {
    service = _MockConnectivityService();
    container = ProviderContainer(
      overrides: [connectivityServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
  });

  group('connectivityStatusProvider', () {
    test('online durumunda ilk değer true yayınlanır', () async {
      when(() => service.isConnected).thenAnswer((_) async => true);
      when(() => service.onStatusChange).thenAnswer((_) => const Stream.empty());

      final first = await container.read(connectivityStatusProvider.future);

      expect(first, isTrue);
    });

    test('offline durumunda ilk değer false yayınlanır', () async {
      when(() => service.isConnected).thenAnswer((_) async => false);
      when(() => service.onStatusChange).thenAnswer((_) => const Stream.empty());

      final first = await container.read(connectivityStatusProvider.future);

      expect(first, isFalse);
    });

    test('durum değişimi (offline → online) sırayla yayınlanır', () async {
      when(() => service.isConnected).thenAnswer((_) async => false);
      when(() => service.onStatusChange).thenAnswer((_) => Stream.fromIterable([true]));

      final values = <bool>[];
      final completer = Completer<void>();
      final sub = container.listen<AsyncValue<bool>>(
        connectivityStatusProvider,
        (previous, next) {
          next.whenData((value) {
            values.add(value);
            if (values.length == 2) completer.complete();
          });
        },
        fireImmediately: true,
      );
      addTearDown(sub.close);

      await completer.future.timeout(const Duration(seconds: 2));

      expect(values, [false, true]);
    });

    test('bağlantı servisi hata fırlatırsa AsyncError yayınlanır', () async {
      when(() => service.isConnected).thenThrow(Exception('platform hatası'));

      final result = await container.read(connectivityStatusProvider.future).then(
            (v) => AsyncValue.data(v),
            onError: (Object e, StackTrace st) => AsyncValue<bool>.error(e, st),
          );

      expect(result, isA<AsyncError<bool>>());
    });
  });
}

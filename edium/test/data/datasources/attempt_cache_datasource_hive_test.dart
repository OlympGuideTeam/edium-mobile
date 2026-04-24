import 'dart:io';

import 'package:edium/data/datasources/attempt_cache/attempt_cache_datasource_hive.dart';
import 'package:edium/data/models/attempt_cache_entry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

late Directory _tmp;

void main() {
  setUp(() async {
    _tmp = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(_tmp.path);
  });
  tearDown(() async {
    await Hive.deleteFromDisk();
    await Hive.close();
    if (_tmp.existsSync()) _tmp.deleteSync(recursive: true);
  });

  Future<AttemptCacheDatasourceHive> newDs() async {
    final box = await Hive.openBox<String>('attempt_cache_test');
    return AttemptCacheDatasourceHive(box: box);
  }

  test('write → read возвращает entry', () async {
    final ds = await newDs();
    final entry = AttemptCacheEntry(
      sessionId: 's1',
      attemptId: 'a1',
      questions: const [],
      answers: const {},
      startedAt: DateTime.utc(2026, 4, 22),
    );
    await ds.write(entry);
    final out = await ds.read('s1');
    expect(out, isNotNull);
    expect(out!.attemptId, 'a1');
  });

  test('read несуществующего ключа возвращает null', () async {
    final ds = await newDs();
    expect(await ds.read('unknown'), isNull);
  });

  test('delete удаляет', () async {
    final ds = await newDs();
    await ds.write(AttemptCacheEntry(
      sessionId: 's1',
      attemptId: 'a1',
      questions: const [],
      answers: const {},
      startedAt: DateTime.utc(2026, 4, 22),
    ));
    await ds.delete('s1');
    expect(await ds.read('s1'), isNull);
  });

  test('gcExpired удаляет просроченные', () async {
    final ds = await newDs();
    await ds.write(AttemptCacheEntry(
      sessionId: 'expired',
      attemptId: 'a',
      questions: const [],
      answers: const {},
      startedAt: DateTime.utc(2026, 1, 1),
      expiresAt: DateTime.utc(2026, 1, 2),
    ));
    await ds.write(AttemptCacheEntry(
      sessionId: 'fresh',
      attemptId: 'a',
      questions: const [],
      answers: const {},
      startedAt: DateTime.utc(2026, 4, 22),
      expiresAt: DateTime.utc(2030, 1, 1),
    ));
    await ds.gcExpired(now: DateTime.utc(2026, 4, 22));
    expect(await ds.read('expired'), isNull);
    expect(await ds.read('fresh'), isNotNull);
  });
}

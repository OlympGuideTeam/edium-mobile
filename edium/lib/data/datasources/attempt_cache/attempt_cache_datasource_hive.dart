import 'package:edium/core/storage/hive_storage.dart';
import 'package:edium/data/datasources/attempt_cache/attempt_cache_datasource.dart';
import 'package:edium/data/models/attempt_cache_entry.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AttemptCacheDatasourceHive implements IAttemptCacheDatasource {
  AttemptCacheDatasourceHive({Box<String>? box})
      : _box = box ?? HiveStorage.attemptCacheBox;

  final Box<String> _box;

  @override
  Future<AttemptCacheEntry?> read(String sessionId) async {
    final raw = _box.get(sessionId);
    if (raw == null) return null;
    try {
      return AttemptCacheEntry.decode(raw);
    } catch (_) {
      await _box.delete(sessionId);
      return null;
    }
  }

  @override
  Future<void> write(AttemptCacheEntry entry) async {
    await _box.put(entry.sessionId, entry.encode());
  }

  @override
  Future<void> delete(String sessionId) async {
    await _box.delete(sessionId);
  }

  @override
  Future<void> gcExpired({DateTime? now}) async {
    final ts = now ?? DateTime.now();
    final toDelete = <String>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw == null) continue;
      try {
        final entry = AttemptCacheEntry.decode(raw);
        if (entry.isExpired(ts)) toDelete.add(entry.sessionId);
      } catch (_) {
        toDelete.add(key as String);
      }
    }
    for (final k in toDelete) {
      await _box.delete(k);
    }
  }
}

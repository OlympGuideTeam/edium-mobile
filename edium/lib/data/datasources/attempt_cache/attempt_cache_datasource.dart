import 'package:edium/data/models/attempt_cache_entry.dart';

abstract class IAttemptCacheDatasource {
  Future<AttemptCacheEntry?> read(String sessionId);
  Future<void> write(AttemptCacheEntry entry);
  Future<void> delete(String sessionId);
  Future<void> gcExpired({DateTime? now});
}

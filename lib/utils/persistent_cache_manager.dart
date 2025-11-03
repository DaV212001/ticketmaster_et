import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Custom cache manager that persists images across app restarts
/// 
/// This cache manager:
/// - Stores cached files in a persistent directory (automatically handled by flutter_cache_manager)
/// - Keeps images cached for 30 days by default
/// - Maintains a maximum of 1000 cached objects
/// - Uses a JSON-based cache info repository to track cache entries
/// - Persists across app restarts using the application's cache directory
class PersistentImageCacheManager extends CacheManager {
  /// Unique cache key to identify this cache manager
  static const String _key = 'persistentImageCache';
  
  /// Singleton instance
  static PersistentImageCacheManager? _instance;
  
  /// Get the singleton instance of the persistent cache manager
  factory PersistentImageCacheManager() {
    _instance ??= PersistentImageCacheManager._internal();
    return _instance!;
  }
  
  /// Private constructor to ensure singleton pattern
  PersistentImageCacheManager._internal()
      : super(
          Config(
            _key,
            // Cache files remain valid for 30 days
            stalePeriod: const Duration(days: 30),
            // Maximum number of cached files
            maxNrOfCacheObjects: 1000,
            // Use JSON-based cache info repository with a custom database name
            // This ensures cache metadata persists across app restarts
            repo: JsonCacheInfoRepository(
              databaseName: '${_key}_cache_info.db',
            ),
            // Use default file service for HTTP requests
            fileService: HttpFileService(),
            // Use default IO file system which automatically handles
            // persistent storage in the app's cache directory
            // The cache will persist across app restarts automatically
          ),
        );
}


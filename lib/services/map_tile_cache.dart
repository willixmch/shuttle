import 'package:path_provider/path_provider.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:http_cache_file_store/http_cache_file_store.dart';

class MapTileCache {
  static Future<CachedTileProvider> initializeTileCaching() async {
    // Get cache directory
    final cacheDir = await getTemporaryDirectory();
    // Initialize FileCacheStore
    final cacheStore = FileCacheStore(cacheDir.path);
    // Set up CachedTileProvider
    return CachedTileProvider(
      store: cacheStore,
      maxStale: const Duration(days: 30), // Cache tiles for 30 days
    );
  }
}
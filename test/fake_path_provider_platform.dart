import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Fake path provider for use in tests.
class FakePathProviderPlatform extends PathProviderPlatform {
  /// Creates a temporary directory and registers it for use by the path
  /// provider plugin.
  static Future<FakePathProviderPlatform> create() async {
    final instance =
        FakePathProviderPlatform._(await Directory.systemTemp.createTemp());
    PathProviderPlatform.instance = instance;
    return instance;
  }

  Directory _tempDir;

  FakePathProviderPlatform._(this._tempDir);

  /// Deletes all of the contents of the temporary directory.
  Future<void> cleanup() async {
    await _tempDir.delete(recursive: true);
  }

  @override
  Future<String?> getTemporaryPath() async {
    return p.join(_tempDir.path, 'temporary');
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return p.join(_tempDir.path, 'applicationSupport');
  }

  @override
  Future<String?> getLibraryPath() async {
    return p.join(_tempDir.path, 'library');
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return p.join(_tempDir.path, 'applicationDocuments');
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return p.join(_tempDir.path, 'externalStorage');
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>[p.join(_tempDir.path, 'externalCache')];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[p.join(_tempDir.path, 'externalStorage')];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return p.join(_tempDir.path, 'downloads');
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'log.dart';

final _log = Log.get('AlbumArt');

// Loads album art for use in the app.
// Usage:
// Initialization:
//   AlbumArt.load();
// To get the URI:
//   String uri = AlbumArt.getUri();
//
// There are some subtleties here, particularly when the image is referenced
// from multiple isolates. We do our best to atomically copy the art from assets
// to the file system, even if multiple isolates start that process in parallel.
// This ends up being an at-least-once scenario: the second isolate might
// overwrite the file, but the file contents are still handled atomically.
class AlbumArt {
  static final _base = 'A'.codeUnitAt(0);
  static const _asset = 'assets/web_hi_res_512.jpg';
  static final _rand = Random.secure();
  static Uri? _uri;
  static bool _loading = false;

  /// Return a file:// url to the album art for the app. Returns null if the
  /// art is not yet available.
  static Uri? getUri() {
    if (_uri != null) {
      return _uri;
    }
    if (!_loading) {
      _loading = true;
      Timer.run(load);
    }
    return null;
  }

  /// Starts album art loading, if it hasn't happened already.
  static Future<void> load() async {
    if (_uri != null) {
      return;
    }
    _log.info('Starting art load');
    final String cacheDir = (await getTemporaryDirectory()).path;
    final File cache = File('$cacheDir/album_art.jpg');
    if (cache.existsSync()) {
      // Previous isolate already did the work.
      _log.info('Cache file found, reusing.');
      _uri = Uri.file(cache.path);
      return;
    }
    final File tmpFile = File('$cacheDir/${_randomString()}.jpg');
    _log.info('Extracting from assets to ${tmpFile.path}');
    final ByteData bytes = await rootBundle.load(_asset);
    tmpFile.writeAsBytesSync(bytes.buffer.asInt8List());
    tmpFile.renameSync(cache.path);
    _log.info('Created ${cache.path}');
    _uri = Uri.file(cache.path);
  }

  // Returns a random string with about 94 bits of entropy that is suitable for
  // use in a file system.
  static String _randomString() {
    final chars = List.generate(20, (index) => _base + _rand.nextInt(26));
    return String.fromCharCodes(chars);
  }
}

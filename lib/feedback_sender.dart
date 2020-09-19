import 'dart:core';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:mailto/mailto.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

import 'log.dart';

final _log = Log.get('FeedbackSender');

class FeedbackSender {
  static final _deviceInfo = DeviceInfoPlugin();
  static final Future<String> _device = _loadDevice();
  static final Future<String> _version = _loadVersion();

  // Send feedback via e-mail. Would be nice to figure out how to do this with
  // the screenshot attachment, but this is fine for now.
  void send() async {
    final String version = await _version;
    final String device = await _device;
    final String body = '''*** Please add suggestions here ***.
      
Version: $version
Device:
$device
''';
    final Mailto mailto = Mailto(
        to: ['foostrainer@gmail.com'],
        subject: 'Feedback on FoosTrainer',
        body: body);
    launch('$mailto');
    _log.info('Feedback data: $body');
  }

  static Future<String> _loadDevice() async {
    Map<String, String> deviceData = {};
    deviceData['os'] = Platform.operatingSystem;
    deviceData['os.version'] = Platform.operatingSystemVersion;
    deviceData['os.locale'] = Platform.localeName;
    deviceData['dart.version'] = Platform.version;
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo android = await _deviceInfo.androidInfo;
        deviceData['brand'] = android.brand;
        deviceData['device'] = android.device;
        deviceData['manufacturer'] = android.manufacturer;
        deviceData['model'] = android.model;
        deviceData['product'] = android.product;
      } else if (Platform.isIOS) {
        final IosDeviceInfo ios = await _deviceInfo.iosInfo;
        deviceData['model'] = ios.model;
        deviceData['name'] = ios.name;
        deviceData['system name'] = ios.systemName;
        deviceData['system version'] = ios.systemVersion;
      }
    } catch (e) {
      deviceData['error'] = e.toString();
    }
    String out = '';
    for (MapEntry<String, String> entry in deviceData.entries) {
      out += '  ${entry.key}: ${entry.value}\n';
    }
    return out;
  }

  static Future<String> _loadVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return '${packageInfo.appName} ${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (e) {
      _log.warning('Failed to load package info: $e');
      return '$e';
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'idsoberana_plugin_platform_interface.dart';

/// An implementation of [IdsoberanaPluginPlatform] that uses method channels.
class MethodChannelIdsoberanaPlugin extends IdsoberanaPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('idsoberana_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<String?> getTest() async {
    final version = await methodChannel.invokeMethod<String>('getTest');
    return version;
  }
}

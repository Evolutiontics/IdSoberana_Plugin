import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'idsoberana_plugin_method_channel.dart';

abstract class IdsoberanaPluginPlatform extends PlatformInterface {
  /// Constructs a IdsoberanaPluginPlatform.
  IdsoberanaPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static IdsoberanaPluginPlatform _instance = MethodChannelIdsoberanaPlugin();

  /// The default instance of [IdsoberanaPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelIdsoberanaPlugin].
  static IdsoberanaPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IdsoberanaPluginPlatform] when
  /// they register themselves.
  static set instance(IdsoberanaPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<String?> getTest(){
    throw UnimplementedError('Error test.');
  }
}

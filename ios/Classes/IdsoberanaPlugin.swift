import Flutter
import UIKit

public class IdsoberanaPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "idsoberana_plugin", binaryMessenger: registrar.messenger())
    let instance = IdsoberanaPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "getTest":
      result("Test iOS")
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

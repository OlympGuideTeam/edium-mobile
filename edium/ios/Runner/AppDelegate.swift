import Flutter
import UIKit
import FirebaseCore
import UserNotifications

/// UIScene: тап по FCM при killed state приходит в `SceneDelegate.connectionOptions`,
/// а не в `launchOptions[.remoteNotification]` — из‑за этого в Dart `getInitialMessage()` null.
/// Достаём `data` (`route`, `role`, …) из `userInfo` и отдаём в Dart через MethodChannel.
extension AppDelegate {
  private static var pendingLaunchNotification: [String: String]?
  private static var launchNotificationChannelRegistered = false

  private static func mergeAnyMap(
    from any: Any,
    into map: inout [String: String]
  ) {
    guard let dict = any as? [AnyHashable: Any] else { return }
    for (k, v) in dict {
      let key = String(describing: k)
      if let s = v as? String {
        map[key] = s
      } else if let nested = v as? [AnyHashable: Any] {
        mergeAnyMap(from: nested, into: &map)
      } else {
        map[key] = String(describing: v)
      }
    }
  }

  private static func parseDataJsonIfNeeded(
    _ dataValue: Any?,
    into map: inout [String: String]
  ) {
    guard let str = dataValue as? String,
          let json = str.data(using: .utf8),
          let obj = try? JSONSerialization.jsonObject(with: json) as? [String: Any]
    else { return }
    for (k, v) in obj {
      map[k] = String(describing: v)
    }
  }

  private static func string(from userInfo: [AnyHashable: Any], key: String) -> String? {
    guard let v = userInfo[key] else { return nil }
    if let s = v as? String { return s }
    return String(describing: v)
  }

  /// Вызывать из `AppDelegate` (старый путь) и из `SceneDelegate` (основной путь UIScene).
  static func mergeLaunchNotificationUserInfo(_ userInfo: [AnyHashable: Any]) {
    var map: [String: String] = [:]
    mergeAnyMap(from: userInfo, into: &map)
    parseDataJsonIfNeeded(userInfo["data"], into: &map)

    let route = map["route"] ??
        map["deep_link"] ??
        map["link"] ??
        map["gcm.notification.route"]
    guard let route, !route.isEmpty else {
      print("[Notif][iOS] launch userInfo without route keys=\(Array(map.keys))")
      return
    }
    map["route"] = route

    if let role = map["role"], !role.isEmpty {
      map["role"] = role
    } else if let role = map["gcm.notification.role"], !role.isEmpty {
      map["role"] = role
    }

    if let mid = string(from: userInfo, key: "gcm.message_id"), !mid.isEmpty {
      map["messageId"] = mid
    } else if let mid = string(from: userInfo, key: "google.message_id"), !mid.isEmpty {
      map["messageId"] = mid
    }

    print("[Notif][iOS] captured launch route=\(route) role=\(map["role"] ?? "nil")")
    pendingLaunchNotification = map
  }

  // ─── Badge channel ───────────────────────────────────────────────────────

  private static var badgeChannelRegistered = false

  static func registerBadgeChannelIfNeeded(attempt: Int = 0) {
    if badgeChannelRegistered { return }
    if attempt > 200 { return }

    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let root = scene.windows.first?.rootViewController as? FlutterViewController else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        registerBadgeChannelIfNeeded(attempt: attempt + 1)
      }
      return
    }

    badgeChannelRegistered = true
    let channel = FlutterMethodChannel(
      name: "edium/badge",
      binaryMessenger: root.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "setBadgeCount", let count = call.arguments as? Int else {
        result(FlutterMethodNotImplemented); return
      }
      if #available(iOS 16.0, *) {
        UNUserNotificationCenter.current().setBadgeCount(count) { _ in }
      } else {
        UIApplication.shared.applicationIconBadgeNumber = count
      }
      result(nil)
    }
  }

  /// Регистрация после появления `FlutterViewController` в активной сцене (совместимо с UIScene).
  static func registerLaunchNotificationChannelIfNeeded(attempt: Int = 0) {
    if launchNotificationChannelRegistered { return }
    if attempt > 200 { return }

    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let root = scene.windows.first?.rootViewController as? FlutterViewController else {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
        registerLaunchNotificationChannelIfNeeded(attempt: attempt + 1)
      }
      return
    }

    launchNotificationChannelRegistered = true
    let channel = FlutterMethodChannel(
      name: "edium/launch_notification",
      binaryMessenger: root.binaryMessenger
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "consumePendingLaunchNotification" {
        let payload = pendingLaunchNotification
        pendingLaunchNotification = nil
        result(payload)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    if let remote = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
      Self.mergeLaunchNotificationUserInfo(remote)
    }
    GeneratedPluginRegistrant.register(with: self)
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    DispatchQueue.main.async {
      Self.registerLaunchNotificationChannelIfNeeded()
      Self.registerBadgeChannelIfNeeded()
    }
    return ok
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    Self.mergeLaunchNotificationUserInfo(response.notification.request.content.userInfo)
    super.userNotificationCenter(
      center,
      didReceive: response,
      withCompletionHandler: completionHandler
    )
  }
}

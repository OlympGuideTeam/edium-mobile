import Flutter
import UIKit

@objc(SceneDelegate)
class SceneDelegate: FlutterSceneDelegate {

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    // До `super`: `pendingLaunchNotification` уже нужен, когда AppDelegate
    // асинхронно регистрирует MethodChannel после появления root VC.
    if let response = connectionOptions.notificationResponse {
      let userInfo = response.notification.request.content.userInfo
      AppDelegate.mergeLaunchNotificationUserInfo(userInfo)
    }
    super.scene(scene, willConnectTo: session, options: connectionOptions)
  }
}

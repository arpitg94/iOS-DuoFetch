import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var hummingbirdServer: HummingbirdServer?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        hummingbirdServer = HummingbirdServer()
        hummingbirdServer?.start()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {
        hummingbirdServer?.stop()
    }
}

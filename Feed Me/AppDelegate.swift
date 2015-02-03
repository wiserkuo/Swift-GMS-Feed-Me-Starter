import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  // 1
  let googleMapsApiKey = "AIzaSyAEW1RRN2ptWGvXGvDZ-kkk_3FNoYgKBhI"
  
  func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
    // 2
    GMSServices.provideAPIKey(googleMapsApiKey)
    return true
  }
}
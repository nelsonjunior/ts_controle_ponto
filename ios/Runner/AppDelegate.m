#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <flutter_local_notifications/FlutterLocalNotificationsPlugin.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    int flutter_native_splash = 1;
    UIApplication.sharedApplication.statusBarHidden = false;

  [GeneratedPluginRegistrant registerWithRegistry:self];
  // cancel old notifications that were scheduled to be periodically shown upon a reinstallation of the app
  if(![[NSUserDefaults standardUserDefaults]objectForKey:@"Notification"]){
      [[UIApplication sharedApplication] cancelAllLocalNotifications];
      [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"Notification"];
  }
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
//
//  AppDelegate.m
//  OpenGL ES_Study
//
//  Created by whatever on 2020/5/19.
//  Copyright © 2020 whatever. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    UINavigationController *navVc = [[UINavigationController alloc] initWithRootViewController:[[MainViewController alloc]init]];
    self.window.rootViewController = navVc;
    [self.window makeKeyAndVisible];
    return YES;
}


@end

//
//  AppDelegate.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/14.
//  Copyright © 2018年 GHome. All rights reserved.
//  gitHub:https://github.com/shabake/GHDropMenuDemo

#import "AppDelegate.h"
#import "ViewController.h"
#import "GHDropMenuDemo-Swift.h"

@interface AppDelegate ()

/// 由 Scheme → Run → Environment Variables 中的 GH_ROOT_DEMO 控制：objc | swift | both（默认 objc，真机/归档无变量时亦为 objc）
- (UIViewController *)gh_makeRootViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UIWindow *window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];

    /** 如果发现项目打开空白,请把Target切换成GHDropMenuDemo后,编译 */
    window.rootViewController = [self gh_makeRootViewController];

    [self configureNavigationBar];

    self.window = window;
    [window makeKeyAndVisible];
    return YES;
}

- (UIViewController *)gh_makeRootViewController {
    NSString *raw = [NSProcessInfo processInfo].environment[@"GH_ROOT_DEMO"];
    NSString *flavor = raw.length ? raw.lowercaseString : @"objc";

    if ([flavor isEqualToString:@"swift"]) {
        SwiftDemoListViewController *swiftRoot = [[SwiftDemoListViewController alloc] init];
        return [[UINavigationController alloc] initWithRootViewController:swiftRoot];
    }
    if ([flavor isEqualToString:@"both"] || [flavor isEqualToString:@"tab"]) {
        ViewController *objcRoot = [[ViewController alloc] init];
        UINavigationController *navObjc = [[UINavigationController alloc] initWithRootViewController:objcRoot];
        navObjc.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Objective-C" image:nil tag:0];

        SwiftDemoListViewController *swiftRoot = [[SwiftDemoListViewController alloc] init];
        UINavigationController *navSwift = [[UINavigationController alloc] initWithRootViewController:swiftRoot];
        navSwift.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Swift" image:nil tag:1];

        UITabBarController *tab = [[UITabBarController alloc] init];
        tab.viewControllers = @[navObjc, navSwift];
        return tab;
    }
    // objc（含 GH_ROOT_DEMO=objc 或未设置）
    ViewController *objcRoot = [[ViewController alloc] init];
    return [[UINavigationController alloc] initWithRootViewController:objcRoot];
}

- (void)configureNavigationBar {
    UINavigationBar *navBar = [UINavigationBar appearance];
    navBar.tintColor = [UIColor blueColor];
    UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor whiteColor];
    appearance.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    appearance.shadowColor = [UIColor clearColor];
    navBar.standardAppearance = appearance;
    navBar.scrollEdgeAppearance = appearance;
    navBar.compactAppearance = appearance;
    if (@available(iOS 15.0, *)) {
        navBar.compactScrollEdgeAppearance = appearance;
    }
    UIBarButtonItem *barButtonItem = [UIBarButtonItem appearance];
    [barButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor blueColor]} forState:UIControlStateNormal];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

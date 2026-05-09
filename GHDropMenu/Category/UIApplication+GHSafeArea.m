//
//  UIApplication+GHSafeArea.m
//  GHDropMenuDemo
//

#import "UIApplication+GHSafeArea.h"

@implementation UIApplication (GHSafeArea)

+ (nullable UIWindow *)gh_keyWindow {
    UIApplication *app = [UIApplication sharedApplication];
    for (UIScene *scene in app.connectedScenes) {
        if (scene.activationState != UISceneActivationStateForegroundActive) {
            continue;
        }
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        for (UIWindow *window in windowScene.windows) {
            if (window.isKeyWindow) {
                return window;
            }
        }
    }
    for (UIScene *scene in app.connectedScenes) {
        if (![scene isKindOfClass:[UIWindowScene class]]) {
            continue;
        }
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        for (UIWindow *window in windowScene.windows) {
            if (!window.isHidden && window.alpha > 0.01) {
                return window;
            }
        }
    }
    for (UIWindow *window in app.windows) {
        if (!window.isHidden && window.alpha > 0.01) {
            return window;
        }
    }
    return app.windows.firstObject;
}

+ (CGRect)gh_keyWindowBounds {
    UIWindow *window = [self gh_keyWindow];
    if (window) {
        return window.bounds;
    }
    return [UIScreen mainScreen].bounds;
}

+ (UIEdgeInsets)gh_safeAreaInsets {
    UIWindow *window = [self gh_keyWindow];
    if (!window) {
        return UIEdgeInsetsZero;
    }
    return window.safeAreaInsets;
}

@end

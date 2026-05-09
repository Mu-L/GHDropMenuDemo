//
//  UIApplication+GHSafeArea.h
//  GHDropMenuDemo
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (GHSafeArea)

/// 当前前台场景下的主窗口；兼容 iOS 13+ 多 Scene，避免 keyWindow 为 nil。
+ (nullable UIWindow *)gh_keyWindow;

/// 与 gh_keyWindow 对应的 bounds，无窗口时退回主屏 bounds。
+ (CGRect)gh_keyWindowBounds;

/// 主窗口的安全区；无窗口时为 UIEdgeInsetsZero。
+ (UIEdgeInsets)gh_safeAreaInsets;

@end

NS_ASSUME_NONNULL_END

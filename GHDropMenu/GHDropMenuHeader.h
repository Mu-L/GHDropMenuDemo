//
//  GHDropMenuHeader.h
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/15.
//  Copyright © 2018年 GHome. All rights reserved.
//  gitHub:https://github.com/shabake/GHDropMenuDemo

#ifndef GHDropMenuHeader_h
#define GHDropMenuHeader_h
#import "UIApplication+GHSafeArea.h"
#define weakself(self)  __weak __typeof(self) weakSelf = self

// ScreenWidth & kScreenHeight
#define kGHScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kGHScreenHeight [UIScreen mainScreen].bounds.size.height

#define iPhoneXRAndXSMAX (kGHScreenWidth == 414.f && kGHScreenHeight == 896.f ? YES : NO)
// iPhoneX
#define iPhoneXAndXS (kGHScreenWidth == 375.f && kGHScreenHeight == 812.f ? YES : NO)
#define kGHSafeAreaBottomHeight ([UIApplication gh_safeAreaInsets].bottom)
// StatusbarH + NavigationH
#define kGHSafeAreaTopHeight ([UIApplication gh_safeAreaInsets].top + 44.f)
// StatusBarHeight
#define kStatusBarHeight ([UIApplication gh_safeAreaInsets].top)
// NavigationBarHeigth
#define kNavBarHeight 44.f
// TabBarHeight
#define kTabBarHeight  (49.f + [UIApplication gh_safeAreaInsets].bottom)

// KeyWindow（iOS 13+ Scene 下 keyWindow 可能为 nil，使用分类方法）
#define kKeyWindow [UIApplication gh_keyWindow]
#define kGHKeyWindowBounds [UIApplication gh_keyWindowBounds]

// Rete
#define kScreenWidthRete   kScreenWidth / 375.0 //比率
#define kScreenHeightRete  kScreenWidth / 667.0 //比率
// AutoSize
#define kAutoWithSize(r) r*kScreenWidth / 375.0
#define kFont(size) kAutoWithSize(size)

#define kAutoHeightSize(r) r*kScreenHeight / 667.0

#define kFilterButtonHeight 44
#define kFilterButtonWidth 44

#import "UIView+Extension.h"

#endif /* GHDropMenuHeader_h */

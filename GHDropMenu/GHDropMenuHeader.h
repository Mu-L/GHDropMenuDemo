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

#pragma mark - GH 主题色（清新蓝紫）
/** 主色 */
#define kGHThemeAccentColor        [UIColor colorWithRed:99.0/255  green:102.0/255 blue:241.0/255 alpha:1]   // #6366F1
/** 主色（深） */
#define kGHThemeAccentDarkColor    [UIColor colorWithRed:79.0/255  green:70.0/255  blue:229.0/255 alpha:1]   // #4F46E5
/** 主色（浅底） */
#define kGHThemeAccentSoftColor    [UIColor colorWithRed:238.0/255 green:240.0/255 blue:255.0/255 alpha:1]   // #EEF0FF
/** 页面背景 */
#define kGHThemeBackgroundColor    [UIColor colorWithRed:245.0/255 green:246.0/255 blue:250.0/255 alpha:1]   // #F5F6FA
/** 主文字 */
#define kGHThemeTextColor          [UIColor colorWithRed:31.0/255  green:35.0/255  blue:51.0/255  alpha:1]   // #1F2333
/** 次级文字 */
#define kGHThemeSubTextColor       [UIColor colorWithRed:138.0/255 green:144.0/255 blue:166.0/255 alpha:1]   // #8A90A6
/** 分割线 */
#define kGHThemeLineColor          [UIColor colorWithRed:236.0/255 green:237.0/255 blue:243.0/255 alpha:1]   // #ECEDF3

#import "UIView+Extension.h"

#endif /* GHDropMenuHeader_h */

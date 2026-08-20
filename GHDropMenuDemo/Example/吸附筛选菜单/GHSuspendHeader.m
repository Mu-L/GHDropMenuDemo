//
//  GHSuspendHeader.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/29.
//  Copyright © 2018年 GHome. All rights reserved.
//

#import "GHSuspendHeader.h"
#import "GHDropMenuHeader.h"
#import <QuartzCore/QuartzCore.h>

@implementation GHSuspendHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        self.backgroundColor = kGHThemeAccentColor;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.colors = @[(id)kGHThemeAccentColor.CGColor, (id)kGHThemeAccentDarkColor.CGColor];
        gradient.startPoint = CGPointMake(0, 0);
        gradient.endPoint = CGPointMake(1, 1);
        [self.layer insertSublayer:gradient atIndex:0];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = self.bounds;
        }
    }
}

- (void)changeY:(CGFloat)y {
    self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
}
@end

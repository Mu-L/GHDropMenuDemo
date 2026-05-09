//
//  GHMeituanFoodViewController.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/31.
//  Copyright © 2018年 GHome. All rights reserved.
//

#import "GHMeituanFoodViewController.h"

@interface GHMeituanFoodViewController ()
@property (nonatomic, strong) UILabel *hintLabel;
@end

@implementation GHMeituanFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.view.bounds, 24, 120)];
    self.hintLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.hintLabel.numberOfLines = 0;
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.textColor = [UIColor darkGrayColor];
    self.hintLabel.font = [UIFont systemFontOfSize:15];
    self.hintLabel.text = @"「流水菜单 / 美团外卖」示例页占位。\n可在此接入 GHDropMenu 瀑布流等数据源。";
    [self.view addSubview:self.hintLabel];
}

@end

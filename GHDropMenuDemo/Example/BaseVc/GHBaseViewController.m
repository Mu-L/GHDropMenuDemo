//
//  GHBaseViewController.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/29.
//  Copyright © 2018年 GHome. All rights reserved.
//

#import "GHBaseViewController.h"
#import "GHDropMenuHeader.h"

@interface GHBaseViewController ()

@end

@implementation GHBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = self.navTitle;
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;

    self.view.backgroundColor = kGHThemeBackgroundColor;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];

}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

//
//  ViewController.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/14.
//  Copyright © 2018年 GHome. All rights reserved.
//  gitHub:https://github.com/shabake/GHDropMenuDemo

#import "ViewController.h"
#import "GHBaseViewController.h"
#import "GHDropMenuHeader.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
/// 每项: title / subtitle / vcClass(NSString, 用于 NSClassFromString)
@property (nonatomic, copy) NSArray<NSDictionary *> *demoItems;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"示例（Objective-C）";
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeAlways;
    self.view.backgroundColor = kGHThemeBackgroundColor;

    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    UILayoutGuide *g = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:g.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];

    UILabel *intro = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 52)];
    intro.text = @"下拉、侧滑、标签、瀑布流筛选菜单演示";
    intro.font = [UIFont systemFontOfSize:13];
    intro.textColor = kGHThemeSubTextColor;
    intro.textAlignment = NSTextAlignmentCenter;
    self.tableView.tableHeaderView = intro;
}

#pragma mark - Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.demoItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"GHDemoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    NSDictionary *item = self.demoItems[indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", item[@"icon"], item[@"title"]];
    cell.textLabel.textColor = kGHThemeTextColor;
    cell.textLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    cell.detailTextLabel.text = item[@"subtitle"];
    cell.detailTextLabel.textColor = kGHThemeSubTextColor;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.numberOfLines = 0;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *item = self.demoItems[indexPath.row];
    NSString *name = item[@"vcClass"];
    Class cls = NSClassFromString(name);
    if (!cls || ![cls isSubclassOfClass:[GHBaseViewController class]]) {
        return;
    }
    GHBaseViewController *vc = [[cls alloc] init];
    vc.navTitle = item[@"title"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleInsetGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 72;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSArray<NSDictionary *> *)demoItems {
    if (!_demoItems) {
        _demoItems = @[
            @{ @"icon": @"🧩",
               @"title": @"复杂筛选菜单",
               @"subtitle": @"标题栏 + 下拉列表 + 右侧复杂筛选；数据用 GHDropMenuModel 拼好即可。",
               @"vcClass": @"GHComplexMenuViewController" },
            @{ @"icon": @"🎚️",
               @"title": @"侧滑筛选菜单",
               @"subtitle": @"只有全屏侧滑筛选：点导航栏「筛选」出现；必须先 addSubview 再 show。",
               @"vcClass": @"GHSlipMenuViewController" },
            @{ @"icon": @"📋",
               @"title": @"普通筛选菜单",
               @"subtitle": @"标题栏下拉；列标题和内容自己实现数据源协议 columnTitlesInMeun / menu:numberOfColumns:。",
               @"vcClass": @"GHNormalMenuViewController" },
            @{ @"icon": @"📌",
               @"title": @"悬浮筛选（TableView）",
               @"subtitle": @"列表吸顶头里放 GHDropMenu，适合长列表里筛选。",
               @"vcClass": @"GHSuspendViewController" },
            @{ @"icon": @"🍔",
               @"title": @"瀑布流 / 美团样式",
               @"subtitle": @"多列标签瀑布流筛选示例（界面参考外卖类 App）。",
               @"vcClass": @"GHMeituanFoodViewController" },
        ];
    }
    return _demoItems;
}

@end

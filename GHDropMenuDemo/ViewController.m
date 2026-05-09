//
//  ViewController.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/14.
//  Copyright © 2018年 GHome. All rights reserved.
//  gitHub:https://github.com/shabake/GHDropMenuDemo

#import "ViewController.h"
#import "GHBaseViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
/// 每项: title / subtitle / vcClass(NSString, 用于 NSClassFromString)
@property (nonatomic, copy) NSArray<NSDictionary *> *demoItems;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"示例（Objective-C）";
    [self.view addSubview:self.tableView];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    UILayoutGuide *g = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:g.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
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
    cell.textLabel.text = item[@"title"];
    cell.detailTextLabel.text = item[@"subtitle"];
    cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
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
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 72;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSArray<NSDictionary *> *)demoItems {
    if (!_demoItems) {
        _demoItems = @[
            @{ @"title": @"复杂筛选菜单",
               @"subtitle": @"标题栏 + 下拉列表 + 右侧复杂筛选；数据用 GHDropMenuModel 拼好即可。",
               @"vcClass": @"GHComplexMenuViewController" },
            @{ @"title": @"侧滑筛选菜单",
               @"subtitle": @"只有全屏侧滑筛选：点导航栏「筛选」出现；必须先 addSubview 再 show。",
               @"vcClass": @"GHSlipMenuViewController" },
            @{ @"title": @"普通筛选菜单",
               @"subtitle": @"标题栏下拉；列标题和内容自己实现数据源协议 columnTitlesInMeun / menu:numberOfColumns:。",
               @"vcClass": @"GHNormalMenuViewController" },
            @{ @"title": @"悬浮筛选（TableView）",
               @"subtitle": @"列表吸顶头里放 GHDropMenu，适合长列表里筛选。",
               @"vcClass": @"GHSuspendViewController" },
            @{ @"title": @"瀑布流 / 美团样式",
               @"subtitle": @"多列标签瀑布流筛选示例（界面参考外卖类 App）。",
               @"vcClass": @"GHMeituanFoodViewController" },
        ];
    }
    return _demoItems;
}

@end

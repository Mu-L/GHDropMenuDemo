//
//  GHMeituanFoodViewController.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/31.
//  Copyright © 2018年 GHome. All rights reserved.
//

#import "GHMeituanFoodViewController.h"
#import "GHDropMenu.h"
#import "GHDropMenuModel.h"
#import "GHDropMenuHeader.h"

#pragma mark - 食物列表 Cell
@interface GHFoodCell : UITableViewCell
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *priceLabel;
@end

@implementation GHFoodCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
        _nameLabel.textColor = kGHThemeTextColor;
        [self.contentView addSubview:_nameLabel];

        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:13];
        _descLabel.textColor = kGHThemeSubTextColor;
        [self.contentView addSubview:_descLabel];

        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        _priceLabel.textColor = kGHThemeAccentColor;
        _priceLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_priceLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat w = self.contentView.bounds.size.width;
    CGFloat h = self.contentView.bounds.size.height;
    CGFloat pad = 16;
    CGFloat priceW = 80;
    self.priceLabel.frame = CGRectMake(w - pad - priceW, 0, priceW, h);
    self.nameLabel.frame = CGRectMake(pad, 14, w - pad * 2 - priceW, 22);
    self.descLabel.frame = CGRectMake(pad, 40, w - pad * 2 - priceW, 20);
}

@end

#pragma mark - 美团样式示例页
@interface GHMeituanFoodViewController () <GHDropMenuDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) GHDropMenu *dropMenu;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSDictionary *> *foods;
@end

@implementation GHMeituanFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupDropMenu];
    [self setupTableView];
}

- (void)back {
    [self.dropMenu closeMenu];
    [super back];
}

#pragma mark - 顶部筛选菜单（综合排序 / 价格瀑布流 / 品牌瀑布流）
- (void)setupDropMenu {
    GHDropMenuModel *configuration = [[GHDropMenuModel alloc] init];
    configuration.recordSeleted = YES; // 选中后把结果回填到标题栏
    configuration.titles = [configuration creaMeituanDropMenuData];

    weakself(self);
    GHDropMenu *dropMenu = [GHDropMenu creatDropMenuWithConfiguration:configuration
                                                                frame:CGRectMake(0, 0, kGHScreenWidth, 44)
                                                  dropMenuTitleBlock:^(GHDropMenuModel * _Nonnull dropMenuModel) {
        [weakSelf updateSummary:dropMenuModel.title];
    } dropMenuTagArrayBlock:^(NSArray * _Nonnull tagArray) {
    }];
    dropMenu.tableY = 44;
    dropMenu.titleSeletedImageName = @"up_normal";
    dropMenu.titleNormalImageName = @"down_normal";
    dropMenu.delegate = self;
    dropMenu.durationTime = 0.25;
    self.dropMenu = dropMenu;
    [self.view addSubview:dropMenu];
}

- (void)updateSummary:(NSString *)text {
    self.navigationItem.title = text.length ? [NSString stringWithFormat:@"筛选结果: %@", text] : self.navTitle;
}

#pragma mark - 食物列表
- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, kGHScreenWidth, self.view.bounds.size.height - 44) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 76;
    self.tableView.separatorColor = kGHThemeLineColor;
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
}

- (NSArray<NSDictionary *> *)foods {
    if (!_foods) {
        _foods = @[
            @{@"icon": @"🍔", @"name": @"招牌牛肉汉堡", @"desc": @"月售 328 · 起送 ¥20 · 35分钟", @"price": @"¥29.9"},
            @{@"icon": @"🍗", @"name": @"香辣鸡腿堡套餐", @"desc": @"月售 456 · 起送 ¥20 · 30分钟", @"price": @"¥32.0"},
            @{@"icon": @"🍟", @"name": @"薯条（大份）", @"desc": @"月售 189 · 起送 ¥15 · 25分钟", @"price": @"¥12.5"},
            @{@"icon": @"🥤", @"name": @"冰镇可乐", @"desc": @"月售 210 · 起送 ¥15 · 25分钟", @"price": @"¥7.0"},
            @{@"icon": @"🍕", @"name": @"超级至尊披萨", @"desc": @"月售 120 · 起送 ¥30 · 45分钟", @"price": @"¥59.0"},
            @{@"icon": @"🌮", @"name": @"墨西哥鸡肉卷", @"desc": @"月售 156 · 起送 ¥18 · 30分钟", @"price": @"¥18.8"},
            @{@"icon": @"🍦", @"name": @"草莓圣代", @"desc": @"月售 88 · 起送 ¥15 · 20分钟", @"price": @"¥9.9"},
            @{@"icon": @"🥗", @"name": @"凯撒沙拉", @"desc": @"月售 66 · 起送 ¥20 · 25分钟", @"price": @"¥22.0"},
            @{@"icon": @"☕", @"name": @"拿铁咖啡", @"desc": @"月售 145 · 起送 ¥12 · 20分钟", @"price": @"¥15.0"},
            @{@"icon": @"🍰", @"name": @"提拉米苏", @"desc": @"月售 98 · 起送 ¥18 · 25分钟", @"price": @"¥16.8"},
        ];
    }
    return _foods;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.foods.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"GHFoodCell";
    GHFoodCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[GHFoodCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    NSDictionary *food = self.foods[indexPath.row];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@  %@", food[@"icon"], food[@"name"]];
    cell.descLabel.text = food[@"desc"];
    cell.priceLabel.text = food[@"price"];
    return cell;
}

#pragma mark - GHDropMenuDelegate
- (void)dropMenu:(GHDropMenu *)dropMenu dropMenuTitleModel:(GHDropMenuModel *)dropMenuTitleModel {
    [self updateSummary:dropMenuTitleModel.title];
}

- (void)dropMenu:(GHDropMenu *)dropMenu tagArray:(NSArray *)tagArray {
}

@end

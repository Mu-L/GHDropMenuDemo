//
//  GHSuspendViewController.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/29.
//  Copyright © 2018年 GHome. All rights reserved.
//

#import "GHSuspendViewController.h"
#import "GHDropMenu.h"
#import "GHSuspendMenuHeaderView.h"
#import "GHSuspendHeader.h"
#import "GHSuspendItem.h"
#import "GHCollectionReusableView.h"
#import "GHDropMenuModel.h"
#import "NSArray+Bounds.h"

#define kHeaderHeight 400

@interface GHSuspendViewController ()<GHDropMenuDelegate,UITableViewDataSource,UITableViewDelegate,GHDropMenuDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic , strong) GHDropMenu *dropMenu;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSArray *dataArray;
@property (nonatomic , strong) GHSuspendHeader *header;
@property (nonatomic , strong) UICollectionView *collectionView ;
@property (nonatomic , strong) UICollectionViewFlowLayout *flowLayout ;
@property (nonatomic , strong) UIButton *button;
@end

@implementation GHSuspendViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view addSubview:self.tableView];
    self.tableView.tableHeaderView = self.header;
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    UIButton *button = [[UIButton alloc]init];
    [button addTarget:self action:@selector(change:)
     forControlEvents:UIControlEventTouchUpInside] ;
    [button setTitle:@"模拟本地数据" forState:UIControlStateNormal];
    [button setTitle:@"模拟网络数据" forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    self.button = button;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:button];

}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect b = self.view.bounds;
    self.tableView.frame = b;
    self.header.frame = CGRectMake(0, 0, CGRectGetWidth(b), kHeaderHeight);
    self.tableView.tableHeaderView = self.header;
}

- (void)change: (UIButton *)button {
    button.selected = !button.selected;
    UIView *raw = [self.tableView headerViewForSection:0];
    if (![raw isKindOfClass:[GHSuspendMenuHeaderView class]]) {
        return;
    }
    GHSuspendMenuHeaderView *view = (GHSuspendMenuHeaderView *)raw;
    [view.dropMenu resetMenuStatus];
}
- (void)refresh {
    [self.tableView reloadData];
}

- (void)dropMenu:(GHDropMenu *)dropMenu
   dropMenuModel:(GHDropMenuModel *)dropMenuModel
           index:(NSInteger)index {
    if (self.button.selected && index == 3) {
        NSMutableArray *temp = [NSMutableArray array];
        GHDropMenuModel *changeModel = [dropMenu.titles by_ObjectAtIndex:3];
        [temp addObject:[dropMenu.titles by_ObjectAtIndex:0]];
        [temp addObject:[dropMenu.titles by_ObjectAtIndex:1]];
        [temp addObject:[dropMenu.titles by_ObjectAtIndex:2]];

        GHDropMenuModel *changeNewModel = [[dropMenuModel creatRandomDropMenuData] by_ObjectAtIndex:3];
        changeNewModel.title = changeModel.title;
        [temp addObject:changeNewModel];
        dropMenu.recordSeleted = YES;
        dropMenuModel.titles = temp.copy;
        dropMenu.configuration = dropMenuModel;
    } else {

    }
}
- (void)back {
    [super back];
    /** 返回时候 需要将菜单收起 */
    UIView *raw = [self.tableView headerViewForSection:0];
    if ([raw isKindOfClass:[GHSuspendMenuHeaderView class]]) {
        [[(GHSuspendMenuHeaderView *)raw dropMenu] closeMenu];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGRect rectInTableView = [self.tableView rectForHeaderInSection:0];
    
    CGRect rect = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];

    UIView *raw = [self.tableView headerViewForSection:0];
    if (![raw isKindOfClass:[GHSuspendMenuHeaderView class]]) {
        return;
    }
    GHSuspendMenuHeaderView *view = (GHSuspendMenuHeaderView *)raw;
    view.dropMenu.tableY = rect.origin.y + rect.size.height;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(kGHScreenWidth, 44);
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
  
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        GHCollectionReusableView *header  = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"GHCollectionReusableViewID" forIndexPath:indexPath];
        return header;
    } else {
        return [UICollectionReusableView new];
    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GHSuspendItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GHSuspendItemID" forIndexPath:indexPath];
    cell.title.text = [NSString stringWithFormat:@"我是collectionView:%@",self.dataArray[indexPath.row]];

    cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor redColor]:[UIColor purpleColor];

    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击collectionView");
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GHSuspendMenuHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"GHSuspendMenuHeaderViewID"];
    CGFloat w = CGRectGetWidth(tableView.bounds);
    [view configureWithTableView:self.tableView section:section hostWidth:w delegate:self];
    view.dropMenu.titleSeletedColor = [UIColor redColor];
    view.dropMenu.titleNormalColor = [UIColor orangeColor];
    view.dropMenu.titleSeletedImageName = @"up_normal";
    view.dropMenu.titleNormalImageName = @"down_normal";
    view.dropMenu.titleFont = [UIFont systemFontOfSize:11];
    view.dropMenu.optionFont = [UIFont systemFontOfSize:20];
    view.dropMenu.optionSeletedColor = [UIColor redColor];
    view.dropMenu.optionNormalColor = [UIColor blueColor];
    view.backgroundView = ({
        UIView *bg = [[UIView alloc] initWithFrame:view.bounds];
        bg.backgroundColor = [UIColor whiteColor];
        bg;
    });
    return view;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID"];
    cell.textLabel.text = [NSString stringWithFormat:@"我是tableView:%@",self.dataArray[indexPath.row]];
    cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor yellowColor]:[UIColor brownColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击tableView");
}
#pragma mark - 代理方法

- (void)dropMenu:(GHDropMenu *)dropMenu dropMenuModel:(GHDropMenuModel *)dropMenuModel {
    
}
- (void)dropMenu:(GHDropMenu *)dropMenu dropMenuTitleModel:(GHDropMenuModel *)dropMenuTitleModel {
    self.navigationItem.title = [NSString stringWithFormat:@"%@第%ld列%ld行",dropMenuTitleModel.title,(long)dropMenuTitleModel.indexPath.section,(long)dropMenuTitleModel.indexPath.row];
}
- (void)dropMenu:(GHDropMenu *)dropMenu tagArray:(NSArray *)tagArray {
    [self getStrWith:tagArray];
}

- (void)getStrWith: (NSArray *)tagArray {
    NSMutableString *string = [NSMutableString string];
    if (tagArray.count) {
        for (GHDropMenuModel *dropMenuTagModel in tagArray) {
            if (dropMenuTagModel.tagSeleted) {
                if (dropMenuTagModel.tagName.length) {
                    [string appendFormat:@"%@",dropMenuTagModel.tagName];
                }
            }
            if (dropMenuTagModel.maxPrice.length) {
                [string appendFormat:@"最大价格%@",dropMenuTagModel.maxPrice];
            }
            if (dropMenuTagModel.minPrice.length) {
                [string appendFormat:@"最小价格%@",dropMenuTagModel.minPrice];
            }
        }
    }
    self.navigationItem.title = [NSString stringWithFormat:@"筛选结果: %@",string];
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (_flowLayout == nil) {
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _flowLayout.itemSize = CGSizeMake(kGHScreenWidth, 44);
        _flowLayout.minimumLineSpacing = 0.01f;
        _flowLayout.minimumInteritemSpacing = 0.01f;

    }
    return _flowLayout;
}
- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kGHScreenWidth, kHeaderHeight) collectionViewLayout:self.flowLayout];
        _collectionView.contentInset = UIEdgeInsetsMake(kHeaderHeight, 0, 0, 0);
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[GHSuspendItem class] forCellWithReuseIdentifier:@"GHSuspendItemID"];
    }
    return _collectionView;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tableView.delegate = self;
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentAutomatic;
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];
        [_tableView registerClass:[GHSuspendMenuHeaderView class] forHeaderFooterViewReuseIdentifier:@"GHSuspendMenuHeaderViewID"];
    }
    return _tableView;
}

- (NSArray *)dataArray {
    if (_dataArray == nil) {
        _dataArray = [NSArray arrayWithObjects:@"学习iOS",@"一定要",@"眼高手低",@"纸上谈兵",@"不思进取",@"多学少练",@"开开心心",@"惠而不倦",@"2019",@"行尸走",
                      @"金蝉脱壳",
                      @"百里挑一",
                      @"金玉满堂",
                      @"背水一战",
                      @"霸王别姬",
                      @"天上人间",
                      @"不吐不快",
                      @"海阔天空",
                      @"情非得已",
                      @"满腹经纶",
                      @"兵临城下" ,nil];
    }
    return _dataArray;
}

- (GHSuspendHeader *)header {
    if (_header == nil) {
        _header = [[GHSuspendHeader alloc]init];
        _header.frame = CGRectMake(0, 0, kGHScreenWidth, kHeaderHeight);
    }
    return _header;
}
- (void)dealloc {
}
@end

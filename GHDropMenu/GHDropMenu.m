//
//  GHDropMenu.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2018/12/14.
//  Copyright © 2018年 GHome. All rights reserved.
//  gitHub:https://github.com/shabake/GHDropMenuDemo

#import "GHDropMenu.h"
#import "NSArray+Bounds.h"
#import "NSString+Size.h"
#import "UIView+Extension.h"
#import "GHDropMenuModel.h"
#import "GHDropMenuTitleItem.h"
#import "GHDropMenuOptionCell.h"
#import "GHDropMenuFilterSectionHeader.h"
#import "GHDropMenuFilterSingleInputItem.h"
#import "GHDropMenuFilterInputItem.h"
#import "GHDropMenuFilterTagItem.h"
#import "GHDropMenuWaterFallCell.h"
#import "GHDropMenuFilterTimeChoseItem.h"
#import "GHCustomAlertView.h"

@class GHDropMenu;

/// 挂在 window 上的弹出容器：避免全屏透明层挡住导航栏「返回」与未弹出时的页面触摸
@interface GHPopupPassthroughHostView : UIView
@property (nonatomic, weak) GHDropMenu *menuOwner;
/// 为 YES 时整层不参与 hitTest（菜单未展开）
@property (nonatomic, copy) BOOL (^isFullyPassthrough)(void);
@end

@implementation GHPopupPassthroughHostView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL (^passthrough)(void) = self.isFullyPassthrough;
    if (passthrough && passthrough()) {
        return nil;
    }
    GHDropMenu *menu = self.menuOwner;
    if (menu.superview) {
        CGRect barRect = [menu convertRect:menu.bounds toView:self];
        if (point.y < CGRectGetMaxY(barRect)) {
            return nil;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end

#pragma mark - - - -- - - -- - - -- - - -- - - -- - - -- - - -- - - -- - - - GHDropMenu 筛选菜单开始
/** 按钮类型 */
typedef NS_ENUM (NSUInteger,GHDropMenuButtonType) {
    /** 确定 */
    GHDropMenuButtonTypeSure = 1,
    /** 重置 */
    GHDropMenuButtonTypeReset,
};

typedef NS_ENUM (NSUInteger,GHDropMenuShowType) {
    GHDropMenuShowTypeCommon = 1,
    GHDropMenuShowTypeOnlyFilter,
};

@interface GHDropMenu()<UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource,UITableViewDelegate,GHDropMenuFilterTagItemDelegate,GHDropMenuFilterInputItemDelegate,GHDropMenuFilterSingleInputItemDelegate,GHDropMenuTitleItemDelegate,GHDropMenuFilterSectionHeaderDelegate,GHDropMenuFilterTimeChoseItemDelegate>

/** 顶部菜单 */
@property (nonatomic , strong) UICollectionView *collectionView;
/** 顶部菜单布局 */
@property (nonatomic , strong) UICollectionViewFlowLayout *flowLayout;
/** 弹出菜单 */
@property (nonatomic , strong) UITableView *tableView;
/** 弹出菜单内容数组 */
@property (nonatomic , strong) NSArray *contents;
/** 菜单的高度 */
@property (nonatomic , assign) CGFloat menuHeight;
@property (nonatomic , strong) UIView *topLine;
@property (nonatomic , strong) UIView *bottomLine;
@property (nonatomic , strong) UIView *bottomView;
/** 弹出菜单选中index */
@property (nonatomic , assign) NSInteger currentIndex;
/** 筛选器 */
@property (nonatomic , strong) UICollectionView *filter;
@property (nonatomic , strong) UICollectionViewFlowLayout *filterFlowLayout;
/** 重置 */
@property (nonatomic , strong) UIButton *reset;
/** 确定 */
@property (nonatomic , strong) UIButton *sure;
/** 遮罩 */
@property (nonatomic , strong) UIControl *filterCover;

@property (nonatomic , strong) NSIndexPath *currentIndexPath;

@property (nonatomic , strong) UIControl *titleCover;

@property (nonatomic , strong) DropMenuTitleBlock dropMenuTitleBlock;

@property (nonatomic , strong) DropMenuTagArrayBlock dropMenuTagArrayBlock;

@property (nonatomic , assign) GHDropMenuShowType dropMenuShowType;
/** 标记菜单是否展开 */
@property (nonatomic , assign) BOOL isShow;
/// 下拉/遮罩挂载在所属 window 上的全屏容器（AutoLayout 用 frame+autoresizing 随 window 变化）
@property (nonatomic , strong) UIView *ghPopupHostView;
typedef NS_ENUM(NSInteger, GHDropMenuPresentationPhase) {
    GHDropMenuPresentationPhaseIdle = 0,
    GHDropMenuPresentationPhaseExpanded,
};
@property (nonatomic , assign) GHDropMenuPresentationPhase presentationPhase;

@end
@implementation GHDropMenu
#pragma mark - 初始化
+ (instancetype)creatDropFilterMenuWidthConfiguration: (GHDropMenuModel *)configuration
                                dropMenuTagArrayBlock: (DropMenuTagArrayBlock)dropMenuTagArrayBlock {
    GHDropMenu *dropMenu = [[GHDropMenu alloc]initWithFrame:CGRectZero];
    dropMenu.dropMenuShowType = GHDropMenuShowTypeOnlyFilter;
    dropMenu.titles = configuration.titles.mutableCopy;
    dropMenu.dropMenuTagArrayBlock = dropMenuTagArrayBlock;
    [dropMenu setupFilterUI];
    return dropMenu;
}

#pragma mark - 初始化
+ (instancetype)creatDropMenuWithConfiguration: (GHDropMenuModel *)configuration frame: (CGRect)frame dropMenuTitleBlock: (DropMenuTitleBlock)dropMenuTitleBlock dropMenuTagArrayBlock: (DropMenuTagArrayBlock)dropMenuTagArrayBlock {
    GHDropMenu *dropMenu = [[GHDropMenu alloc]initWithFrame:CGRectMake(0, frame.origin.y, frame.size.width, frame.size.height)];
    dropMenu.configuration = configuration;
    dropMenu.menuHeight = frame.size.height;
    dropMenu.tableY = frame.origin.y + frame.size.height;
    dropMenu.dropMenuTitleBlock = dropMenuTitleBlock;
    dropMenu.dropMenuTagArrayBlock = dropMenuTagArrayBlock;
    dropMenu.dropMenuShowType = GHDropMenuShowTypeCommon;
    [dropMenu setupUI];
    return dropMenu;
}

#pragma mark - set方法
- (void)setDataSource:(id<GHDropMenuDataSource>)dataSource {
    _dataSource = dataSource;
    
    if (dataSource == nil) {
        return;
    }
    
    NSArray *tempArray = nil;
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(columnTitlesInMeun:)]) {
        tempArray = [self.dataSource columnTitlesInMeun:self];
    }
    NSMutableArray *titles = [NSMutableArray array];
    for (NSInteger index = 0; index < tempArray.count; index++) {
        GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
        dropMenuModel.title = [tempArray by_ObjectAtIndex:index];
        dropMenuModel.dropMenuType = GHDropMenuTypeTitle;
        dropMenuModel.indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        dropMenuModel.identifier = index;
        [titles addObject:dropMenuModel];
    }
    self.titles = titles;
    
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(menu:numberOfColumns:)]) {
        for (NSInteger index = 0; index < titles.count; index++) {
            GHDropMenuModel *dropMenuTitleModel = [titles by_ObjectAtIndex:index];
            NSArray *temp = [self.dataSource menu:self numberOfColumns:index];
            
            NSMutableArray *dataArray = [NSMutableArray array];
            for (NSInteger j = 0; j < temp.count; j++) {
                GHDropMenuModel *dropMenuModel = [[GHDropMenuModel alloc]init];
                dropMenuModel.title = [temp by_ObjectAtIndex:j];
                [dataArray addObject: dropMenuModel];
            }
            dropMenuTitleModel.dataArray = dataArray;
        }
    }
    [self.collectionView reloadData];
}
- (void)setTitles:(NSMutableArray *)titles {
    _titles = titles;
    [self.tableView reloadData];
    [self.collectionView reloadData];
}
- (void)setTableY:(CGFloat)tableY {
    _tableY = tableY;
    [self gh_syncPopupFramesToHost];
}
- (void)setCellHeight:(CGFloat)cellHeight {
    _cellHeight = cellHeight;
}
- (void)setOptionNormalColor:(UIColor *)optionNormalColor {
    _optionNormalColor = optionNormalColor;
    for (GHDropMenuModel *dropMenuTitleModel in self.titles) {
        for (GHDropMenuModel *dropMenuOptionModel in dropMenuTitleModel.dataArray) {
            dropMenuOptionModel.optionNormalColor = optionNormalColor;
        }
    }
    [self.tableView reloadData];
}
- (void)setOptionSeletedColor:(UIColor *)optionSeletedColor {
    _optionSeletedColor = optionSeletedColor;
    for (GHDropMenuModel *dropMenuTitleModel in self.titles) {
        for (GHDropMenuModel *dropMenuOptionModel  in dropMenuTitleModel.dataArray) {
            dropMenuOptionModel.optionSeletedColor = optionSeletedColor;
        }
    }
    [self.tableView reloadData];
}
- (void)setOptionFont:(UIFont *)optionFont {
    _optionFont = optionFont;
    for (GHDropMenuModel *dropMenuTitleModel in self.titles) {
        for (GHDropMenuModel *dropMenuOptionModel  in dropMenuTitleModel.dataArray) {
            dropMenuOptionModel.optionFont = optionFont;
        }
    }
    [self.tableView reloadData];
}
- (void)setTitleNormalImageName:(NSString *)titleNormalImageName {
    _titleNormalImageName = titleNormalImageName;
    for (GHDropMenuModel *dropMenuTitleModel in self.titles) {
        dropMenuTitleModel.titleNormalImageName = titleNormalImageName;
    }
    [self.collectionView reloadData];
}
- (void)setTitleSeletedImageName:(NSString *)titleSeletedImageName {
    _titleSeletedImageName = titleSeletedImageName;
    for (GHDropMenuModel *dropMenuTitleModel in self.titles) {
        dropMenuTitleModel.titleSeletedImageName = titleSeletedImageName;
    }
    [self.collectionView reloadData];
}
- (void)setTitleSeletedColor:(UIColor *)titleSeletedColor {
    _titleSeletedColor = titleSeletedColor;
    for (GHDropMenuModel *dropMenuTitleModel in self.titles) {
        dropMenuTitleModel.titleSeletedColor = titleSeletedColor;
    }
    [self.collectionView reloadData];
}
- (void)setTitleNormalColor:(UIColor *)titleNormalColor {
    _titleNormalColor = titleNormalColor;
    for (GHDropMenuModel *dropMenuTitleModel in self.titles) {
        dropMenuTitleModel.titleNormalColor = titleNormalColor;
    }
    [self.collectionView reloadData];
}
- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    for (GHDropMenuModel *dropMenuTitleModel in self.titles) {
        dropMenuTitleModel.titleFont = titleFont;
    }
    [self.collectionView reloadData];
}
- (void)setTitleViewBackGroundColor:(UIColor *)titleViewBackGroundColor {
    for (GHDropMenuModel *dropMenuTitleModel in self.titles) {
        dropMenuTitleModel.titleViewBackGroundColor = titleViewBackGroundColor;
    }
    [self.collectionView reloadData];
}

- (void)setConfiguration:(GHDropMenuModel *)configuration {
    _configuration = configuration;
    self.titles = configuration.titles.copy;
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

#pragma mark - set方法 end
- (instancetype)new {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"请使用方法 creatDropMenuWithConfiguration: or creatDropFilterMenuWidthConfiguration: 代替初始化" userInfo:nil];
}
- (instancetype)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"请使用方法 creatDropMenuWithConfiguration: or creatDropFilterMenuWidthConfiguration: 代替初始化" userInfo:nil];
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self defaultConfiguration];
    }
    return self;
}
- (void)defaultConfiguration {
    self.menuHeight = 44;
    self.currentIndex = 0;
    self.cellHeight = 44;
    self.isShow = NO;
    self.presentationPhase = GHDropMenuPresentationPhaseIdle;
}

- (UIWindow *)gh_resolveWindow {
    if (self.window) {
        return self.window;
    }
    return [UIApplication gh_keyWindow];
}

- (void)gh_ensureCommonPopupHost {
    if (self.dropMenuShowType != GHDropMenuShowTypeCommon) {
        return;
    }
    UIWindow *win = [self gh_resolveWindow];
    if (!win) {
        return;
    }
    if (!self.ghPopupHostView) {
        GHPopupPassthroughHostView *hostView = [[GHPopupPassthroughHostView alloc] initWithFrame:win.bounds];
        hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        hostView.userInteractionEnabled = YES;
        hostView.backgroundColor = UIColor.clearColor;
        hostView.menuOwner = self;
        __weak typeof(self) weakSelf = self;
        hostView.isFullyPassthrough = ^BOOL {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            if (!strongSelf) {
                return YES;
            }
            return (BOOL)(!strongSelf.isShow && strongSelf.presentationPhase == GHDropMenuPresentationPhaseIdle);
        };
        self.ghPopupHostView = hostView;
    } else {
        self.ghPopupHostView.frame = win.bounds;
    }
    if (self.ghPopupHostView.superview != win) {
        [win addSubview:self.ghPopupHostView];
    }
    [win bringSubviewToFront:self.ghPopupHostView];
    UIView *host = self.ghPopupHostView;
    if (self.filterCover.superview != host) {
        [host addSubview:self.filterCover];
    }
    if (self.titleCover.superview != host) {
        [host addSubview:self.titleCover];
    }
    if (self.tableView.superview != host) {
        [host addSubview:self.tableView];
    }
}

- (CGRect)gh_popupLayoutBounds {
    if (self.dropMenuShowType == GHDropMenuShowTypeOnlyFilter) {
        return self.bounds;
    }
    [self gh_ensureCommonPopupHost];
    return self.ghPopupHostView.bounds;
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.superview && self.dropMenuShowType == GHDropMenuShowTypeCommon) {
        [self gh_ensureCommonPopupHost];
        [self gh_syncPopupFramesToHost];
    }
}

- (UIViewController *)gh_presentingViewController {
    for (UIResponder *r = self; r; r = r.nextResponder) {
        if ([r isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)r;
        }
    }
    return nil;
}

/// 底部 Home 条区域：优先用父视图（如 VC.view）的 safeArea，侧滑筛选与 window 高度不一致时也能贴底
- (CGFloat)gh_effectiveSafeAreaBottom {
    if (self.superview) {
        return self.superview.safeAreaInsets.bottom;
    }
    return [UIApplication gh_safeAreaInsets].bottom;
}

/// 全屏/侧滑筛选（GHDropMenuTypeFilter）下白底面板 + 按钮 + 底部安全区延伸条
- (void)gh_layoutFilterSheetChromeInContainerBounds:(CGRect)containerBounds {
    if (self.bottomView.superview != self.filterCover) {
        [self.filterCover addSubview:self.bottomView];
    }
    CGFloat winW = CGRectGetWidth(containerBounds);
    CGFloat winH = CGRectGetHeight(containerBounds);
    CGFloat safeBottom = [self gh_effectiveSafeAreaBottom];
    CGFloat filterH = MAX(0, winH - kFilterButtonHeight - safeBottom);
    self.filter.frame = CGRectMake(winW * 0.1f, 0, winW * 0.9f, filterH);
    CGFloat btnY = CGRectGetMaxY(self.filter.frame);
    self.reset.frame = CGRectMake(self.filter.frame.origin.x, btnY, self.filter.frame.size.width * 0.5f, kFilterButtonHeight);
    self.sure.frame = CGRectMake(self.filter.frame.origin.x + self.filter.frame.size.width * 0.5f, btnY, self.filter.frame.size.width * 0.5f, kFilterButtonHeight);
    self.sure.alpha = 1;
    self.reset.alpha = 1;
    self.bottomView.frame = CGRectMake(self.filter.frame.origin.x, CGRectGetMaxY(self.reset.frame), self.filter.frame.size.width, safeBottom);
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.filterCover bringSubviewToFront:self.sure];
    [self.filterCover bringSubviewToFront:self.reset];
}

#pragma mark - 消失
- (void)dismiss {
    
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex:self.currentIndex];
    self.filterCover.backgroundColor = [UIColor clearColor];
    self.titleCover.backgroundColor = [UIColor clearColor];
    if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeOptionCollection /** 普通菜单 */) {
        self.sure.alpha = 0;
        self.reset.alpha = 0;
    }
    [self gh_syncPopupFramesToHost];
    CGRect wb = [self gh_popupLayoutBounds];
    CGFloat winW = CGRectGetWidth(wb);
    CGFloat winH = CGRectGetHeight(wb);
    CGFloat popupX = CGRectGetMinX(self.tableView.frame);
    CGFloat popupW = CGRectGetWidth(self.tableView.frame);
    [UIView animateWithDuration:self.durationTime animations:^{
        if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeTitle /** 普通菜单 */) {
            self.tableView.frame = CGRectMake(popupX, self.tableY, popupW, 0);
            self.titleCover.frame = CGRectMake(popupX, self.tableY, popupW, 0);
        } else if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeFilter /** 筛选菜单 */) {
            self.filterCover.frame = CGRectMake(winW, 0, winW, winH);
            
        }  else if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeOptionCollection) {
            self.filter.frame = CGRectMake(popupX, self.tableY, popupW, 0);
            self.titleCover.frame = CGRectMake(popupX, self.tableY, popupW, 0);
            self.sure.frame = CGRectMake(popupX, CGRectGetMaxY(self.filter.frame), self.filter.width * 0.5, kFilterButtonHeight);
            self.reset.frame = CGRectMake(popupX + self.filter.width * .5, CGRectGetMaxY(self.filter.frame), self.filter.width * 0.5, kFilterButtonHeight);
        }
    } completion:^(BOOL finished) {
        if (self.dropMenuShowType == GHDropMenuShowTypeOnlyFilter) {
            [self.layer setOpacity:0.0];
        }
        self.isShow = NO;
        self.presentationPhase = GHDropMenuPresentationPhaseIdle;
        [self.tableView reloadData];
        [self.collectionView reloadData];
        
    }];
}
#pragma mark - 弹出
- (void)show {
    [self.tableView reloadData];
    [self.filter reloadData];
    self.sure.alpha = 0;
    self.reset.alpha = 0;
    if (self.dropMenuShowType == GHDropMenuShowTypeOnlyFilter) {
        [self.layer setOpacity:1];
    }
    if (self.dropMenuShowType == GHDropMenuShowTypeCommon) {
        [self gh_ensureCommonPopupHost];
    }
    [self gh_syncPopupFramesToHost];
    CGRect wb = [self gh_popupLayoutBounds];
    CGFloat winH = CGRectGetHeight(wb);
    CGFloat popupX = CGRectGetMinX(self.tableView.frame);
    CGFloat popupW = CGRectGetWidth(self.tableView.frame);
    CGFloat titleCoverHeight = MAX(0.f, winH - self.tableY);
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex:self.currentIndex];
    if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeTitle /** 筛选菜单 */) {
        self.titleCover.backgroundColor = [UIColor clearColor];
        self.filter.frame = CGRectMake(popupX, self.tableY, popupW, 0);
        
    } else if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeOptionCollection) {
        self.tableView.frame = CGRectMake(popupX, self.tableY, popupW, 0);
        [self.ghPopupHostView addSubview:self.filter];
        
        self.filter.frame =  CGRectMake(popupX, self.tableY, popupW, 0);
        [self.ghPopupHostView addSubview:self.sure];
        [self.ghPopupHostView addSubview:self.reset];
        self.reset.frame = CGRectMake(popupX, CGRectGetMaxY(self.filter.frame), popupW * 0.5, kFilterButtonHeight);
        self.sure.frame = CGRectMake(popupX + popupW * .5, CGRectGetMaxY(self.filter.frame), popupW * 0.5, kFilterButtonHeight);
        self.sure.alpha = 1;
        self.reset.alpha = 1;
        
    } else if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeFilter) {
        /** 仅 Common 模式需要先 dismiss 并把遮罩挂到 window 的 host；OnlyFilter 若也 dismiss，completion 里会把 layer.opacity 置 0，侧滑面板展示结束后会整页消失 */
        if (self.dropMenuShowType == GHDropMenuShowTypeCommon) {
            [self dismiss];
            [self.ghPopupHostView addSubview:self.filterCover];
        }
        [self.filterCover addSubview:self.filter];
        [self.filterCover addSubview:self.sure];
        [self.filterCover addSubview:self.reset];
        [self gh_layoutFilterSheetChromeInContainerBounds:wb];
    }
    [UIView animateWithDuration:self.durationTime animations:^{
        if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeTitle /** 普通菜单 */) {
            self.tableView.frame = CGRectMake(popupX, self.tableY, popupW, dropMenuTitleModel.dataArray.count * self.cellHeight);
            self.titleCover.frame = CGRectMake(popupX, self.tableY, popupW, titleCoverHeight);
            
        } else if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeFilter /** 筛选菜单 */) {
            self.tableView.frame = CGRectMake(popupX, self.tableY, popupW, 0);
            self.titleCover.frame = CGRectMake(popupX, self.tableY, popupW, 0);
            self.filterCover.frame = wb;
        }  else if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeOptionCollection /** 筛选菜单 */) {
            self.filter.frame =  CGRectMake(popupX, self.tableY, popupW, 500);
            self.titleCover.frame = CGRectMake(popupX, self.tableY, popupW, titleCoverHeight);
            
            self.reset.frame = CGRectMake(popupX, CGRectGetMaxY(self.filter.frame), self.filter.width * 0.5, kFilterButtonHeight);
            self.sure.frame = CGRectMake(popupX + self.filter.width * .5, CGRectGetMaxY(self.filter.frame), self.filter.width * 0.5, kFilterButtonHeight);
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeFilter /** 筛选菜单 */) {
                self.filterCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:102.0/255];
            } else if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeTitle) {
                self.titleCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:102.0/255];
            } else if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeOptionCollection) {
                self.titleCover.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:102.0/255];
            }
        } completion:^(BOOL finished) {
            self.isShow = YES;
            self.presentationPhase = GHDropMenuPresentationPhaseExpanded;
            if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeFilter) {
                CGRect b = (self.dropMenuShowType == GHDropMenuShowTypeOnlyFilter) ? self.bounds : self.ghPopupHostView.bounds;
                [self gh_layoutFilterSheetChromeInContainerBounds:b];
            }
        }];
    }];
}

- (void)gh_syncPopupFramesToHost {
    if (self.dropMenuShowType != GHDropMenuShowTypeCommon) {
        return;
    }
    [self gh_ensureCommonPopupHost];
    UIView *host = self.ghPopupHostView;
    if (!host || !self.superview) {
        return;
    }
    CGRect barInHost = [self convertRect:self.bounds toView:host];
    CGFloat popupY = CGRectGetMaxY(barInHost);
    CGFloat popupW = CGRectGetWidth(barInHost);
    CGFloat popupX = CGRectGetMinX(barInHost);
    _tableY = popupY;
    UITableView *tv = self.tableView;
    CGFloat tableH = CGRectGetHeight(tv.frame);
    tv.frame = CGRectMake(popupX, popupY, popupW, tableH);
    UIControl *cover = self.titleCover;
    CGFloat coverH = CGRectGetHeight(cover.frame);
    cover.frame = CGRectMake(popupX, popupY, popupW, coverH);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat menuW = self.bounds.size.width;
    self.collectionView.frame = CGRectMake(0, 0, menuW, self.menuHeight);
    self.topLine.frame = CGRectMake(0, 0, menuW, 1);
    self.bottomLine.frame = CGRectMake(0, self.menuHeight - 1, menuW, 1);
    [self gh_syncPopupFramesToHost];
    if (self.dropMenuShowType == GHDropMenuShowTypeOnlyFilter && self.isShow && self.presentationPhase == GHDropMenuPresentationPhaseExpanded) {
        GHDropMenuModel *m = [self.titles by_ObjectAtIndex:self.currentIndex];
        if (m.dropMenuType == GHDropMenuTypeFilter && self.filterCover.superview) {
            self.filterCover.frame = self.bounds;
            [self gh_layoutFilterSheetChromeInContainerBounds:self.bounds];
        }
    }
}
#pragma mark - 创建UI 添加控件
- (void)setupUI {
    [self addSubview:self.collectionView];
    [self.collectionView addSubview:self.bottomLine];
    [self.filterCover addSubview:self.filter];
    [self.filterCover addSubview:self.bottomView];
    [self.filterCover addSubview:self.sure];
    [self.filterCover addSubview:self.reset];
}

- (void)setupFilterUI {
    [self addSubview:self.filterCover];
    [self.filterCover addSubview:self.filter];
    [self.filterCover addSubview:self.bottomView];
    [self.filterCover addSubview:self.sure];
    [self.filterCover addSubview:self.reset];
}
- (void)closeMenu {
    [self.ghPopupHostView removeFromSuperview];
    self.ghPopupHostView = nil;
    [self.tableView removeFromSuperview];
    [self.titleCover removeFromSuperview];
    [self.filter removeFromSuperview];
    [self.filterCover removeFromSuperview];
    [self.sure removeFromSuperview];
    [self.reset removeFromSuperview];
    [self.collectionView removeFromSuperview];
}
/** 重置menu 状态 */
- (void)resetMenuStatus {
    for (GHDropMenuModel *dropMenuModel in self.titles) {
        dropMenuModel.titleSeleted = NO;
    }
    [self.filter reloadData];
    [self.collectionView reloadData];
    [self dismiss];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self resetMenuStatus];
}

- (void)dropMenuFilterSingleInputItem:(GHDropMenuFilterSingleInputItem *)item
                        dropMenuModel:(GHDropMenuModel *)dropMenuModel {
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex: self.currentIndex];
    GHDropMenuModel *dropMenuSectionModel = [dropMenuTitleModel.sections by_ObjectAtIndex: dropMenuModel.indexPath.section];
    GHDropMenuModel *dropMenuTagModel = [dropMenuSectionModel.dataArray by_ObjectAtIndex:dropMenuModel.indexPath.row];
    dropMenuTagModel.singleInput = dropMenuModel.singleInput;
}

- (void)dropMenuFilterEndInputItem:(GHDropMenuFilterInputItem *)item dropMenuModel:(GHDropMenuModel *)dropMenuModel {
    if (dropMenuModel.minPrice.length && dropMenuModel.maxPrice.length) {
        if (dropMenuModel.minPrice.doubleValue > dropMenuModel.maxPrice.doubleValue) {
            UIViewController *presenter = [self gh_presentingViewController];
            if (presenter) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"最小价格不能大于最大价格,请重新选择" preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:nil]];
                [presenter presentViewController:alert animated:YES completion:nil];
            }
            dropMenuModel.minPrice = @"";
            dropMenuModel.maxPrice = @"";
            [self.filter reloadData];
        }
    }
}

- (void)dropMenuFilterTimeChoseItem:(GHDropMenuFilterTimeChoseItem *)item type:(GHDropMenuFilterTimeChoseItemType)type dropMenuModel:(GHDropMenuModel *)dropMenuModel {
    GHCustomAlertView *alert = [[GHCustomAlertView alloc]init];
    alert.alertHeight = 220;
    alert.alertTitle = type == GHDropMenuFilterTimeChoseItemTypeBeginTime ?@"选择开始时间":@"选择结束时间";
    alert.positionType = GHCustomAlertViewPositionType_bottom;
    alert.timeBlock = ^(NSString *time) {
        if (type == GHDropMenuFilterTimeChoseItemTypeBeginTime) {
            dropMenuModel.beginTime = time;
        } else {
            dropMenuModel.endTime = time;
        }
    };
    alert.dimissFinish = ^{
        [self.filter reloadData];
    };
    [alert show];
}

- (void)dropMenuFilterInputItem:(GHDropMenuFilterInputItem *)item
                  dropMenuModel:(GHDropMenuModel *)dropMenuModel {
    
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex: self.currentIndex];
    GHDropMenuModel *dropMenuSectionModel = [dropMenuTitleModel.sections by_ObjectAtIndex: dropMenuModel.indexPath.section];
    GHDropMenuModel *dropMenuTagModel = [dropMenuSectionModel.dataArray by_ObjectAtIndex:dropMenuModel.indexPath.row];
    dropMenuTagModel.minPrice = dropMenuModel.minPrice;
    dropMenuTagModel.maxPrice = dropMenuModel.maxPrice;
}

- (void)dropMenuFilterSectionHeader:(GHDropMenuFilterSectionHeader *)header
                      dropMenuModel:(GHDropMenuModel *)dropMenuModel {
    dropMenuModel.sectionSeleted = !dropMenuModel.sectionSeleted;
    [self.filter reloadData];
}

#pragma mark - tag标签点击方法
- (void)dropMenuFilterTagItem:(GHDropMenuFilterTagItem *)item
                dropMenuModel:(GHDropMenuModel *)dropMenuModel {
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex: self.currentIndex];
    GHDropMenuModel *dropMenuSectionModel = [dropMenuTitleModel.sections by_ObjectAtIndex: dropMenuModel.indexPath.section];
    /** 处理多选 单选*/
    [self actionMultipleWithDropMenuModel:dropMenuModel dropMenuSectionModel:dropMenuSectionModel];
    /** 处理sectionDetails */
    [self actionSectionHeaderDetailsWithDropMenuModel:dropMenuModel dropMenuSectionModel:dropMenuSectionModel];
    [self.filter reloadData];
}

#pragma mark - 处理sectionHeaderDetails
- (void)actionSectionHeaderDetailsWithDropMenuModel: (GHDropMenuModel *)dropMenuModel
                               dropMenuSectionModel: (GHDropMenuModel *)dropMenuSectionModel {
    
    NSMutableString *details = [NSMutableString string];
    for (GHDropMenuModel *dropMenuTagModel in dropMenuSectionModel.dataArray) {
        if (dropMenuTagModel.tagSeleted) {
            [details appendFormat:@"%@,", dropMenuTagModel.tagName];
        }
    }
    if (details.length) {
        [details deleteCharactersInRange:NSMakeRange(details.length - 1, 1)];
    }
    dropMenuSectionModel.sectionHeaderDetails = details;
}
#pragma mark - 处理单选 多选
- (void)actionMultipleWithDropMenuModel: (GHDropMenuModel *)dropMenuModel
                   dropMenuSectionModel: (GHDropMenuModel *)dropMenuSectionModel {
    
    /** 处理单选 */
    NSString *currentSeletedStr = [NSString string];
    if (dropMenuSectionModel.isMultiple) {
        
    } else {
        for (GHDropMenuModel *dropMenuTagModel in dropMenuSectionModel.dataArray) {
            if (dropMenuTagModel.tagSeleted) {
                currentSeletedStr = dropMenuTagModel.tagName;
            }
            dropMenuTagModel.tagSeleted = NO;
        }
    }
    if (self.currentIndexPath != dropMenuModel.indexPath /** 不是第一次选中 */) {
        if ([currentSeletedStr isEqualToString:dropMenuModel.tagName]) {
            dropMenuModel.tagSeleted = NO;
        } else {
            dropMenuModel.tagSeleted = !dropMenuModel.tagSeleted ;
        }
        self.currentIndexPath = dropMenuModel.indexPath;
    } else {
        if ([currentSeletedStr isEqualToString:dropMenuModel.tagName]) {
            if (dropMenuSectionModel.isMultiple) {
                dropMenuModel.tagSeleted = YES;
            } else {
                dropMenuModel.tagSeleted = NO;
            }
        } else {
            dropMenuModel.tagSeleted = !dropMenuModel.tagSeleted ;
        }
        self.currentIndexPath = nil;
    }
}

#pragma mark - 点击顶部titleView 代理回调
- (void)dropMenuTitleItem: (GHDropMenuTitleItem *)item
            dropMenuModel: (GHDropMenuModel *)dropMenuModel {
    
    dropMenuModel.titleSeleted = !dropMenuModel.titleSeleted;
    self.currentIndex = dropMenuModel.indexPath.row;
    
    if (dropMenuModel.titleSeleted) {
        self.contents = dropMenuModel.dataArray.copy;
        for (GHDropMenuModel *model in self.titles) {
            if (model.identifier != dropMenuModel.identifier) {
                model.titleSeleted = NO;
            }
        }
        
        [self show];
    } else {
        [self dismiss];
    }
    
    [self.collectionView reloadData];
}

#pragma mark - tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex:self.currentIndex];
    
    if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeWaterFall) {
        GHDropMenuModel *rowModel = [dropMenuTitleModel.dataArray by_ObjectAtIndex:indexPath.row];
        NSInteger n = rowModel.waterFallTags.count;
        if (n <= 0) {
            return 44.f;
        }
        NSInteger rows = (n + 2) / 3;
        return 16.f + rows * 36.f;
    } else {
        return 44;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex:self.currentIndex];
    
    GHDropMenuModel *dropMenuModel = [dropMenuTitleModel.dataArray by_ObjectAtIndex: indexPath.row];
    dropMenuModel.indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:dropMenuTitleModel.indexPath.row];
    
    if (dropMenuTitleModel.dropMenuType == GHDropMenuTypeWaterFall) {
        GHDropMenuWaterFallCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GHDropMenuWaterFallCellID"];
        NSArray *tags = dropMenuModel.waterFallTags;
        cell.tags = tags ? [tags mutableCopy] : [NSMutableArray array];
        return cell;
  
    } else {
        NSString *cellIdentifier = [NSString stringWithFormat:@"GHDropMenuOptionCellID%ld%ld%ld",indexPath.section,indexPath.row,(long)dropMenuTitleModel.identifier];
        
        GHDropMenuOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[GHDropMenuOptionCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        }
        cell.dropMenuModel = dropMenuModel;
        return cell;
    }
    return [UITableViewCell new];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GHDropMenuModel *dropMenuModel = [self.titles by_ObjectAtIndex: self.currentIndex];
    for (GHDropMenuModel *dropMenuContentModel in dropMenuModel.dataArray) {
        dropMenuContentModel.cellSeleted = NO;
    }
    GHDropMenuModel *contentModel = [dropMenuModel.dataArray by_ObjectAtIndex:indexPath.row];
    if (self.configuration.recordSeleted) {
        dropMenuModel.title = contentModel.title;
    }
    
    contentModel.cellSeleted = !contentModel.cellSeleted;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropMenu:dropMenuTitleModel:)]) {
        [self.delegate dropMenu:self dropMenuTitleModel:contentModel];
    }
    
    if (self.dropMenuTitleBlock) {
        self.dropMenuTitleBlock(contentModel);
    }
    
    [self resetMenuStatus];
}
#pragma mark - collectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section  {
    if (self.filter == collectionView) {
        return CGSizeMake(kGHScreenWidth * 0.8, 10);
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.filter == collectionView) {
        return CGSizeMake(kGHScreenWidth * 0.8, 44);
    } else {
        return CGSizeZero;
    }
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex:self.currentIndex];
    GHDropMenuModel *dropMenuSectionModel = [dropMenuTitleModel.sections by_ObjectAtIndex:indexPath.section];
    dropMenuSectionModel.indexPath = indexPath;
    if ([kind isEqualToString:UICollectionElementKindSectionHeader] && self.filter == collectionView) {
        GHDropMenuFilterSectionHeader *header  = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"GHDropMenuFilterSectionHeaderID" forIndexPath:indexPath];
        header.dropMenuModel = dropMenuSectionModel;
        header.delegate = self;
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter] && self.filter == collectionView) {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionReusableViewID" forIndexPath:indexPath];
    } else {
        return [UICollectionReusableView new];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    GHDropMenuModel *dropMenuModel = [self.titles by_ObjectAtIndex: self.currentIndex];
    
    if (collectionView == self.collectionView) {
        return CGSizeMake(kGHScreenWidth /self.titles.count, self.menuHeight - 0.01f);
    } else if (collectionView == self.filter) {
        GHDropMenuModel *dropMenuSectionModel = [dropMenuModel.sections by_ObjectAtIndex:indexPath.section];
        if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeTag) {
            return CGSizeMake((dropMenuModel.menuWidth - (dropMenuModel.sectionCount + 1) * 10) /dropMenuModel.sectionCount , 30.01f);
        } else if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeInput ||
                   dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeSingleInput ||
                   dropMenuSectionModel.filterCellType ==GHDropMenuFilterCellTypeTimeChose) {
            return CGSizeMake(dropMenuModel.menuWidth - (dropMenuModel.sectionCount -1) * 10,30.01f);
        } else if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeTagCollection) {
            return CGSizeMake((dropMenuModel.menuWidth - (dropMenuModel.sectionCount + 1) * 10) / (dropMenuModel.sectionCount + 1), 30.01f);
        } else {
            return CGSizeZero;
        }
    } else {
        return CGSizeZero;
    }
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex: self.currentIndex];
    if (self.filter == collectionView) {
        return dropMenuTitleModel.sections.count;
    } else if (collectionView == self.collectionView){
        
        return 1;
    } else {
        
        return 0;
    }
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.collectionView == collectionView) {
        return self.titles.count;
    } else if (self.filter == collectionView) {
        GHDropMenuModel *dropMenuModel = [self.titles by_ObjectAtIndex: self.currentIndex];
        GHDropMenuModel *dropMenuSectionModel = [dropMenuModel.sections by_ObjectAtIndex: section];
        if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeTag) {
            return dropMenuSectionModel.sectionSeleted ? dropMenuSectionModel.dataArray.count:dropMenuSectionModel.dataArray.count > 3 ? 3:dropMenuSectionModel.dataArray.count;
        } else if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeInput ||
                   dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeSingleInput) {
            return 1;
        } else {
            return dropMenuSectionModel.dataArray.count;
        }
    } else {
        return 0;
    }
}
#pragma mark - - - 返回collectionView item
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionView) {
        NSString *identifier = [NSString stringWithFormat:@"GHDropMenuTitleItemID%ld%ld",(long)indexPath.section,(long)indexPath.row];
        [collectionView registerClass:[GHDropMenuTitleItem class] forCellWithReuseIdentifier:identifier];
        GHDropMenuModel *dropMenuModel = [self.titles by_ObjectAtIndex:indexPath.row];
        dropMenuModel.indexPath = indexPath;
        GHDropMenuTitleItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
        cell.dropMenuModel = dropMenuModel;
        cell.delegate = self;
        return cell;
    } else if (collectionView == self.filter) {
        NSString *identifier = [NSString stringWithFormat:@"GHDropMenuFilterTagItemID%ld%ld",(long)indexPath.section,(long)indexPath.row];
        [self.filter registerClass:[GHDropMenuFilterTagItem class] forCellWithReuseIdentifier:identifier];
        
        GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex: self.currentIndex];
        GHDropMenuModel *dropMenuSectionModel = [dropMenuTitleModel.sections by_ObjectAtIndex: indexPath.section];
        GHDropMenuModel *dropMenuTagModel = [dropMenuSectionModel.dataArray by_ObjectAtIndex: indexPath.row];
        dropMenuTagModel.indexPath = indexPath;
        if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeTag) {
            GHDropMenuFilterTagItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
            cell.dropMenuModel = dropMenuTagModel;
            cell.delegate = self;
            return cell;
        } else if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeInput) {
            GHDropMenuFilterInputItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GHDropMenuFilterInputItemID" forIndexPath:indexPath];
            cell.dropMenuModel = dropMenuTagModel;
            cell.delegate = self;
            return cell;
        } else if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeSingleInput) {
            GHDropMenuFilterSingleInputItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GHDropMenuFilterSingleInputItemID" forIndexPath:indexPath];
            cell.dropMenuModel = dropMenuTagModel;
            cell.delegate = self;
            return cell;
        }  else if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeTimeChose) {
            GHDropMenuFilterTimeChoseItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GHDropMenuFilterTimeChoseItemID" forIndexPath:indexPath];
            cell.dropMenuModel = dropMenuTagModel;
            cell.delegate = self;
            return cell;
        } else  {
            return [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellID" forIndexPath:indexPath];
        }
    } else {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCellID" forIndexPath:indexPath];
    }
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    [self resetMenuStatus];
}

- (void)clickButton: (UIButton *)button {
    GHDropMenuModel *dropMenuTitleModel = [self.titles by_ObjectAtIndex:self.currentIndex];
    if (button.tag == GHDropMenuButtonTypeSure) {
        NSMutableArray *dataArray = [NSMutableArray array];
        for (GHDropMenuModel *dropMenuSectionModel in dropMenuTitleModel.sections) {
            for (GHDropMenuModel *dropMenuTagModel in dropMenuSectionModel.dataArray) {
                if (dropMenuTagModel.tagSeleted) {
                    [dataArray addObject:dropMenuTagModel];
                }
                if (dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeInput ||
                    dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeSingleInput ||
                    dropMenuSectionModel.filterCellType == GHDropMenuFilterCellTypeTimeChose) {
                    
                    [dataArray addObject:dropMenuTagModel];
                }
            }
        }
        [self resetMenuStatus];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(dropMenu:tagArray:)]) {
            [self.delegate dropMenu:self tagArray:dataArray.copy];
        }
        if (self.dropMenuTagArrayBlock) {
            self.dropMenuTagArrayBlock(dataArray.copy);
        }
    } else if (button.tag == GHDropMenuButtonTypeReset){
        for (GHDropMenuModel *dropMenuSectionModel in dropMenuTitleModel.sections) {
            dropMenuSectionModel.sectionHeaderDetails = @"";
            for (GHDropMenuModel *dropMenuTagModel in dropMenuSectionModel.dataArray) {
                dropMenuTagModel.tagSeleted = NO;
                dropMenuTagModel.minPrice = @"";
                dropMenuTagModel.maxPrice = @"";
            }
        }
        [self.filter reloadData];
    }
}
- (void)clickControl {
    [self resetMenuStatus];
}
#pragma mark - 懒加载
- (UIView *)bottomView {
    if (_bottomView == nil) {
        _bottomView = [[UIView alloc]init];
        _bottomView.backgroundColor = [UIColor whiteColor];
    }
    return _bottomView;
}
- (UIControl *)titleCover {
    if (_titleCover == nil) {
        _titleCover = [[UIControl alloc]init];
        _titleCover.frame = CGRectMake(0, self.frame.size.height + kGHSafeAreaTopHeight, kGHScreenWidth, 0);
        [_titleCover addTarget:self action:@selector(clickControl) forControlEvents:UIControlEventTouchUpInside];
        _titleCover.backgroundColor = [UIColor clearColor];
    }
    return _titleCover;
}
- (UIControl *)filterCover {
    if (_filterCover == nil) {
        _filterCover = [[UIControl alloc]init];
        CGRect wb = kGHKeyWindowBounds;
        CGFloat winW = CGRectGetWidth(wb);
        CGFloat winH = CGRectGetHeight(wb);
        _filterCover.frame = CGRectMake(winW, 0, winW, winH);
        [_filterCover addTarget:self action:@selector(clickControl) forControlEvents:UIControlEventTouchUpInside];
        _filterCover.backgroundColor = [UIColor clearColor];
    }
    return _filterCover;
}
- (UIButton *)reset {
    if (_reset == nil) {
        _reset = [[UIButton alloc]init];
        _reset.frame = CGRectMake(self.filter.frame.origin.x, self.filter.frame.size.height, self.filter.frame.size.width * 0.5, kFilterButtonHeight);
        _reset.backgroundColor = [UIColor whiteColor];
        [_reset setTitle:@"重置" forState:UIControlStateNormal];
        [_reset setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_reset addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        _reset.tag = GHDropMenuButtonTypeReset;
        UIView *line = [[UIView alloc]init];
        line.backgroundColor = [UIColor lightGrayColor];
        line.alpha = .1;
        line.frame = CGRectMake(0, 0, _reset.frame.size.width, 1);
        [_reset addSubview:line];
        _reset.alpha = 0;
    }
    return _reset;
}
- (UIButton *)sure {
    if (_sure == nil) {
        _sure = [[UIButton alloc]init];
        _sure.frame = CGRectMake(kGHScreenWidth - self.filter.frame.size.width * 0.5, self.filter.frame.size.height, self.filter.frame.size.width * 0.5, kFilterButtonHeight);
        _sure.backgroundColor = [UIColor orangeColor];
        [_sure setTitle:@"确定" forState:UIControlStateNormal];
        [_sure setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sure.tag = GHDropMenuButtonTypeSure;
        [_sure addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        _sure.alpha = 0;
    }
    return _sure;
}
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.tableY, 0, 0) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.bounces = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[GHDropMenuOptionCell class] forCellReuseIdentifier:@"GHDropMenuOptionCellID"];
        [_tableView registerClass:[GHDropMenuWaterFallCell class] forCellReuseIdentifier:@"GHDropMenuWaterFallCellID"];
    }
    return _tableView;
}
- (UICollectionViewFlowLayout *)filterFlowLayout {
    if (_filterFlowLayout == nil) {
        _filterFlowLayout = [[UICollectionViewFlowLayout alloc]init];
        _filterFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _filterFlowLayout.minimumLineSpacing = 10.01f;
        _filterFlowLayout.minimumInteritemSpacing = 10.01f;
    }
    return _filterFlowLayout;
}
- (UICollectionViewFlowLayout *)flowLayout {
    if (_flowLayout == nil) {
        _flowLayout = [[UICollectionViewFlowLayout alloc]init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 0.01f;
        _flowLayout.minimumInteritemSpacing = 0.01f;
    }
    return _flowLayout;
}
- (UICollectionView *)filter {
    if (_filter == nil) {
        CGRect wb = kGHKeyWindowBounds;
        CGFloat winW = CGRectGetWidth(wb);
        CGFloat winH = CGRectGetHeight(wb);
        _filter = [[UICollectionView alloc]initWithFrame:CGRectMake(winW * 0.1, 0, winW * 0.9, winH - kFilterButtonHeight - kGHSafeAreaBottomHeight) collectionViewLayout:self.filterFlowLayout];
        _filter.delegate = self;
        _filter.dataSource = self;
        _filter.contentInset = UIEdgeInsetsMake(20, 10, 0, 10);
        _filter.backgroundColor = [UIColor whiteColor];
        [_filter registerClass:[GHDropMenuFilterTagItem class] forCellWithReuseIdentifier:@"GHDropMenuFilterTagItemID"];
        [_filter registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCellID"];
        [_filter registerClass:[GHDropMenuFilterSectionHeader class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"GHDropMenuFilterSectionHeaderID"];
        [_filter registerClass:[GHDropMenuFilterInputItem class] forCellWithReuseIdentifier:@"GHDropMenuFilterInputItemID"];
        [_filter registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionReusableViewID"];
        [_filter registerClass:[GHDropMenuFilterSingleInputItem class] forCellWithReuseIdentifier:@"GHDropMenuFilterSingleInputItemID"];
        [_filter registerClass:[GHDropMenuFilterTimeChoseItem class] forCellWithReuseIdentifier:@"GHDropMenuFilterTimeChoseItemID"];
    }
    return _filter;
}

- (UICollectionView *)collectionView {
    if (_collectionView == nil) {
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(kGHScreenWidth, 0, kGHScreenWidth, self.menuHeight) collectionViewLayout:self.flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.layer.borderColor = [UIColor clearColor].CGColor;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCellID"];
        [_collectionView registerClass:[GHDropMenuTitleItem class] forCellWithReuseIdentifier:@"GHDropMenuTitleItemID"];
    }
    return _collectionView;
}


- (UIView *)bottomLine {
    if (_bottomLine == nil) {
        _bottomLine = [[UIView alloc]init];
        _bottomLine.backgroundColor = [UIColor darkGrayColor];
        _bottomLine.alpha = .1;
    }
    return _bottomLine;
}
- (UIView *)topLine {
    if (_topLine == nil) {
        _topLine = [[UIView alloc]init];
        _topLine.backgroundColor = [UIColor darkGrayColor];
        _topLine.alpha = .1;
    }
    return _topLine;
}

- (void)dealloc {
    [self.ghPopupHostView removeFromSuperview];
    NSLog(@"释放了");
}
@end

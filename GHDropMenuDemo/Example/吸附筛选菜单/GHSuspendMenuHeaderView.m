//
//  GHSuspendMenuHeaderView.m
//  GHDropMenuDemo
//

#import "GHSuspendMenuHeaderView.h"
#import "GHDropMenu.h"
#import "GHDropMenuModel.h"

@interface GHSuspendMenuHeaderView ()
@property (nonatomic, strong, readwrite) GHDropMenu *dropMenu;
@end

@implementation GHSuspendMenuHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.tintColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)configureWithTableView:(UITableView *)tableView
                       section:(NSInteger)section
                    hostWidth:(CGFloat)hostWidth
                      delegate:(id<GHDropMenuDelegate>)delegate {
    if (!_dropMenu) {
        GHDropMenuModel *bootstrap = [[GHDropMenuModel alloc] init];
        bootstrap.recordSeleted = YES;
        bootstrap.titles = [bootstrap creatNormalDropMenuData];
        _dropMenu = [GHDropMenu creatDropMenuWithConfiguration:bootstrap
                                                         frame:CGRectMake(0, 0, hostWidth, 44)
                                            dropMenuTitleBlock:^(GHDropMenuModel *_Nonnull dropMenuModel) {
        } dropMenuTagArrayBlock:^(NSArray *_Nonnull tagArray) {
        }];
        _dropMenu.titleSeletedColor = [UIColor redColor];
        _dropMenu.titleNormalColor = [UIColor orangeColor];
        _dropMenu.titleSeletedImageName = @"up_normal";
        _dropMenu.titleNormalImageName = @"down_normal";
        _dropMenu.titleFont = [UIFont systemFontOfSize:11];
        _dropMenu.optionFont = [UIFont systemFontOfSize:20];
        _dropMenu.optionSeletedColor = [UIColor redColor];
        _dropMenu.optionNormalColor = [UIColor blueColor];
        _dropMenu.delegate = delegate;
        _dropMenu.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self.contentView addSubview:_dropMenu];
    }
    GHDropMenuModel *fresh = [[GHDropMenuModel alloc] init];
    fresh.recordSeleted = YES;
    fresh.titles = [fresh creatNormalDropMenuData];
    _dropMenu.configuration = fresh;
    _dropMenu.delegate = delegate;
    CGRect rectInTable = [tableView rectForHeaderInSection:section];
    CGRect rect = [tableView convertRect:rectInTable toView:tableView.superview];
    _dropMenu.tableY = CGRectGetMaxY(rect);
    _dropMenu.frame = CGRectMake(0, 0, hostWidth, 44);
}

@end

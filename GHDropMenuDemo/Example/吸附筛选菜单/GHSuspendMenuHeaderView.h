//
//  GHSuspendMenuHeaderView.h
//  GHDropMenuDemo
//

#import <UIKit/UIKit.h>
#import "GHDropMenu.h"

NS_ASSUME_NONNULL_BEGIN

/// 可复用的 section 头部，内部只创建一次 GHDropMenu，避免每次滚动都新建。
@interface GHSuspendMenuHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong, readonly) GHDropMenu *dropMenu;

- (void)configureWithTableView:(UITableView *)tableView
                       section:(NSInteger)section
                    hostWidth:(CGFloat)hostWidth
                      delegate:(id<GHDropMenuDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END

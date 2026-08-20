//
//  GHDropMenuWaterFallCell.h
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2019/1/19.
//  Copyright © 2019年 GHome. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GHDropMenuWaterFallCell;

@protocol GHDropMenuWaterFallCellDelegate <NSObject>
/** 点击瀑布流中的某个标签 */
- (void)waterFallCell:(GHDropMenuWaterFallCell *)cell didSelectTagAtIndex:(NSInteger)index;
@end

@interface GHDropMenuWaterFallCell : UITableViewCell
/** 瀑布流标签数组 */
@property (nonatomic , strong) NSMutableArray *tags;
/** 当前选中标签索引，-1 表示未选中 */
@property (nonatomic , assign) NSInteger selectedIndex;
@property (nonatomic , weak) id<GHDropMenuWaterFallCellDelegate> delegate;

- (CGFloat)getCellHeight;
@end

NS_ASSUME_NONNULL_END

//
//  GHDropMenuWaterFallCell.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2019/1/19.
//  Copyright © 2019年 GHome. All rights reserved.
//

#import "GHDropMenuWaterFallCell.h"

@interface GHDropMenuWaterFallCell()

@end

@implementation GHDropMenuWaterFallCell

- (CGFloat)getCellHeight {
    NSInteger n = self.tags.count;
    if (n <= 0) {
        return 44.f;
    }
    NSInteger rows = (n + 2) / 3;
    return 16.f + rows * 36.f;
}

@end

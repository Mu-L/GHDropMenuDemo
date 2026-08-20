//
//  GHDropMenuFilterTagItem.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2019/1/4.
//  Copyright © 2019年 GHome. All rights reserved.
//

#import "GHDropMenuFilterTagItem.h"
#import "GHDropMenuModel.h"

@interface GHDropMenuFilterTagItem()
@property (nonatomic , strong) UILabel *title;
@end
@implementation GHDropMenuFilterTagItem

- (void)setDropMenuModel:(GHDropMenuModel *)dropMenuModel {
    _dropMenuModel = dropMenuModel;
    self.title.text = dropMenuModel.tagName;
    if (dropMenuModel.tagSeleted) {
        self.title.backgroundColor = kGHThemeAccentColor;
        self.title.textColor = [UIColor whiteColor];
        self.title.layer.borderColor = kGHThemeAccentColor.CGColor;
    } else {
        self.title.backgroundColor = [UIColor whiteColor];
        self.title.textColor = kGHThemeSubTextColor;
        self.title.layer.borderColor = kGHThemeLineColor.CGColor;
    }
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self == [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.title.frame = CGRectMake(0, 0, self.frame.size.width , self.frame.size.height);
    self.title.layer.cornerRadius = self.frame.size.height * 0.5;
}
- (void)setupUI {
    [self addSubview:self.title];
    
}
- (void)tap:(UITapGestureRecognizer *)gesture {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropMenuFilterTagItem:dropMenuModel:)]) {
        [self.delegate dropMenuFilterTagItem:self dropMenuModel:self.dropMenuModel];
    }
}

- (UILabel *)title {
    if (_title == nil) {
        _title = [[UILabel alloc]init];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.userInteractionEnabled = YES;
        _title.text = @"1";
        _title.layer.masksToBounds = YES;
        _title.layer.cornerRadius = 15;
        _title.layer.borderColor = kGHThemeLineColor.CGColor;
        _title.layer.borderWidth = 1;
        _title.textColor = kGHThemeSubTextColor;
        _title.font = [UIFont systemFontOfSize:13];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 1;
        [_title addGestureRecognizer:tap];
        
    }
    return _title;
}
@end

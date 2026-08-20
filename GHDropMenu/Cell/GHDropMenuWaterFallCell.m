//
//  GHDropMenuWaterFallCell.m
//  GHDropMenuDemo
//
//  Created by zhaozhiwei on 2019/1/19.
//  Copyright © 2019年 GHome. All rights reserved.
//

#import "GHDropMenuWaterFallCell.h"
#import "GHDropMenuHeader.h"

@interface GHDropMenuWaterFallCell ()
@property (nonatomic , strong) NSMutableArray<UIButton *> *tagButtons;
@end

@implementation GHDropMenuWaterFallCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _selectedIndex = -1;
    }
    return self;
}

- (void)setTags:(NSMutableArray *)tags {
    _tags = tags;
    for (UIButton *button in self.tagButtons) {
        [button removeFromSuperview];
    }
    [self.tagButtons removeAllObjects];

    for (NSInteger i = 0; i < tags.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:tags[i] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13];
        button.tag = i;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 15;
        button.layer.borderWidth = 1;
        [button addTarget:self action:@selector(tagTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        [self.tagButtons addObject:button];
    }
    [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat padding = 16;
    CGFloat gap = 10;
    NSInteger columns = 3;
    CGFloat width = (self.contentView.bounds.size.width - padding * 2 - gap * (columns - 1)) / columns;
    CGFloat tagHeight = 30;
    for (NSInteger i = 0; i < self.tagButtons.count; i++) {
        NSInteger col = i % columns;
        NSInteger row = i / columns;
        UIButton *button = self.tagButtons[i];
        button.frame = CGRectMake(padding + col * (width + gap), 8 + row * 36, width, tagHeight);
        [self styleButton:button selected:(i == self.selectedIndex)];
    }
}

- (void)tagTapped:(UIButton *)sender {
    self.selectedIndex = sender.tag;
    [self setNeedsLayout];
    if (self.delegate && [self.delegate respondsToSelector:@selector(waterFallCell:didSelectTagAtIndex:)]) {
        [self.delegate waterFallCell:self didSelectTagAtIndex:sender.tag];
    }
}

- (void)styleButton:(UIButton *)button selected:(BOOL)selected {
    if (selected) {
        button.backgroundColor = kGHThemeAccentColor;
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.layer.borderColor = kGHThemeAccentColor.CGColor;
    } else {
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor:kGHThemeSubTextColor forState:UIControlStateNormal];
        button.layer.borderColor = kGHThemeLineColor.CGColor;
    }
}

- (CGFloat)getCellHeight {
    NSInteger n = self.tags.count;
    if (n <= 0) {
        return 44.f;
    }
    NSInteger rows = (n + 2) / 3;
    return 16.f + rows * 36.f;
}

- (NSMutableArray<UIButton *> *)tagButtons {
    if (!_tagButtons) {
        _tagButtons = [NSMutableArray array];
    }
    return _tagButtons;
}

@end

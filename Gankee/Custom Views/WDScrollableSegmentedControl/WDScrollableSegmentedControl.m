//
//  WDScrollableSegmentedControl.m
//
//  Created by Wildog on 1/28/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "WDScrollableSegmentedControl.h"

@interface WDScrollableSegmentedControl () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *indicator;

@end

@implementation WDScrollableSegmentedControl

- (instancetype)init {
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefaults];
    }
    return self;
}

- (void)setupDefaults {
    _padding = 10;
    _edgeMargin = 0;
    _indicatorHeight = 3;
    _indicatorColor = [UIColor colorWithRed:0.09 green:0.47 blue:0.42 alpha:1];
    _indicatorMoveDuration = 0.25;
    _buttonColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
    _buttonHighlightColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1];
    _buttonSelectedColor = [UIColor colorWithRed:0.09 green:0.47 blue:0.42 alpha:1];
    _font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.tag = -42;
    [self addSubview:_scrollView];
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    _indicator.backgroundColor = indicatorColor;
}

- (void)setButtonColor:(UIColor *)color forState:(UIControlState)state {
    for (UIButton *button in self.scrollView.subviews) {
        if (![button isKindOfClass:[UIButton class]]) continue;
        [button setTitleColor:color forState:state];
    }
    
    if (state == UIControlStateNormal) {
        self.buttonColor = color;
    } else if (state == UIControlStateHighlighted) {
        self.buttonHighlightColor = color;
    } else if (state == UIControlStateSelected) {
        self.buttonSelectedColor = color;
    }
}

- (void)setFont:(UIFont *)font {
    _font = font;
    self.buttons = self.buttons;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    if (selectedIndex == _selectedIndex) return;
    if (![[self.scrollView viewWithTag:selectedIndex] isKindOfClass:[UIButton class]]) return;
    
    UIButton *from = (UIButton *)[self.scrollView viewWithTag:_selectedIndex];
    UIButton *target = [self.scrollView viewWithTag:selectedIndex];
    [UIView transitionWithView:from duration:self.indicatorMoveDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        from.selected = NO;
    } completion:nil];
    [UIView transitionWithView:target duration:self.indicatorMoveDuration options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        target.selected = YES;
    } completion:nil];
    _selectedIndex = target.tag;
    
    if (!self.indicator) {
        self.indicator = [[UIView alloc] initWithFrame:CGRectMake(target.frame.origin.x + self.padding, self.frame.size.height - self.indicatorHeight, target.frame.size.width - self.padding * 2, self.indicatorHeight)];
        self.indicator.backgroundColor = self.indicatorColor;
        [self.scrollView addSubview:self.indicator];
    } else {
        [self scrollButtonCentered:target];
        [UIView animateWithDuration:self.indicatorMoveDuration animations:^{
            self.indicator.frame = CGRectMake(target.frame.origin.x + self.padding, self.indicator.frame.origin.y, target.titleLabel.frame.size.width, self.indicator.frame.size.height);
        }];
    }
}

- (void)setButtons:(NSArray *)buttons {
    if (buttons.count == 0) return;
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    _buttons = buttons;
    _selectedIndex = -1;
    _indicator = nil;
    
    CGFloat x = self.edgeMargin;
    for (NSUInteger i = 0; i < self.buttons.count; i++) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 0, 20, self.frame.size.height)];
        button.tag = i;
        [button setTitle:self.buttons[i] forState:UIControlStateNormal];
        [button setTitleColor:self.buttonColor forState:UIControlStateNormal];
        [button setTitleColor:self.buttonHighlightColor forState:UIControlStateHighlighted];
        [button setTitleColor:self.buttonSelectedColor forState:UIControlStateSelected];
        [button.titleLabel setFont:self.font];
        [button addTarget:self action:@selector(buttonDidSelect:) forControlEvents:UIControlEventTouchUpInside];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, self.padding, 0, self.padding);
        [button sizeToFit];
        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, button.frame.size.width, self.frame.size.height - self.indicatorHeight);
        x = CGRectGetMaxX(button.frame);
        [self.scrollView addSubview:button];
    }
    
    self.scrollView.contentSize = CGSizeMake(x + self.edgeMargin, self.frame.size.height);
    self.selectedIndex = 0;
}

- (void)buttonDidSelect:(UIButton *)sender {
    if ([(NSObject *)self.delegate respondsToSelector:@selector(didSelectButtonAtIndex:)]) {
        [self.delegate didSelectButtonAtIndex:sender.tag];
    }
    self.selectedIndex = sender.tag;
}

- (void)scrollButtonCentered:(UIButton *)button {
    CGRect centeredRect = CGRectMake(button.frame.origin.x + button.frame.size.width/2.0 - self.frame.size.width/2.0, button.frame.origin.y + button.frame.size.height/2.0 - self.frame.size.height/2.0, self.frame.size.width, self.frame.size.height);
    [self.scrollView scrollRectToVisible:centeredRect animated:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    self.selectedIndex = self.selectedIndex;
}

@end

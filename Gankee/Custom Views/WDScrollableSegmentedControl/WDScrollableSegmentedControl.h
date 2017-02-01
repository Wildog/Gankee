//
//  WDScrollableSegmentedControl.h
//
//  Created by Wildog on 1/28/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@protocol WDScrollableSegmentedControlDelegate;

@interface WDScrollableSegmentedControl : UIControl

// space between buttons, default to 10
@property (nonatomic, assign) IBInspectable CGFloat padding;

// space before first button and after last button, default to 0
@property (nonatomic, assign) IBInspectable CGFloat edgeMargin;

// indicator height, default to 3.0
@property (nonatomic, assign) IBInspectable CGFloat indicatorHeight;

// indicator animation duration, default to 0.25
@property (nonatomic, assign) IBInspectable CGFloat indicatorMoveDuration;

// indicator color
@property (nonatomic, strong) IBInspectable UIColor *indicatorColor;

// button color at normal state
@property (nonatomic, strong) IBInspectable UIColor *buttonColor;

// button color at highlighted state
@property (nonatomic, strong) IBInspectable UIColor *buttonHighlightColor;

// button color at selected state
@property (nonatomic, strong) IBInspectable UIColor *buttonSelectedColor;

// button font, default to system font 15pt
@property (nonatomic, strong) IBInspectable UIFont *font;

@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, strong) id<WDScrollableSegmentedControlDelegate> delegate;

// use this method to change button color dynamically
- (void)setButtonColor:(UIColor *)color forState:(UIControlState)state;

@end

@protocol WDScrollableSegmentedControlDelegate

@required

- (void)didSelectButtonAtIndex:(NSInteger)index;

@end

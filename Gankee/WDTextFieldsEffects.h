//
//  WDTextFieldsEffects.h
//  Eavescrob
//
//  Created by Wildog on 11/19/16.
//  Copyright © 2016 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, AnimationType) {
    textEntry,
    textDisplay
};

IB_DESIGNABLE
@interface WDTextFieldsEffects : UITextField

- (void)animateViewsForTextEntry;
- (void)animateViewsForTextDisplay;
- (void)drawViewsForRect:(CGRect)rect;
- (void)updateViewsForBoundsChange:(CGRect)rect;
- (void)drawRect:(CGRect)rect;
- (void)willMoveToSuperview:(UIView *)newSuperview;
- (void)textFieldDidBeginEditing;
- (void)textFieldDidEndEditing;
- (void)prepareForInterfaceBuilder;

@end

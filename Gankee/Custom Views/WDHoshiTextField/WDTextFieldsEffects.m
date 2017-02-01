//
//  WDTextFieldsEffects.m
//  Eavescrob
//
//  Created by Wildog on 11/19/16.
//  Copyright © 2016 Wildog. All rights reserved.
//

#import "WDTextFieldsEffects.h"

@implementation WDTextFieldsEffects

- (void)animateViewsForTextEntry {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

- (void)animateViewsForTextDisplay {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

- (void)drawViewsForRect:(CGRect)rect {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

- (void)updateViewsForBoundsChange:(CGRect)rect {
    NSAssert(NO, @"This is an abstract method and should be overridden");
}

- (void)drawRect:(CGRect)rect {
    [self drawViewsForRect:rect];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    
}

- (void)setText:(NSString *)text {
    [super setText:text];
    if (text.length == 0) {
        [self animateViewsForTextDisplay];
    } else {
        [self animateViewsForTextEntry];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview != nil) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidEndEditing) name:UITextFieldTextDidEndEditingNotification object:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidBeginEditing) name:UITextFieldTextDidBeginEditingNotification object:self];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)textFieldDidBeginEditing {
    [self animateViewsForTextEntry];
}

- (void)textFieldDidEndEditing {
    [self animateViewsForTextDisplay];
}

- (void)prepareForInterfaceBuilder {
    [self drawViewsForRect:self.frame];
}

@end

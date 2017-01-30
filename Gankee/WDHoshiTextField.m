//
//  WDHoshiTextField.m
//  Eavescrob
//
//  Created by Wildog on 11/19/16.
//  Copyright © 2016 Wildog. All rights reserved.
//

#import "WDHoshiTextField.h"
#define borderThicknessActive 1.5
#define borderThicknessInactive 1
#define placeholderInsets CGPointMake(0, 7)
#define textFieldInsets CGPointMake(0, 8)

@implementation WDHoshiTextField

- (void)setBorderInactiveColor:(UIColor *)borderInactiveColor {
    _borderInactiveColor = borderInactiveColor;
    [self updateBorder];
}

- (void)setBorderActiveColor:(UIColor *)borderActiveColor {
    _borderActiveColor = borderActiveColor;
    [self updateBorder];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    [self updatePlaceholder];
}

- (void)setPlaceholderFontScale:(CGFloat)placeholderFontScale {
    _placeholderFontScale = placeholderFontScale;
    [self updatePlaceholder];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    [self updateBorder];
    [self updatePlaceholder];
}

- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = [[UILabel alloc] init];
    }
    return _placeholderLabel;
}

- (CALayer *)activeBorderLayer {
    if (!_activeBorderLayer) {
        _activeBorderLayer = [CALayer layer];
    }
    return _activeBorderLayer;
}

- (CALayer *)inactiveBorderLayer {
    if (!_inactiveBorderLayer) {
        _inactiveBorderLayer = [CALayer layer];
    }
    return _inactiveBorderLayer;
}

- (void)drawViewsForRect:(CGRect)rect {
    CGRect frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    self.placeholderLabel.frame = CGRectInset(frame, placeholderInsets.x, placeholderInsets.y);
    self.placeholderLabel.font = [self placeholderFontFromFont:self.font];
    self.placeholderLabel.textColor = self.placeholderColor;
    
    [self updateBorder];
    [self updatePlaceholder];
    
    [self.layer addSublayer:self.inactiveBorderLayer];
    [self.layer addSublayer:self.activeBorderLayer];
    [self addSubview:self.placeholderLabel];
}

- (void)animateViewsForTextEntry {
    if (self.text.length == 0) {
        [UIView animateWithDuration:0.6 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.placeholderLabel.frame = CGRectMake(10, self.placeholderLabel.frame.origin.y, self.placeholderLabel.frame.size.width, self.placeholderLabel.frame.size.height);
            self.placeholderLabel.alpha = 0;
        } completion:nil];
    }
    
    [self layoutPlaceholderInTextRect];
    self.placeholderLabel.frame = CGRectMake(self.activePlaceholderPoint.x, self.activePlaceholderPoint.y, self.placeholderLabel.frame.size.width, self.placeholderLabel.frame.size.height);
    
    [UIView animateWithDuration:0.4 animations:^{
        self.placeholderLabel.alpha = 0.5;
    }];
    
    self.activeBorderLayer.frame = [self rectForBorder:borderThicknessActive isFilled:YES];
}

- (void)animateViewsForTextDisplay {
    if (self.text.length == 0) {
        [UIView animateWithDuration:0.45 delay:0.0 usingSpringWithDamping:0.8 initialSpringVelocity:2.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self layoutPlaceholderInTextRect];
            self.placeholderLabel.alpha = 1;
        } completion:nil];
        
        self.activeBorderLayer.frame = [self rectForBorder:borderThicknessActive isFilled:NO];
    }
}

- (void)updateBorder {
    self.inactiveBorderLayer.frame = [self rectForBorder:borderThicknessInactive isFilled:YES];
    self.inactiveBorderLayer.backgroundColor = self.borderInactiveColor.CGColor;
    
    self.activeBorderLayer.frame = [self rectForBorder:borderThicknessActive isFilled:NO];
    self.activeBorderLayer.backgroundColor = self.borderActiveColor.CGColor;
}

- (void)updatePlaceholder {
    self.placeholderLabel.text = self.placeholder;
    self.placeholderLabel.textColor = self.placeholderColor;
    [self.placeholderLabel sizeToFit];
    [self layoutPlaceholderInTextRect];
    
    if (self.isFirstResponder || self.text.length != 0) {
        [self animateViewsForTextEntry];
    }
}

- (CGRect)rectForBorder:(CGFloat)thickness isFilled:(BOOL)isFilled {
    if (isFilled) {
        return CGRectMake(0, self.frame.size.height - thickness, self.frame.size.width, thickness);
    } else {
        return CGRectMake(0, self.frame.size.height - thickness, 0, thickness);
    }
}

- (void)layoutPlaceholderInTextRect {
    CGRect textRect = [self textRectForBounds:self.bounds];
    CGFloat originX = textRect.origin.x;
    if (self.textAlignment == NSTextAlignmentCenter) {
        originX += textRect.size.width / 2 - self.placeholderLabel.bounds.size.width / 2;
    } else if (self.textAlignment == NSTextAlignmentRight) {
        originX += textRect.size.width - self.placeholderLabel.bounds.size.width;
    }
    self.placeholderLabel.frame = CGRectMake(originX, textRect.size.height / 2, self.placeholderLabel.bounds.size.width, self.placeholderLabel.bounds.size.height);
    self.activePlaceholderPoint = CGPointMake(self.placeholderLabel.frame.origin.x, self.placeholderLabel.frame.origin.y - self.placeholderLabel.frame.size.height - placeholderInsets.y);
}

- (UIFont *)placeholderFontFromFont:(UIFont *)font {
    return [UIFont fontWithName:font.fontName size:font.pointSize * self.placeholderFontScale];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectOffset(bounds, textFieldInsets.x, textFieldInsets.y - 1);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectOffset(bounds, textFieldInsets.x, textFieldInsets.y - 1);
}

@end

//
//  WDHoshiTextField.h
//  Eavescrob
//
//  Created by Wildog on 11/19/16.
//  Copyright © 2016 Wildog. All rights reserved.
//

#import "WDTextFieldsEffects.h"

IB_DESIGNABLE
@interface WDHoshiTextField : WDTextFieldsEffects

@property (strong, nonatomic) IBInspectable UIColor *borderInactiveColor;
@property (strong, nonatomic) IBInspectable UIColor *borderActiveColor;
@property (strong, nonatomic) IBInspectable UIColor *placeholderColor;
@property (assign, nonatomic) IBInspectable CGFloat placeholderFontScale;
@property (strong, nonatomic) CALayer *inactiveBorderLayer;
@property (strong, nonatomic) CALayer *activeBorderLayer;
@property (assign, nonatomic) CGPoint activePlaceholderPoint;
@property (strong, nonatomic) UILabel *placeholderLabel;

@end

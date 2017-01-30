//
//  GKPieView.h
//  Gankee
//
//  Created by Wildog on 1/27/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKPieLayer.h"

@interface GKPieView : UIView

@property (nonatomic, strong) GKPieLayer *pieLayer;

- (id)initWithFrame:(CGRect)frame
         startAngle:(CGFloat)startAngle
           endAngle:(CGFloat)endAngle
          fillColor:(UIColor *)fillColor
        strokeColor:(UIColor *)strokeColor
        strokeWidth:(CGFloat)strokeWidth;

- (void)startAnimating;

@end

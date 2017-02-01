//
//  GKPieLayer.h
//  Gankee
//
//  Created by Wildog on 1/27/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

#define DEG2RAD(angle) angle*M_PI/180.0

@interface GKPieLayer : CALayer

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat strokeWidth;

@end

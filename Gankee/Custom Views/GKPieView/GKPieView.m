//
//  GKPieView.m
//  Gankee
//
//  Created by Wildog on 1/27/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKPieView.h"

@implementation GKPieView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle fillColor:(UIColor *)fillColor strokeColor:(UIColor *)strokeColor strokeWidth:(CGFloat)strokeWidth {
    self = [super initWithFrame:frame];
    if (self) {
        _pieLayer = [GKPieLayer layer];
        _pieLayer.startAngle = DEG2RAD(startAngle);
        _pieLayer.endAngle = DEG2RAD(endAngle);
        _pieLayer.fillColor = fillColor;
        _pieLayer.strokeColor = strokeColor;
        _pieLayer.strokeWidth = strokeWidth;
        _pieLayer.frame = self.bounds;
        _pieLayer.contentsScale = [UIScreen mainScreen].scale;
        
        [self.layer addSublayer:self.pieLayer];
    }
    return self;
}

- (void)startAnimating {
    [_pieLayer removeAllAnimations];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"endAngle"];
    anim.fromValue = @(_pieLayer.endAngle);
    anim.toValue = @(DEG2RAD(350));
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.repeatCount = HUGE_VALF;
    anim.autoreverses = 1;
    anim.duration = 0.3;
    anim.removedOnCompletion = NO;
    [_pieLayer addAnimation:anim forKey:@"eatingAnimation"];
}


@end

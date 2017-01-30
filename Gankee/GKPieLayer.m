//
//  GKPieLayer.m
//  Gankee
//
//  Created by Wildog on 1/27/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKPieLayer.h"

@implementation GKPieLayer

@dynamic startAngle, endAngle;

/*
- (id<CAAction>)actionForKey:(NSString *)event {
    if ([event isEqualToString:@"startAngle"] ||
        [event isEqualToString:@"endAngle"]) {
        //return [self makeAnimationForKey:event];
    }
    return [super actionForKey:event];
}

- (CABasicAnimation *)makeAnimationForKey:(NSString *)key {
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:key];
	anim.fromValue = [[self presentationLayer] valueForKey:key];
	anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	anim.duration = 0.5;

	return anim;
}
 */

- (instancetype)initWithLayer:(id)layer {
    if (self = [super initWithLayer:layer]) {
        if ([layer isKindOfClass:[GKPieLayer class]]) {
            GKPieLayer *other = (GKPieLayer *)layer;
            self.startAngle = other.startAngle;
            self.endAngle = other.endAngle;
            self.fillColor = other.fillColor;
            self.strokeColor = other.strokeColor;
            self.strokeWidth = other.strokeWidth;
        }
    }
    return self;
}

+ (BOOL)needsDisplayForKey:(NSString *)key {
    if ([key isEqualToString:@"startAngle"] ||
        [key isEqualToString:@"endAngle"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx {
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGFloat radius = MIN(center.x, center.y) - self.strokeWidth;
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, center.x, center.y);
    
    CGPoint p1 = CGPointMake(center.x + radius * cosf(self.startAngle), center.y + radius * sinf(self.startAngle));
    CGContextAddLineToPoint(ctx, p1.x, p1.y);
    
    int clockwise = self.startAngle > self.endAngle;
    CGContextAddArc(ctx, center.x, center.y, radius, self.startAngle, self.endAngle, clockwise);
    
    CGContextClosePath(ctx);
    
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, self.strokeColor.CGColor);
    CGContextSetLineWidth(ctx, self.strokeWidth);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    CGContextDrawPath(ctx, kCGPathFillStroke);
}

@end

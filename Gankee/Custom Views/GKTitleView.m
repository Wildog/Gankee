//
//  GKTitleView.m
//  Gankee
//
//  Created by Wildog on 11/15/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKTitleView.h"

@implementation GKTitleView

- (CGSize)intrinsicContentSize {
    if (self.preferredWidth > 0) {
        return CGSizeMake(self.preferredWidth, 44);
    }
    return UILayoutFittingExpandedSize;
}

- (void)setValue:(id)value forKeyPath:(NSString *)keyPath {
    if ([keyPath isEqualToString:@"preferredWidth"]) {
        self.preferredWidth = [value doubleValue];
    }
}

@end

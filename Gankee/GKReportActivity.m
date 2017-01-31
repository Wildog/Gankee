//
//  GKReportActivity.m
//  Gankee
//
//  Created by Wildog on 1/29/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKReportActivity.h"

@implementation GKReportActivity

- (id)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        [self prepareWithURL:url];
    }
    return self;
}

- (NSString *)activityType {
    return @"GKReportActivityType";
}

- (NSString *)activityTitle {
    return @"举报内容";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"report"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSURL* url = nil;
    for (NSObject* obj in activityItems) {
        if ([obj isKindOfClass:[NSURL class]]) {
            url = (NSURL*)obj;
        }
    }
    
    [self prepareWithURL:url];
}

- (void)prepareWithURL:(NSURL*)url {
    activityViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"report_vc"];
}

- (UIViewController *)activityViewController {
    return activityViewController;
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}


@end

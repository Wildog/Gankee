//
//  GKFavoriteActivity.m
//  Gankee
//
//  Created by Wildog on 2/1/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKFavoriteActivity.h"
#import <RKDropdownAlert.h>

@implementation GKFavoriteActivity

- (id)initWithItem:(GKItem *)item {
    self = [super init];
    if (self) {
        _item = item;
    }
    return self;
}

- (NSString *)activityType {
    return @"GKFavoriteActivityType";
}

- (NSString *)activityTitle {
    return @"加入收藏";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"star-outline"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    [GKFavoriteHelper createFavoriteItemFromItem:_item];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [RKDropdownAlert title:@"收藏失败" message:error.localizedDescription];
        } else {
            [RKDropdownAlert title:@"已收藏" backgroundColor:[UIColor colorWithRed:0.16 green:0.73 blue:0.61 alpha:1] textColor:[UIColor whiteColor] time:1];
        }
    }];
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

@end

//
//  GKFavoriteActivity.m
//  Gankee
//
//  Created by Wildog on 2/1/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKUnfavoriteActivity.h"
#import <RKDropdownAlert.h>

@implementation GKUnfavoriteActivity

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
    return @"取消收藏";
}

- (UIImage *)activityImage {
    return [UIImage imageNamed:@"star-filled"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    GKFavoriteItem *favorite = [GKFavoriteHelper fetchFavoriteItemFromItem:_item];
    [favorite MR_deleteEntity];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            [RKDropdownAlert title:@"未能取消收藏" message:error.localizedDescription];
        } else {
            [RKDropdownAlert title:@"已取消收藏" backgroundColor:MADISON textColor:[UIColor whiteColor] time:1];
        }
    }];
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryAction;
}

@end

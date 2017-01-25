//
//  GKAPIManager.h
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>

typedef NS_ENUM(NSUInteger, GKCategory) {
    GKCategoryAll,
    GKCategoryIOS,
    GKCategoryAndroid,
    GKCategoryApp,
    GKCategoryFrontend,
    GKCategoryExplore,
    GKCategoryExt,
    GKCategoryVideo,
    GKCategoryWelfare
};

@interface GKClient : NSObject

+ (instancetype)client;

- (RACSubject *)dataForCategory:(GKCategory)category
                    onPage:(NSUInteger)page
                 withCount:(NSUInteger)count
                randomize:(BOOL)randomize;

- (RACSignal *)dataForDay:(NSString *)day;

- (RACSignal *)availableDays;

@end

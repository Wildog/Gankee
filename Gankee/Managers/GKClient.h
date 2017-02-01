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

- (RACSignal *)dataForCategory:(GKCategory)category
                    onPage:(NSUInteger)page
                 withCount:(NSUInteger)count
                  onSearch:(NSString *)search
                 randomize:(BOOL)randomize;

- (RACSignal *)dataForDay:(NSString *)day;

- (RACSignal *)availableDays;

- (RACSignal *)submitURL:(NSString *)url desc:(NSString *)desc category:(NSString *)category author:(NSString *)author;

@end

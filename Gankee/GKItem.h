//
//  GKItemModel.h
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <YYModel.h>

@interface GKItem : NSObject

@property (nonatomic, strong) NSString *itemID;
@property (nonatomic, strong) NSDate *created;
@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSDate *published;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *author;

- (NSString *)imageURLStringForBanner;

@end

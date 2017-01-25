//
//  GKItemModel.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKItem.h"

@implementation GKItem

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"itemID" : @"_id",
             @"created" : @"createdAt",
             @"published": @"publishedAt",
             @"category": @"type",
             @"author": @"who"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSArray *imageURLs = dic[@"images"];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageURLs.count];
    for (NSString *imageURL in imageURLs) {
        NSString *urlString = imageURL;
        if ([imageURL hasPrefix:@"http://"]) {
            urlString = [imageURL stringByReplacingCharactersInRange:NSMakeRange(0, 7) withString:@"https://"];
        }
        NSURL *url = [NSURL URLWithString:urlString];
        [images addObject:url];
    }
    _images = images;
    return YES;
}

@end

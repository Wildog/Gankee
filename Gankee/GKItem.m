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
    return @{@"itemID" : @[@"_id", @"ganhuo_id"],
             @"created": @"createdAt",
             @"published": @"publishedAt",
             @"category": @"type",
             @"author": @"who"};
}

- (BOOL)modelCustomTransformFromDictionary:(NSDictionary *)dic {
    NSArray *imageURLs = dic[@"images"];
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageURLs.count];
    for (NSString *imageURL in imageURLs) {
        if ([imageURL containsString:@"img.gank.io"] || [imageURL containsString:@"https://"]) {
            NSString *urlString = [NSString stringWithFormat:@"%@%@", imageURL, @"?imageView2/2/w/200/format/jpg/interlace/1"];
            NSURL *url = [NSURL URLWithString:urlString];
            [images addObject:url];
        }
    }
    _images = images;
    return YES;
}

- (NSString *)imageURLStringForBanner {
    if (!self.images[0]) {
        return nil;
    }
    
    NSString *URLString = [self.images[0] absoluteString];
    return [URLString stringByReplacingOccurrencesOfString:@"2/w/200" withString:@"1/w/600/h/300"];
}

@end

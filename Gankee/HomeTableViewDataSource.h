//
//  HomeTableViewDataSource.h
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKItem.h"

typedef void (^HomeTableViewCellConfigureBlock)(id cell, GKItem *item);

@interface HomeTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSArray *> *dict;

- (id)initWithDict:(NSDictionary<NSString *, NSArray *> *)dict
    cellIdentifier:(NSString *)identifier
configureCellBlock:(HomeTableViewCellConfigureBlock)configureCellBlock;

- (GKItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

@end

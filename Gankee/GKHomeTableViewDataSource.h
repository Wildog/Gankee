//
//  HomeTableViewDataSource.h
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKItem.h"

typedef void (^GKHomeTableViewCellConfigureBlock)(id cell, GKItem *item);

@interface GKHomeTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSDictionary<NSString *, NSArray *> *dict;

- (id)initWithDict:(NSDictionary<NSString *, NSArray *> *)dict
    cellIdentifier:(NSString *)identifier
configureCellBlock:(GKHomeTableViewCellConfigureBlock)configureCellBlock
    altCellIdentifier:(NSString *)altIdentifier
altConfigureCellBlock:(GKHomeTableViewCellConfigureBlock)altConfigureCellBlock;

- (GKItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

@end

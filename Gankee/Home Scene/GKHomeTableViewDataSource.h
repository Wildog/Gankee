//
//  HomeTableViewDataSource.h
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKItem.h"

@interface GKHomeTableViewDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, copy) NSDictionary<NSString *, NSArray *> *dict;

- (id)initWithDict:(NSDictionary<NSString *, NSArray *> *)dict
    cellIdentifier:(NSString *)identifier
configureCellBlock:(GKCellConfigureBlock)configureCellBlock
    altCellIdentifier:(NSString *)altIdentifier
altConfigureCellBlock:(GKCellConfigureBlock)altConfigureCellBlock;

- (GKItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

@end

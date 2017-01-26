//
//  GKHomeViewModel.h
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveObjC.h>
#import "GKItem.h"
#import "GKClient.h"
#import "GKHomeTableViewDataSource.h"

@interface GKHomeViewModel : NSObject

@property (nonatomic, strong) NSString *currentDay;
@property (nonatomic, strong, readonly) NSArray *availableDays;
@property (nonatomic, strong, readonly) NSArray<GKItem *> *randomItems;
@property (nonatomic, strong, readonly) GKHomeTableViewDataSource *dataSource;

- (instancetype)initWithCellIdentifier:(NSString *)identifier
                    configureCellBlock:(GKHomeTableViewCellConfigureBlock)configureCellBlock
                     altCellIdentifier:(NSString *)altIdentifier
                 altConfigureCellBlock:(GKHomeTableViewCellConfigureBlock)altConfigureCellBlock;

- (RACSignal *)itemsForCurrentDaySignal;
- (RACSignal *)availableDaysSignal;
- (RACSignal *)randomItemsSignal;

@end

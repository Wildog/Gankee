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

@property (nonatomic, copy) NSString *currentDay;
@property (nonatomic, assign) NSInteger currentRandomItemIndex;
@property (nonatomic, copy, readonly) NSArray *availableDays;
@property (nonatomic, copy, readonly) NSArray<GKItem *> *randomItems;
@property (nonatomic, strong, readonly) GKHomeTableViewDataSource *dataSource;
@property (nonatomic, strong, readonly) RACSubject *allDataLoadedSignal;

- (instancetype)initWithCellIdentifier:(NSString *)identifier
                    configureCellBlock:(GKCellConfigureBlock)configureCellBlock
                     altCellIdentifier:(NSString *)altIdentifier
                 altConfigureCellBlock:(GKCellConfigureBlock)altConfigureCellBlock;

- (RACSignal *)itemsForCurrentDaySignal;
- (RACSignal *)availableDaysSignal;
- (RACSignal *)randomItemsSignal;

@end

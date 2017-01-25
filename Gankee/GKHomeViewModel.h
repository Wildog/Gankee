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
#import "HomeTableViewDataSource.h"

@interface GKHomeViewModel : NSObject

@property (nonatomic, strong) NSString *currentDay;
@property (nonatomic, strong, readonly) NSArray *availableDays;
@property (nonatomic, strong, readonly) HomeTableViewDataSource *dataSource;

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(HomeTableViewCellConfigureBlock)configureCellBlock;

- (RACSignal *)itemsForCurrentDaySignal;
- (RACSignal *)availableDaysSignal;

@end

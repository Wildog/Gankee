//
//  GKHomeViewModel.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKHomeViewModel.h"

@interface GKHomeViewModel ()

@property (nonatomic, strong) NSArray *availableDays;

@end

@implementation GKHomeViewModel

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(HomeTableViewCellConfigureBlock)configureCellBlock {
    self = [super init];
    if (self) {
        _dataSource = [[HomeTableViewDataSource alloc] initWithDict:@{} cellIdentifier:cellIdentifier configureCellBlock:configureCellBlock];
        
        // update currentDay for the first time availableDays updated
        [RACObserve(self, availableDays) subscribeNext:^(NSArray *x) {
            if (!self.currentDay) {
                self.currentDay = self.availableDays[0];
            }
        }];
    }
    return self;
}

- (RACSignal *)itemsForCurrentDaySignal {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[[GKClient client] dataForDay:self.currentDay] subscribeNext:^(id  _Nullable x) {
            self.dataSource.dict = x;
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } error:^(NSError * _Nullable error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSignal *)availableDaysSignal {
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[[GKClient client] availableDays] subscribeNext:^(id  _Nullable x) {
            self.availableDays = x;
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } error:^(NSError * _Nullable error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

@end

//
//  GKHomeViewModel.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKHomeViewModel.h"
#import "RACEXTScope.h"

@interface GKHomeViewModel ()

@property (nonatomic, strong) NSArray *availableDays;

@end

@implementation GKHomeViewModel

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(GKHomeTableViewCellConfigureBlock)configureCellBlock altCellIdentifier:(NSString *)altIdentifier altConfigureCellBlock:(GKHomeTableViewCellConfigureBlock)altConfigureCellBlock {
    self = [super init];
    if (self) {
        _dataSource = [[GKHomeTableViewDataSource alloc] initWithDict:@{} cellIdentifier:cellIdentifier configureCellBlock:configureCellBlock altCellIdentifier:altIdentifier altConfigureCellBlock:altConfigureCellBlock];
        
        // update currentDay for the first time availableDays updated
        @weakify(self)
        [RACObserve(self, availableDays) subscribeNext:^(NSArray *x) {
            @strongify(self)
            if (!self.currentDay && self.availableDays) {
                self.currentDay = self.availableDays[0];
            }
        }];
    }
    return self;
}

- (RACSignal *)itemsForCurrentDaySignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[[GKClient client] dataForDay:self.currentDay] subscribeNext:^(id  _Nullable x) {
            @strongify(self)
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
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[[GKClient client] availableDays] subscribeNext:^(id  _Nullable x) {
            @strongify(self)
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

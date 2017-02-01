//
//  GKHomeViewModel.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKHomeViewModel.h"
#import <RACEXTScope.h>

@interface GKHomeViewModel ()

@property (nonatomic, strong) NSArray *availableDays;
@property (nonatomic, strong) NSArray *randomItems;
@property (nonatomic, strong) RACSubject *allDataLoadedSignal;

@end

@implementation GKHomeViewModel

- (id)init {
    return nil;
}

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier configureCellBlock:(GKCellConfigureBlock)configureCellBlock altCellIdentifier:(NSString *)altIdentifier altConfigureCellBlock:(GKCellConfigureBlock)altConfigureCellBlock {
    self = [super init];
    if (self) {
        _dataSource = [[GKHomeTableViewDataSource alloc] initWithDict:@{} cellIdentifier:cellIdentifier configureCellBlock:configureCellBlock altCellIdentifier:altIdentifier altConfigureCellBlock:altConfigureCellBlock];
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

- (RACSignal *)randomItemsSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[[GKClient client] dataForCategory:GKCategoryAll onPage:1 withCount:20 onSearch:nil randomize:YES] subscribeNext:^(NSArray<GKItem *> *items) {
            @strongify(self)
            NSArray *filtered = [items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"images.@count > 0"]];
            self.randomItems = [filtered subarrayWithRange:NSMakeRange(0, MIN(5, filtered.count))];
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } error:^(NSError * _Nullable error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

- (RACSubject *)allDataLoadedSignal {
    if (!_allDataLoadedSignal) {
        _allDataLoadedSignal = [RACSubject subject];
    }
    return _allDataLoadedSignal;
}

@end

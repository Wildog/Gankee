//
//  GKCategoryViewModel.m
//  Gankee
//
//  Created by Wildog on 1/28/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <RACEXTScope.h>
#import "GKResultTableViewModel.h"

@interface GKResultTableViewModel ()

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) GKCellConfigureBlock configureCellBlock;
@property (nonatomic, copy) NSString *altCellIdentifier;
@property (nonatomic, copy) GKCellConfigureBlock altConfigureCellBlock;

@property (nonatomic, strong) NSMutableArray *items;

@end

@implementation GKResultTableViewModel

- (id)init {
    return nil;
}

- (id)initWithItems:(NSArray *)items category:(GKCategory)category pageSize:(NSUInteger)pageSize cellIdentifier:(NSString *)identifier configureCellBlock:(GKCellConfigureBlock)configureCellBlock altCellIdentifier:(NSString *)altIdentifier altConfigureCellBlock:(GKCellConfigureBlock)altConfigureCellBlock {
    self = [super init];
    if (self) {
        self.items = [items mutableCopy];
        self.category = category;
        self.pageSize = pageSize;
        self.cellIdentifier = identifier;
        self.configureCellBlock = configureCellBlock;
        self.altCellIdentifier = altIdentifier;
        self.altConfigureCellBlock = altConfigureCellBlock;
        self.currentPage = 1;
        self.noMoreResults = YES;
    }
    return self;
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKItem *item = _items[indexPath.row];
    UITableViewCell *cell = nil;
    if (self.category == GKCategoryAll) {
        cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
        self.configureCellBlock(cell, item);
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:self.altCellIdentifier forIndexPath:indexPath];
        self.altConfigureCellBlock(cell, item);
    }
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor colorWithRed:0.92 green:0.92 blue:0.94 alpha:1];
    cell.selectedBackgroundView = bgView;
    return cell;
}

- (RACSignal *)moreItemsSignal {
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [[[GKClient client] dataForCategory:self.category onPage:self.currentPage withCount:self.pageSize onSearch:self.search randomize:NO] subscribeNext:^(NSArray *x) {
            @strongify(self)
            if (x.count == 0) {
                NSError *alert = nil;
                if (self.search.length > 0 && self.currentPage <= 1) {
                    alert = [NSError errorWithDomain:@"GKErrorDomain" code:-43 userInfo:@{NSLocalizedDescriptionKey: @"未找到搜索结果"}];
                } else {
                    alert = [NSError errorWithDomain:@"GKErrorDomain" code:-42 userInfo:@{NSLocalizedDescriptionKey: @"已加载完全部数据"}];
                }
                self.noMoreResults = YES;
                [subscriber sendError:alert];
            } else {
                if (self.currentPage <= 1) {
                    self.items = [NSMutableArray arrayWithCapacity:self.pageSize];
                }
                [self.items addObjectsFromArray:x];
                self.noMoreResults = NO;
                [subscriber sendNext:nil];
                [subscriber sendCompleted];
            }
        } error:^(NSError * _Nullable error) {
            [subscriber sendError:error];
        }];
        return nil;
    }];
}

@end

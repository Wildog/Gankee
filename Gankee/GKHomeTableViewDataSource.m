//
//  HomeTableViewDataSource.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKHomeTableViewDataSource.h"

@interface GKHomeTableViewDataSource ()

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) GKCellConfigureBlock configureCellBlock;
@property (nonatomic, copy) NSString *altCellIdentifier;
@property (nonatomic, copy) GKCellConfigureBlock altConfigureCellBlock;

@end

@implementation GKHomeTableViewDataSource

- (id)init {
    return nil;
}

- (id)initWithDict:(NSDictionary<NSString *,NSArray *> *)dict cellIdentifier:(NSString *)identifier configureCellBlock:(GKCellConfigureBlock)configureCellBlock altCellIdentifier:(NSString *)altIdentifier altConfigureCellBlock:(GKCellConfigureBlock)altConfigureCellBlock {
    self = [super init];
    if (self) {
        self.dict = dict;
        self.cellIdentifier = identifier;
        self.configureCellBlock = configureCellBlock;
        self.altCellIdentifier = altIdentifier;
        self.altConfigureCellBlock = altConfigureCellBlock;
    }
    return self;
}

- (GKItem *)itemAtIndexPath:(NSIndexPath *)indexPath {
    return _dict[_dict[@"categories"][indexPath.section]][indexPath.row];
}

#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dict[@"categories"].count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dict[_dict[@"categories"][section]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKItem *item = [self itemAtIndexPath:indexPath];
    UITableViewCell *cell = nil;
    if (item.images.count > 0) {
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _dict[@"categories"][section];
}

@end

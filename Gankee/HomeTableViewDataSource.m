//
//  HomeTableViewDataSource.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "HomeTableViewDataSource.h"

@interface HomeTableViewDataSource ()

@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) HomeTableViewCellConfigureBlock configureCellBlock;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray *> *dict;

@end

@implementation HomeTableViewDataSource

- (id)init {
    return nil;
}

- (id)initWithDict:(NSDictionary<NSString *,NSArray *> *)dict cellIdentifier:(NSString *)identifier configureCellBlock:(HomeTableViewCellConfigureBlock)configureCellBlock {
    if (self) {
        self.dict = dict;
        self.cellIdentifier = identifier;
        self.configureCellBlock = configureCellBlock;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    GKItem *item = [self itemAtIndexPath:indexPath];
    self.configureCellBlock(cell, item);
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return _dict[@"categories"][section];
}

@end

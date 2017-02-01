//
//  GKCategoryViewModel.h
//  Gankee
//
//  Created by Wildog on 1/28/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveObjC.h>
#import "GKItem.h"
#import "GKClient.h"

@interface GKResultTableViewModel : NSObject <UITableViewDataSource>

@property (nonatomic, strong, readonly) NSMutableArray<GKItem *> *items;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, assign) NSUInteger pageSize;
@property (nonatomic, assign) GKCategory category;
@property (nonatomic, copy) NSString *search;
@property (nonatomic, assign) BOOL noMoreResults;

- (id)initWithItems:(NSArray *)items
           category:(GKCategory)category
           pageSize:(NSUInteger)pageSize
     cellIdentifier:(NSString *)identifier
 configureCellBlock:(GKCellConfigureBlock)configureCellBlock
    altCellIdentifier:(NSString *)altIdentifier
altConfigureCellBlock:(GKCellConfigureBlock)altConfigureCellBlock;

- (RACSignal *)moreItemsSignal;
    
@end

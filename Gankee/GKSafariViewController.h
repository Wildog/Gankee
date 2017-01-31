//
//  GKSafariViewController.h
//  Gankee
//
//  Created by Wildog on 1/29/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <SafariServices/SafariServices.h>
#import "GKItem.h"
#import "GKFavoriteItem+CoreDataClass.h"

@interface GKSafariViewController : SFSafariViewController

@property (nonatomic, strong) GKItem *item;

- (instancetype)initWithItem:(GKItem *)item;
- (instancetype)initWithFavoriteItem:(GKFavoriteItem *)item;

@end

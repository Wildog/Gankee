//
//  GKFavoriteActivity.h
//  Gankee
//
//  Created by Wildog on 2/1/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKFavoriteHelper.h"

@interface GKUnfavoriteActivity : UIActivity

@property (nonatomic, strong) GKItem *item;

- (id)initWithItem:(GKItem *)item;

@end

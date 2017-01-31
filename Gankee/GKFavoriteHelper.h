//
//  GKFavoriteHelper.h
//  Gankee
//
//  Created by Wildog on 2/1/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKItem.h"
#import "GKFavoriteItem+CoreDataClass.h"

@interface GKFavoriteHelper : NSObject

+ (GKFavoriteItem *)createFavoriteItemFromItem:(GKItem *)item;
+ (GKFavoriteItem *)fetchFavoriteItemFromItem:(GKItem *)item;

@end

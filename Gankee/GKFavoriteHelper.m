//
//  GKFavoriteHelper.m
//  Gankee
//
//  Created by Wildog on 2/1/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "GKFavoriteHelper.h"
#import "GKFavoriteItem+CoreDataClass.h"

@implementation GKFavoriteHelper

+ (GKFavoriteItem *)createFavoriteItemFromItem:(GKItem *)item {
    GKFavoriteItem *favoriteItem = [GKFavoriteHelper fetchFavoriteItemFromItem:item];
    if (favoriteItem) {
        return favoriteItem;
    }
    favoriteItem = [GKFavoriteItem MR_createEntity];
    favoriteItem.itemID = item.itemID;
    favoriteItem.created = item.created;
    favoriteItem.published = item.published;
    favoriteItem.added = [NSDate date];
    favoriteItem.url = item.url;
    favoriteItem.desc = item.desc;
    favoriteItem.author = item.author;
    favoriteItem.images = item.images;
    favoriteItem.category = item.category;
    favoriteItem.source = item.source;
    return favoriteItem;
}

+ (GKFavoriteItem *)fetchFavoriteItemFromItem:(GKItem *)item {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"itemID = %@", item.itemID];
    return [GKFavoriteItem MR_findAllWithPredicate:predicate].firstObject;
}


@end

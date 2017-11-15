//
//  AppDelegate.m
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import "AppDelegate.h"
#import "IQKeyboardManager.h"
#import "GKFavoriteItem+CoreDataClass.h"
#import "GKSafariViewController.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/SDWebImageManager.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // setup keyboard avoider
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 160;
    
    // window background color
    self.window.backgroundColor = [UIColor whiteColor];
    
    // setup core data
    if ([[NSFileManager defaultManager] ubiquityIdentityToken]) {
        [self iCloudCoreDataSetup];
    } else {
        [MagicalRecord setupAutoMigratingCoreDataStack];
    }
    
    // setup spotlight indexer
    self.indexer = [[WACDSIndexer alloc] initWithManagedObjectContext:[NSManagedObjectContext MR_defaultContext]];
    
    WACDSCustomMapping *mapping = [[WACDSCustomMapping alloc] initWithManagedObjectEntityName:@"GKFavoriteItem" uniqueIdentifierPattern:@"{#itemID#}" searchableItemAttributeSetBuilder:^CSSearchableItemAttributeSet *(GKFavoriteItem *item) {
        CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeText];
        attributeSet.title = item.desc;
        attributeSet.contentDescription = item.category;
        attributeSet.contentCreationDate = item.created;
        attributeSet.creator = item.author;
        attributeSet.keywords = @[@"gankee", @"干货", item.desc, item.category];
        
        NSArray *images = (NSArray *)item.images;
        if (images.count > 0) {
            NSURL *imageUrl = images[0];
            NSString *cacheKey = [[SDWebImageManager sharedManager] cacheKeyForURL:imageUrl];
            UIImage *image = [[SDImageCache sharedImageCache] imageFromCacheForKey:cacheKey];
            if (image) {
                attributeSet.thumbnailData = UIImagePNGRepresentation(image);
            }
        }
        
        return attributeSet;
    }];
    [self.indexer registerMapping:mapping];
    
    return YES;
}

- (void)iCloudCoreDataSetup {
    [MagicalRecord setupCoreDataStackWithiCloudContainer:@"iCloud.dog.wil.Gankee"
                                          contentNameKey:@"GKFavoriteItem"
                                         localStoreNamed:@"GKFavoriteItem.sqlite"
                                 cloudStorePathComponent:@"Documents/CloudLogs"
                                              completion:nil];
    
    // This notification is issued only once when
    // 1) you run your app on a particular device for the first time
    // 2) you disable/enable iCloud document storage on a particular device
    // usually a couple of seconds after the respective event.
    // The notification must be handled on the MAIN thread and synchronously
    // (because as soon as it finishes, the persistent store is removed by OS).
    // Refer to Apple's documentation for further details
    [[NSNotificationCenter defaultCenter] addObserverForName:NSPersistentStoreCoordinatorStoresWillChangeNotification
                                                      object:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      // Save changes to current MOC and reset it
                                                      if ([[NSManagedObjectContext MR_defaultContext] hasChanges]) {
                                                          [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
                                                      }
                                                      [[NSManagedObjectContext MR_defaultContext] reset];
                                                  }];
    
    // This notification is issued couple of times every time your app starts
    // The notification must be handled on the BACKGROUND thread and asynchronously to prevent deadlock
    // Refer to Apple's documentation for further details
    [[NSNotificationCenter defaultCenter] addObserverForName:NSPersistentStoreCoordinatorStoresDidChangeNotification
                                                      object:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]
                                                       queue:nil    // Run on the background thread
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          // Recommended by Apple
                                                          [[NSManagedObjectContext MR_defaultContext] reset];
                                                          
                                                          // Notify UI that the data has changes
                                                          [[NSNotificationCenter defaultCenter] postNotificationName:kMagicalRecordPSCDidCompleteiCloudSetupNotification object:nil];
                                                      });
                                                  }];
    
    // Core Data's iCloud integration is deprecating, this notification depracted in iOS 10.1, with no replacment yet
    // But we still need to re-index spotlight based on changes from iCloud contents
    [[NSNotificationCenter defaultCenter] addObserverForName:NSPersistentStoreDidImportUbiquitousContentChangesNotification
                                                      object:[NSPersistentStoreCoordinator MR_defaultStoreCoordinator]
                                                       queue:nil
                                                  usingBlock:^(NSNotification * _Nonnull note) {
                                                      
                                                      for (NSManagedObjectID *objectID in [note.userInfo objectForKey:NSInsertedObjectsKey]) {
                                                          GKFavoriteItem *item = [[NSManagedObjectContext MR_defaultContext] existingObjectWithID:objectID error:nil];
                                                          if (item) [self.indexer updateIndexingForObject:item];
                                                      }
                                                      
                                                      for (NSManagedObjectID *objectID in [note.userInfo objectForKey:NSUpdatedObjectsKey]) {
                                                          GKFavoriteItem *item = [[NSManagedObjectContext MR_defaultContext] existingObjectWithID:objectID error:nil];
                                                          if (item) [self.indexer updateIndexingForObject:item];
                                                      }
                                                      
                                                      for (NSManagedObjectID *objectID in [note.userInfo objectForKey:NSDeletedObjectsKey]) {
                                                          GKFavoriteItem *item = [[NSManagedObjectContext MR_defaultContext] existingObjectWithID:objectID error:nil];
                                                          if (item) [self.indexer removeObjectsFromIndex:@[item]];
                                                      }
                                                  }];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler {
    GKFavoriteItem *item = (GKFavoriteItem *)[self.indexer objectFromUserActivity:userActivity];
    GKSafariViewController *viewController = [[GKSafariViewController alloc] initWithFavoriteItem:item];
    [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
    
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler {
    if ([shortcutItem.type isEqualToString:@"Categories"]) {
        [(UITabBarController *)self.window.rootViewController setSelectedIndex:1];
    } else if ([shortcutItem.type isEqualToString:@"Favorites"]) {
        [(UITabBarController *)self.window.rootViewController setSelectedIndex:2];
    } else if ([shortcutItem.type isEqualToString:@"Search"]) {
        [(UITabBarController *)self.window.rootViewController setSelectedIndex:0];
        [[(UITabBarController *)self.window.rootViewController selectedViewController] performSegueWithIdentifier:@"search_segue" sender:nil];
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}


@end

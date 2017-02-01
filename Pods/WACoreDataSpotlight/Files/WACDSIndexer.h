//
//  WACDSRegistrar.h
//  WACoreDataSpotlight
//
//  Created by Marian Paul on 21/09/2015.
//  Copyright © 2015 Wasappli. All rights reserved.
//

@import Foundation;
@import CoreData;

@class WACDSCustomMapping;

typedef void (^WACDSIndexerBatchCompletionHandler)(NSError * _Nullable error);

/**
 WACDSIndexer is the starting point for autoindexing your content data. You should initialize it with a managed object context, and optionnaly with some protection. Please see the doc about this (not yet supported in the app though)
 
 */
@interface WACDSIndexer : NSObject

/**
 *  Init the indexer
 *
 *  @param managedObjectContext the managed object context you use along with your CoreData objects
 *
 *  @return nil if search is not available, a fresh new indexer otherwise
 */
- (_Nullable instancetype)initWithManagedObjectContext:( NSManagedObjectContext * _Nonnull)managedObjectContext;

/**
 *  @see initWithManagedObjectContext:
 *
 *  @param managedObjectContext the managed object context you use along with your CoreData objects
 *  @param indexName            the index name @see name on CSSearchableIndex
 *
 *  @return nil if search is not available, a fresh new indexer otherwise
 */
- (_Nullable instancetype)initWithManagedObjectContext:( NSManagedObjectContext * _Nonnull)managedObjectContext indexName:(NSString * _Nullable)indexName;

/**
 *  @see initWithManagedObjectContext:
 *
 *  @param managedObjectContext the managed object context you use along with your CoreData objects
 *  @param indexName            the index name @see name on CSSearchableIndex
 *  @param protectionClass      protection class @see protectionClass on CSSearchableIndex
 *
 *  @return nil if search is not available, a fresh new indexer otherwise
 */
- (_Nullable instancetype)initWithManagedObjectContext:( NSManagedObjectContext * _Nonnull)managedObjectContext indexName:(NSString * _Nullable)indexName protectionClass:(NSString *_Nullable)protectionClass NS_DESIGNATED_INITIALIZER;


/**
 *  Register a new mapping between a CoreData object and a CSSearchableItem object
 *
 *  @param mapping the mapping
 */
- (void)registerMapping:(WACDSCustomMapping *_Nonnull)mapping;

/**
 *  Index the existing objects. Useful if for example you are launching the app with an existing database which needs to be indexed.
 *  Remember that this is up to you to only index once (not useful to do it every time)
 *
 *  @param objects an array of NSManagedObject
 */
- (void)indexExistingObjects:(NSArray<NSManagedObject *> *_Nonnull)objects;

/**
 *  Update the index for an existing object. This might be useful for reindexing after an image download for example, which event might not appear on CoreData.
 *
 *  @param object the object you want to reindex
 */
- (void)updateIndexingForObject:(NSManagedObject *_Nonnull)object;

/**
 *  Remove objects from indexer
 *
 *  @param objects the objects to remove from the indexer
 */
- (void)removeObjectsFromIndex:(NSArray<NSManagedObject *> *_Nonnull)objects;

/**
 *  Retrieve an NSManagedObject from an identifier you got on application:continueUserActivity:restorationHandler:
 *
 *  @param userActivity the user activity you got from App delegate
 *
 *  @return the corresponding NSManagedObject retrieved or nil if not found
 */
- (NSManagedObject *_Nullable)objectFromUserActivity:(NSUserActivity *_Nonnull)userActivity;

@property (nonatomic, copy, nullable) WACDSIndexerBatchCompletionHandler batchCompletionHandler;

@end

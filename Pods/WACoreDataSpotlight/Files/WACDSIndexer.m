//
//  WACDSRegistrar.m
//  WACoreDataSpotlight
//
//  Created by Marian Paul on 21/09/2015.
//  Copyright © 2015 Wasappli. All rights reserved.
//

#import "WACDSIndexer.h"

#import "WACDSMacros.h"
#import "WACDSCustomMapping.h"

@interface WACDSIndexer ()

@property (nonatomic, strong) NSMutableDictionary *mappings;
@property (nonatomic, strong) CSSearchableIndex   *searchableIndex;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation WACDSIndexer

- (instancetype)init {
    return [self initWithManagedObjectContext:[[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType] indexName:nil protectionClass:nil];
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    return [self initWithManagedObjectContext:managedObjectContext indexName:nil protectionClass:nil];
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext indexName:(NSString *)indexName {
    return [self initWithManagedObjectContext:managedObjectContext indexName:indexName protectionClass:nil];
}

- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext indexName:(NSString *)indexName protectionClass:(NSString *)protectionClass {
    WACDSParameterAssert((managedObjectContext && [managedObjectContext isKindOfClass:[NSManagedObjectContext class]]));
    
    if (![CSSearchableIndex isIndexingAvailable]) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        
        self->_managedObjectContext = managedObjectContext;
        
        if (!indexName) {
            self->_searchableIndex = [CSSearchableIndex defaultSearchableIndex];
        } else {
            NSString *resolvedProtectionClass = protectionClass;
            if (!resolvedProtectionClass) {
                resolvedProtectionClass = NSFileProtectionNone;
            }
            self->_searchableIndex = [[CSSearchableIndex alloc] initWithName:indexName
                                                             protectionClass:resolvedProtectionClass];
            
            __weak typeof(self) weakSelf = self;
            [self->_searchableIndex fetchLastClientStateWithCompletionHandler:^(NSData * _Nullable clientState, NSError * _Nullable error) {
                // TODO: retrieve the objects from the data and finish indexing
                weakSelf.batchCompletionHandler(error);
            }];
        }
    }
    
    return self;
}

#pragma mark - Public methods
#pragma mark Registering

- (void)registerMapping:(WACDSCustomMapping *)mapping {
    WACDSClassAssertion(mapping, WACDSCustomMapping);
    WACDSAssert(!self.mappings[mapping.objectEntityName], ([NSString stringWithFormat:@"You already have a mapping for '%@'", mapping.objectEntityName]));
    self.mappings[mapping.objectEntityName] = mapping;
}

#pragma mark Indexing

- (void)indexExistingObjects:(NSArray *)objects {
    WACDSClassAssertion(objects, NSArray);
    
    // Index or update is the same thing
    [self indexNewObjects:objects];
}

- (void)updateIndexingForObject:(NSManagedObject *)object {
    WACDSClassAssertion(object, NSManagedObject);
    
    if (object) {
        [self indexNewObjects:@[object]];
    }
}

#pragma mark - Object retrieval

- (NSManagedObject *)objectFromUserActivity:(NSUserActivity *)userActivity {
    WACDSClassAssertion(userActivity, NSUserActivity);
    
    if ([[userActivity activityType] isEqualToString:CSSearchableItemActionType]) {
        NSString *uniqueIdentifier = [userActivity.userInfo objectForKey:CSSearchableItemActivityIdentifier];
        
        for (WACDSCustomMapping *mapping in [self.mappings allValues]) {
            NSDictionary *parameters = [mapping parametersFromUniqueIdentifier:uniqueIdentifier];
            
            if (parameters) {
                // We have parameters, but we could have a mis match on equality. So check that rebuilding is fine
                NSString *testIdentifier = [mapping uniqueIdentifierForObject:parameters];
                if ([testIdentifier isEqualToString:uniqueIdentifier]) {
                    // We found the object, hurra. Let's fetch it
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:mapping.objectEntityName
                                                              inManagedObjectContext:self.managedObjectContext];
                    [fetchRequest setEntity:entity];
                    
                    // Build the predicate
                    NSMutableArray *subPredicates = [NSMutableArray arrayWithCapacity:[parameters count]];
                    for (NSString *key in [parameters allKeys]) {
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, parameters[key]];
                        [subPredicates addObject:predicate];
                    }
                    
                    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
                    [fetchRequest setPredicate:predicate];
                    
                    NSError *error = nil;
                    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                    return [fetchedObjects firstObject];
                }
            }
        }
    }
    
    return nil;
}

#pragma mark - Notifications

- (void)managedObjectContextDidSave:(NSNotification *)notification {
    NSArray* insertedObjects = [notification userInfo][NSInsertedObjectsKey];
    NSArray* deletedObjects  = [notification userInfo][NSDeletedObjectsKey];
    NSArray* updatedObjects  = [notification userInfo][NSUpdatedObjectsKey];

    BOOL canUseBatching = [self canUseBatching];
    if (canUseBatching) {
        [self.searchableIndex beginIndexBatch];
    }
    
    [self indexNewObjects:insertedObjects];
    [self removeObjectsFromIndex:deletedObjects];
    [self updateIndexForObjects:updatedObjects];
    
    if (canUseBatching) {
        // TODO: archive somewhere (needs to be defined) the objets IDs to retrieve them later
        // Then store the file URL
        [self.searchableIndex endIndexBatchWithClientState:[NSData new]/*TODO*/
                                         completionHandler:self.batchCompletionHandler];
    }
}

#pragma mark - Indexing

- (BOOL)canUseBatching {
    return self.searchableIndex != [CSSearchableIndex defaultSearchableIndex];
}

- (void)indexNewObjects:(NSArray *)objects {
    NSMutableArray *searchItems                  = [NSMutableArray array];
    NSMutableArray *objectsWithoutSearchableItem = [NSMutableArray array];
    
    for (id object in objects) {
        WACDSCustomMapping *mapping = self.mappings[[[(NSManagedObject *)object entity] name]];
        if (mapping) {
            CSSearchableItem *item = [mapping searchableItemForObject:object];
            if (item) {
                [searchItems addObject:item];
            }
            else {
                [objectsWithoutSearchableItem addObject:object];
            }
        }
    }
    
    if ([searchItems count] > 0) {
        [self.searchableIndex indexSearchableItems:[searchItems copy]
                                 completionHandler:^(NSError * _Nullable error) {
                                     if (error) {
                                         WACDSLog(@"Indexing objects failed with error: %@", error);
                                     }
                                 }];
    }
    
    // We might have some objects not mapped for some reason
    // These objects may have never been indexed. But if it was, be sure to remove them from the index as well
    [self removeObjectsFromIndex:objectsWithoutSearchableItem];
}

- (void)removeObjectsFromIndex:(NSArray *)objects {
    NSMutableArray *identifiersToDelete = [NSMutableArray array];
    for (id object in objects) {
        WACDSCustomMapping *mapping = self.mappings[[[(NSManagedObject *)object entity] name]];
        if (mapping) {
            [identifiersToDelete addObject:[mapping uniqueIdentifierForObject:object]];
        }
    }
    
    if ([identifiersToDelete count] > 0) {
        [self.searchableIndex deleteSearchableItemsWithIdentifiers:[identifiersToDelete copy]
                                                 completionHandler:^(NSError * _Nullable error) {
                                                     if (error) {
                                                         WACDSLog(@"Deleting identifiers failed with error: %@", error);
                                                     }
                                                 }];
    }
}

- (void)updateIndexForObjects:(NSArray *)objects {
    [self indexNewObjects:objects];
}

#pragma mark - Getter/Setters

- (NSMutableDictionary *)mappings {
    if (!_mappings) {
        _mappings = [NSMutableDictionary dictionary];
    }
    
    return _mappings;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:nil];
}

@end

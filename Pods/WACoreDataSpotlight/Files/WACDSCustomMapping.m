//
//  WACDSCustomMapping.m
//  WACoreDataSpotlight
//
//  Created by Marian Paul on 21/09/2015.
//  Copyright © 2015 Wasappli. All rights reserved.
//

#import "WACDSCustomMapping.h"
#import "WACDSStringPattern.h"

#import "WACDSMacros.h"

@import ObjectiveC.runtime;

@interface WACDSCustomMapping ()

@property (nonatomic, strong) WACDSSearchableItemAttributeSetBuilder searchableItemAttributeSetBuilder;

@property (nonatomic, strong) WACDSStringPattern *uniqueIdentifierStringPattern;
@property (nonatomic, strong) WACDSStringPattern *domainIdentifierStringPattern;
@property (nonatomic, strong) NSArray *keywordsStringPatterns;

@end

@implementation WACDSCustomMapping

- (instancetype)initWithManagedObjectEntityName:(NSString *)objectEntityName uniqueIdentifierPattern:(NSString *)uniqueIdentifierPattern searchableItemAttributeSetBuilder:(WACDSSearchableItemAttributeSetBuilder)searchableItemAttributeSetBuilder {
    
    WACDSClassAssertion(objectEntityName, NSString);
    WACDSClassAssertion(uniqueIdentifierPattern, NSString);
    WACDSParameterAssert(searchableItemAttributeSetBuilder);
    
    self = [super init];
    if (self) {
        self->_objectEntityName                  = objectEntityName;
        self->_searchableItemAttributeSetBuilder = searchableItemAttributeSetBuilder;
        
        // Create the pattern
        self->_uniqueIdentifierStringPattern = [[WACDSStringPattern alloc] initWithPattern:uniqueIdentifierPattern cleanValuesOnReplacement:NO];
    }
    
    return self;
}

- (NSString *)uniqueIdentifierForObject:(id)object {
    return [self.uniqueIdentifierStringPattern stringWithValuesFromObject:object];
}

- (NSString *)domainIdentifierForObject:(id)object {
    return [self.domainIdentifierStringPattern stringWithValuesFromObject:object];
}

- (CSSearchableItem *)searchableItemForObject:(id)object {
    if (self.shouldIndexObjectBlock && self.shouldIndexObjectBlock(object) == NO) {
        return nil;
    }
    
    CSSearchableItem *searchableItem = [[CSSearchableItem alloc] initWithUniqueIdentifier:[self uniqueIdentifierForObject:object]
                                                                         domainIdentifier:[self domainIdentifierForObject:object]
                                                                             attributeSet:self.searchableItemAttributeSetBuilder(object)];
    searchableItem.expirationDate = self.expirationDateBuilder ? self.expirationDateBuilder(object) : nil;
    
    return searchableItem;
}

- (NSDictionary *)parametersFromUniqueIdentifier:(NSString *)uniqueIdentifier {
    WACDSClassAssertion(uniqueIdentifier, NSString);
    return [self.uniqueIdentifierStringPattern parametersFromString:uniqueIdentifier];
}

- (void)setDomainIdentifierPattern:(NSString *)domainIdentifierPattern {
    _domainIdentifierPattern = domainIdentifierPattern;
    if (domainIdentifierPattern) {
        self.domainIdentifierStringPattern = [[WACDSStringPattern alloc] initWithPattern:domainIdentifierPattern cleanValuesOnReplacement:YES];
    }
    else {
        self.domainIdentifierStringPattern = nil;
    }
}

@end

@implementation WACDSCustomMapping (Deprecated)

- (instancetype)initWithManagedObjectClass:(Class)objectClass uniqueIdentifierPattern:(NSString *)uniqueIdentifierPattern searchableItemAttributeSetBuilder:(WACDSSearchableItemAttributeSetBuilder)searchableItemAttributeSetBuilder {
    return [self initWithManagedObjectEntityName:NSStringFromClass(objectClass)
                         uniqueIdentifierPattern:uniqueIdentifierPattern
               searchableItemAttributeSetBuilder:searchableItemAttributeSetBuilder];
}

@end
//
//  WACDSSimpleMapping.m
//  WACoreDataSpotlight
//
//  Created by Marian Paul on 21/09/2015.
//  Copyright © 2015 Wasappli. All rights reserved.
//

#import "WACDSSimpleMapping.h"
#import "WACDSStringPattern.h"
@import MobileCoreServices;

#import "WACDSMacros.h"

@interface WACDSSimpleMapping ()

@property (nonatomic, strong) WACDSStringPattern *titleStringPattern;
@property (nonatomic, strong) WACDSStringPattern *contentDescriptionStringPattern;
@property (nonatomic, strong) NSArray            *keywordsStringPatterns;

@property (nonatomic, copy) WACDSSimpleMappingThumbnailDataBuilder thumbnailDataBuilder;

@end

@implementation WACDSSimpleMapping

- (instancetype)initWithManagedObjectEntityName:(NSString *)objectEntityName
                        uniqueIdentifierPattern:(NSString *)uniqueIdentifierPattern
                                   titlePattern:(NSString *)titlePattern
                      contentDescriptionPattern:(NSString *)contentDescriptionPattern
                               keywordsPatterns:(NSArray<NSString *> *)keywordsPatterns
                           thumbnailDataBuilder:(WACDSSimpleMappingThumbnailDataBuilder)thumbnailDataBuilder {
    
    WACDSClassAssertion(titlePattern, NSString);
    
    __weak typeof(self) weakSelf = self;
    self = [super initWithManagedObjectEntityName:objectEntityName
                          uniqueIdentifierPattern:uniqueIdentifierPattern
                searchableItemAttributeSetBuilder:^CSSearchableItemAttributeSet *(id object) {
                    CSSearchableItemAttributeSet *attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeText];
                    attributeSet.title                         = [weakSelf.titleStringPattern stringWithValuesFromObject:object];
                    attributeSet.contentDescription            = [weakSelf.contentDescriptionStringPattern stringWithValuesFromObject:object];
                    attributeSet.keywords                      = [weakSelf keywordsForObject:object];
                    if (weakSelf.thumbnailDataBuilder) {
                        attributeSet.thumbnailData = weakSelf.thumbnailDataBuilder(object);
                    }
                    
                    return attributeSet;
                }];
    
    if (self) {
        self->_titleStringPattern = [[WACDSStringPattern alloc] initWithPattern:titlePattern cleanValuesOnReplacement:YES];
        
        if (contentDescriptionPattern) {
            self->_contentDescriptionStringPattern = [[WACDSStringPattern alloc] initWithPattern:contentDescriptionPattern cleanValuesOnReplacement:YES];
        }
        
        NSMutableArray *keywordsPattern = [NSMutableArray array];
        for (NSString *keyword in keywordsPatterns) {
            WACDSStringPattern *pattern     = [[WACDSStringPattern alloc] initWithPattern:keyword cleanValuesOnReplacement:YES];
            [keywordsPattern addObject:pattern];
        }
        self->_keywordsStringPatterns   = [keywordsPattern copy];
        
        self->_thumbnailDataBuilder = thumbnailDataBuilder;
    }
    
    return self;
}

- (NSArray *)keywordsForObject:(id)object {
    NSMutableArray *resolvedArray   = [NSMutableArray array];
    for (WACDSStringPattern *pattern in self.keywordsStringPatterns) {
        [resolvedArray addObject:[pattern stringWithValuesFromObject:object]];
    }
    return [resolvedArray copy];
}

@end

@implementation WACDSSimpleMapping (Deprecated)

- (instancetype)initWithManagedObjectClass:(Class)objectClass uniqueIdentifierPattern:(NSString *)uniqueIdentifierPattern titlePattern:(NSString *)titlePattern contentDescriptionPattern:(NSString *)contentDescriptionPattern keywordsPatterns:(NSArray<NSString *> *)keywordsPatterns thumbnailDataBuilder:(WACDSSimpleMappingThumbnailDataBuilder)thumbnailDataBuilder {
    return [self initWithManagedObjectEntityName:NSStringFromClass(objectClass) uniqueIdentifierPattern:uniqueIdentifierPattern titlePattern:titlePattern contentDescriptionPattern:contentDescriptionPattern keywordsPatterns:keywordsPatterns thumbnailDataBuilder:thumbnailDataBuilder];
}

@end
//
//  WACDSSimpleMapping.h
//  WACoreDataSpotlight
//
//  Created by Marian Paul on 21/09/2015.
//  Copyright © 2015 Wasappli. All rights reserved.
//

#import "WACDSCustomMapping.h"

typedef NSData* _Nullable (^WACDSSimpleMappingThumbnailDataBuilder)(id _Nonnull object);

/**
 This class is a convenient class to help dealing with a classic indexing where you need a title, description, keywords and thumbnail. For all other properties, consider using WACDSCustomMapping directly
 */
@interface WACDSSimpleMapping : WACDSCustomMapping

/**
 *  Init with some patterns to use
 *
 *  @param objectEntityName          The object entity name
 *  @param uniqueIdentifierPattern   A pattern for unique identifier. Ex: booking_{#bookingID#}
 *  @param titlePattern              A pattern for title. Ex: Booking in {#hotel.name#}
 *  @param contentDescriptionPattern A pattern for Description. Ex: Located in {#address#} from {#checkin#} to {#checkout#}
 *  @param keywordsPatterns          An array of keywords. Can be patterns or not. Ex: @[@"booking", @{#hotel.name#}]
 *  @param thumbnailDataBuilder      A block to build the thumbnail. Should return an image as data
 *
 *  @return a fresh simple mapping all set for you
 */
- (instancetype _Nonnull)initWithManagedObjectEntityName:(NSString * _Nonnull)objectEntityName
                                 uniqueIdentifierPattern:(NSString * _Nonnull)uniqueIdentifierPattern
                                            titlePattern:(NSString * _Nonnull)titlePattern
                               contentDescriptionPattern:(NSString * _Nullable)contentDescriptionPattern
                                        keywordsPatterns:(NSArray<NSString*> * _Nullable)keywordsPatterns
                                    thumbnailDataBuilder:(WACDSSimpleMappingThumbnailDataBuilder _Nullable)thumbnailDataBuilder;

@end

@interface WACDSSimpleMapping (Deprecated)

/**
 *  Init with some patterns to use
 *
 *  @param objectClass               The object class
 *  @param uniqueIdentifierPattern   A pattern for unique identifier. Ex: booking_{#bookingID#}
 *  @param titlePattern              A pattern for title. Ex: Booking in {#hotel.name#}
 *  @param contentDescriptionPattern A pattern for Description. Ex: Located in {#address#} from {#checkin#} to {#checkout#}
 *  @param keywordsPatterns          An array of keywords. Can be patterns or not. Ex: @[@"booking", @{#hotel.name#}]
 *  @param thumbnailDataBuilder      A block to build the thumbnail. Should return an image as data
 *
 *  @return a fresh simple mapping all set for you
 */
- (instancetype _Nonnull)initWithManagedObjectClass:(Class _Nonnull)objectClass
                            uniqueIdentifierPattern:(NSString * _Nonnull)uniqueIdentifierPattern
                                       titlePattern:(NSString * _Nonnull)titlePattern
                          contentDescriptionPattern:(NSString * _Nullable)contentDescriptionPattern
                                   keywordsPatterns:(NSArray<NSString*> * _Nullable)keywordsPatterns
                               thumbnailDataBuilder:(WACDSSimpleMappingThumbnailDataBuilder _Nullable)thumbnailDataBuilder __deprecated_msg("use init with managed object entity name instead");

@end
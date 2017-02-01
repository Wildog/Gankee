//
//  WACDSStringPattern.h
//  WACoreDataSpotlight
//
//  Created by Marian Paul on 22/09/2015.
//  Copyright © 2015 Wasappli. All rights reserved.
//

@import Foundation;

/**
 This class helps dealing with patterns like booking_{#bookingID#}. 
 It will return booking_1 or get bookingID: 1
 Please note that parametersFromString: only works if cleanValuesOnReplacement is set to NO
 */
@interface WACDSStringPattern : NSObject

/**
 *  Init with a pattern
 *
 *  @param pattern     the pattern like booking_{#bookingID#}
 *  @param cleanValues set YES if you want the pattern to be resolved in booking_1 or NO if you want it as booking_{#1#} (useful for grabbing parameters from identifier)
 *
 *  @return a fresh pattern object
 */
- (instancetype _Nonnull)initWithPattern:(NSString * _Nonnull)pattern cleanValuesOnReplacement:(BOOL)cleanValues;

/**
 *  Get the string from the pattern with values replaced by object's
 *
 *  @param object the object to use a replacement on pattern
 *
 *  @return a string with values replaced
 */
- (NSString * _Nonnull)stringWithValuesFromObject:(id _Nonnull)object;

/**
 *  Get the parameters from a string based on the pattern. Only works if cleanValuesOnReplacement is set to NO
 *
 *  @param value the string value
 *
 *  @return a dictionary with the parameters (key is from pattern (bookingID), value is @1)
 */
- (NSDictionary * _Nullable)parametersFromString:(NSString * _Nonnull)value;

@end

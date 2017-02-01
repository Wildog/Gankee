//
//  WACDSStringPattern.m
//  WACoreDataSpotlight
//
//  Created by Marian Paul on 22/09/2015.
//  Copyright © 2015 Wasappli. All rights reserved.
//

#import "WACDSStringPattern.h"
#import "WACDSMacros.h"

static NSString *regexPattern = @"\\{#[^\\}#]+#\\}";

@interface WACDSStringPattern ()

@property (nonatomic, strong) NSString *pattern;
@property (nonatomic, assign) BOOL     cleanValuesOnReplacement;
@end

@implementation WACDSStringPattern

- (instancetype)initWithPattern:(NSString *)pattern cleanValuesOnReplacement:(BOOL)cleanValues {
    WACDSClassAssertion(pattern, NSString);
    
    self = [super init];
    if (self) {
        self->_pattern                  = pattern;
        self->_cleanValuesOnReplacement = cleanValues;
    }
    
    return self;
}

- (NSString *)stringWithValuesFromObject:(id)object {
    WACDSParameterAssert(object);
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSArray *matches = [regex matchesInString:self.pattern
                                      options:0
                                        range:NSMakeRange(0, self.pattern.length)];
    
    // Start with the pattern
    NSString *finalString = [self.pattern copy];
    
    for (NSTextCheckingResult* match in matches) {
        // Get the matching text
        NSString *matchText = [self.pattern substringWithRange:[match range]];
        // Get the key from it by removing {# and #}
        NSString *key       = [matchText substringWithRange:NSMakeRange(2, matchText.length - 4)];
        
        // Get the object value. It is better if this is a string, use the description otherwise
        NSString *value = [object valueForKeyPath:key];
        if (![value isKindOfClass:[NSString class]]) {
            value = [value description];
        }
        
        if (value) {
            if (!self.cleanValuesOnReplacement) {
                value = [NSString stringWithFormat:@"{#%@#}", value];
            }
            
            // Finally, replace the value
            finalString = [finalString stringByReplacingOccurrencesOfString:matchText
                                                                 withString:[value copy]];
        }
    }
    
    return finalString;
}

- (NSDictionary *)parametersFromString:(NSString *)value {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSArray *matchesInValue = [regex matchesInString:value
                                             options:0
                                               range:NSMakeRange(0, value.length)];
    
    NSArray *matchesInPattern = [regex matchesInString:self.pattern
                                               options:0
                                                 range:NSMakeRange(0, self.pattern.length)];
    
    if ([matchesInValue count] != [matchesInPattern count]) {
        return nil;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[matchesInValue count]];
    
    for (NSInteger i = 0 ; i < [matchesInValue count] ; i++) {
        NSTextCheckingResult* matchInValue = matchesInValue[i];
        NSString *matchTextValue           = [value substringWithRange:[matchInValue range]];
        // Get the value from it by removing {# and #}
        NSString *value                    = [matchTextValue substringWithRange:NSMakeRange(2, matchTextValue.length - 4)];
        
        NSTextCheckingResult* matchInKey = matchesInPattern[i];
        NSString *matchTextKey           = [self.pattern substringWithRange:[matchInKey range]];
        // Get the value from it by removing {# and #}
        NSString *key                    = [matchTextKey substringWithRange:NSMakeRange(2, matchTextKey.length - 4)];

        parameters[key] = value;
    }

    
    return [parameters copy];
}

@end

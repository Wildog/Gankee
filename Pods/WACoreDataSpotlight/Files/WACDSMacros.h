//
//  WACDSMacros.h
//  WACoreDataSpotlight
//
//  Created by Marian Paul on 22/09/2015.
//  Copyright © 2015 Wasappli. All rights reserved.
//

#define WACDSParameterAssert(obj) NSParameterAssert(obj)
#define WACDSClassAssertion(obj, className) WACDSParameterAssert(obj && [obj isKindOfClass:[className class]])
#define WACDSClassAssertionIfExisting(obj, className) if (obj) { WACDSParameterAssert([obj isKindOfClass:[className class]]); }

#define WACDSAssert(condition, description) NSAssert(condition, description)

#ifdef WACDS_DEBUG
#define WACDSLog(fmt, ...) NSLog((@"WACoreDataSpotlight %s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);
#else
#define WACDSLog(fmt, ...)
#endif

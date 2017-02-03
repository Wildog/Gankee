//
//  AppDelegate.h
//  Gankee
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WACoreDataSpotlight.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) WACDSIndexer *indexer;

@end


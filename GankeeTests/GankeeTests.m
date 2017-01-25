//
//  GankeeTests.m
//  GankeeTests
//
//  Created by Wildog on 1/23/17.
//  Copyright © 2017 Wildog. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "GKAPIManager.h"

@interface GankeeTests : XCTestCase

@end

@implementation GankeeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    [[GKAPIManager manager] dataForCategory:GKCategoryAndroid onPage:2 withCount:30 randomize:NO];
    [[GKAPIManager manager] dataForCategory:GKCategoryWelfare onPage:1 withCount:10 randomize:YES];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end

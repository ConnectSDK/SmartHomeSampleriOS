//
//  BeaconTriggerTests.m
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 2/19/15.
//  Copyright (c) 2015 LG Electronics.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>

#import "BeaconTrigger_Private.h"
#import "NSInvocation+ObjectGetter.h"

static const CGFloat kDefaultAsyncTestTimeout = 0.2f;

/// Tests for the @c BeaconTrigger class.
@interface BeaconTriggerTests : XCTestCase

@end

@implementation BeaconTriggerTests

#pragma mark - Properties Tests

- (void)testSetUUIDAndBlockShouldBeStored {
    NSUUID *uuid = [NSUUID new];
    TriggerBlock block = ^() { };
    BeaconTrigger *trigger = [[BeaconTrigger alloc] initWithProximityUUID:uuid
                                                          andTriggerBlock:block];

    XCTAssertEqualObjects(trigger.proximityUUID, uuid, @"The UUID must match");
    XCTAssertNil(trigger.major, @"The major must not be setup");
    XCTAssertNil(trigger.minor, @"The minor must not be setup");
    XCTAssertEqualObjects(trigger.triggerBlock, block, @"The block must match");
}

- (void)testSetPropertiesShouldBeStored {
    NSUUID *uuid = [NSUUID new];
    NSNumber *major = @0;
    NSNumber *minor = @42;
    TriggerBlock block = ^() { };
    BeaconTrigger *trigger = [[BeaconTrigger alloc] initWithProximityUUID:uuid
                                                                    major:major
                                                                    minor:minor
                                                          andTriggerBlock:block];

    XCTAssertEqualObjects(trigger.proximityUUID, uuid, @"The UUID must match");
    XCTAssertEqualObjects(trigger.major, major, @"The major must match");
    XCTAssertEqualObjects(trigger.minor, minor, @"The minor must match");
    XCTAssertEqualObjects(trigger.triggerBlock, block, @"The block must match");
}

- (void)testDesignatedInitializerShouldThrowExceptionWithNilUUID {
    XCTAssertThrowsSpecificNamed([[BeaconTrigger alloc] initWithProximityUUID:nil
                                                              andTriggerBlock:^() { }],
                                 NSException, NSInvalidArgumentException,
                                 @"nil UUID must not be accepted");
}

- (void)testInitializerShouldThrowExceptionWithNilUUID {
    XCTAssertThrowsSpecificNamed([[BeaconTrigger alloc] initWithProximityUUID:nil
                                                                        major:@0
                                                                        minor:@0
                                                              andTriggerBlock:^() { }],
                                 NSException, NSInvalidArgumentException,
                                 @"nil UUID must not be accepted");
}

- (void)testDesignatedInitializerShouldThrowExceptionWithNilBlock {
    XCTAssertThrowsSpecificNamed([[BeaconTrigger alloc] initWithProximityUUID:[NSUUID UUID]
                                                              andTriggerBlock:nil],
                                 NSException, NSInvalidArgumentException,
                                 @"nil triggerBlock must not be accepted");
}

- (void)testInitializerShouldThrowExceptionWithNilBlock {
    XCTAssertThrowsSpecificNamed([[BeaconTrigger alloc] initWithProximityUUID:[NSUUID UUID]
                                                                        major:@0
                                                                        minor:@0
                                                              andTriggerBlock:nil],
                                 NSException, NSInvalidArgumentException,
                                 @"nil triggerBlock must not be accepted");
}

- (void)testInitShouldThrowException {
    XCTAssertThrowsSpecificNamed([[BeaconTrigger alloc] init],
                                 NSException, NSInvalidArgumentException,
                                 @"nil UUID must not be accepted");
}

#pragma mark - Callback Tests

- (void)testStartedTriggerShouldCallbackWhenFoundMatchingBeacon {
    NSUUID *uuid = [NSUUID new];
    XCTestExpectation *blockIsCalled = [self expectationWithDescription:@"triggerBlock is called"];

    id locationManagerMock = OCMClassMock([CLLocationManager class]);

    TriggerBlock triggerBlock = ^() {
        [blockIsCalled fulfill];
    };
    BeaconTrigger *trigger = [[BeaconTrigger alloc] initWithProximityUUID:uuid
                                                          andTriggerBlock:triggerBlock];

    trigger.locationManager = locationManagerMock;

    [OCMExpect([locationManagerMock startMonitoringForRegion:[OCMArg isKindOfClass:[CLBeaconRegion class]]]) andDo:^(NSInvocation *invocation) {
        CLBeaconRegion *region = [invocation objectArgumentAtIndex:0];
        dispatch_queue_t queue = dispatch_get_main_queue();

        dispatch_async(queue, ^{
            if ([trigger respondsToSelector:@selector(locationManager:didStartMonitoringForRegion:)]) {
                [trigger locationManager:locationManagerMock
             didStartMonitoringForRegion:region];
            }
        });

        dispatch_async(queue, ^{
            [trigger locationManager:locationManagerMock
                      didEnterRegion:region];
        });
    }];

    [OCMExpect([locationManagerMock isRangingAvailable]) andReturnValue:OCMOCK_VALUE(YES)];

    [OCMExpect([locationManagerMock startRangingBeaconsInRegion:[OCMArg isKindOfClass:[CLBeaconRegion class]]]) andDo:^(NSInvocation *invocation) {
        CLBeaconRegion *region = [invocation objectArgumentAtIndex:0];
        dispatch_queue_t queue = dispatch_get_main_queue();

        dispatch_async(queue, ^{
            id beaconMock = OCMClassMock([CLBeacon class]);
            [OCMStub([beaconMock proximity]) andReturnValue:OCMOCK_VALUE(CLProximityNear)];
            [OCMStub([beaconMock valueForKey:@"proximity"]) andReturn:@(CLProximityNear)];

            [trigger locationManager:locationManagerMock
                     didRangeBeacons:@[beaconMock]
                            inRegion:region];
        });
    }];

    [trigger start];

    [self waitForExpectationsWithTimeout:kDefaultAsyncTestTimeout
                                 handler:^(NSError *error) {
                                     XCTAssertNil(error);
                                     OCMVerifyAll(locationManagerMock);
                                 }];
}

- (void)testBeaconsSetShouldCallbackWithMatchingBeacon {
    NSUUID *uuid = [NSUUID new];
    XCTestExpectation *blockIsCalled = [self expectationWithDescription:@"triggerBlock is called"];

    id locationManagerMock = OCMClassMock([CLLocationManager class]);

    TriggerBlock triggerBlock = ^() {
        [blockIsCalled fulfill];
    };
    BeaconTrigger *trigger = [[BeaconTrigger alloc] initWithProximityUUID:uuid
                                                          andTriggerBlock:triggerBlock];

    trigger.locationManager = locationManagerMock;

    // short-circuit the whole ranging process. this is quite fragile,
    // don't try this at home!
    [OCMExpect([locationManagerMock startMonitoringForRegion:OCMOCK_ANY]) andDo:^(NSInvocation *invocation) {
        CLBeaconRegion *region = [invocation objectArgumentAtIndex:0];
        NSArray *proximitiesToMock = @[OCMOCK_VALUE(CLProximityUnknown),
                                       OCMOCK_VALUE(CLProximityFar),
                                       OCMOCK_VALUE(CLProximityImmediate)];
        NSMutableArray *beaconMocks = [NSMutableArray arrayWithCapacity:proximitiesToMock.count];
        for (NSValue *proximityToMock in proximitiesToMock) {
            id beaconMock = OCMClassMock([CLBeacon class]);
            [OCMStub([beaconMock proximity]) andReturnValue:proximityToMock];
            [OCMStub([beaconMock valueForKey:@"proximity"]) andReturn:proximityToMock];
            [beaconMocks addObject:beaconMock];
        }

        [trigger locationManager:locationManagerMock
                 didRangeBeacons:beaconMocks
                        inRegion:region];
    }];

    [trigger start];

    [self waitForExpectationsWithTimeout:kDefaultAsyncTestTimeout
                                 handler:^(NSError *error) {
                                     XCTAssertNil(error);
                                     OCMVerifyAll(locationManagerMock);
                                 }];
}

- (void)testStoppedTriggerShouldNotCallback {
    NSUUID *uuid = [NSUUID new];

    id locationManagerMock = OCMClassMock([CLLocationManager class]);

    TriggerBlock triggerBlock = ^() {
        XCTFail(@"Must not be called");
    };
    BeaconTrigger *trigger = [[BeaconTrigger alloc] initWithProximityUUID:uuid
                                                          andTriggerBlock:triggerBlock];

    trigger.locationManager = locationManagerMock;

    __block CLBeaconRegion *region;
    [OCMExpect([locationManagerMock startMonitoringForRegion:[OCMArg isKindOfClass:[CLBeaconRegion class]]]) andDo:^(NSInvocation *invocation) {
        region = [invocation objectArgumentAtIndex:0];
    }];

    [trigger start];
    [trigger stop];

    dispatch_async(dispatch_get_main_queue(), ^{
        XCTAssertNotNil(region); // tests for tests?!

        id beaconMock = OCMClassMock([CLBeacon class]);
        [OCMStub([beaconMock proximity]) andReturnValue:OCMOCK_VALUE(CLProximityNear)];
        [OCMStub([beaconMock valueForKey:@"proximity"]) andReturn:@(CLProximityNear)];

        [trigger locationManager:locationManagerMock
                 didRangeBeacons:@[beaconMock]
                        inRegion:region];
    });

    [self runRunLoopForInterval:kDefaultAsyncTestTimeout];
    OCMVerifyAll(locationManagerMock);
}

#pragma mark - Helpers

- (void)runRunLoopForInterval:(CGFloat)interval {
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:interval];
    while ([timeoutDate timeIntervalSinceNow] > 0) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:timeoutDate];
    }
}

@end

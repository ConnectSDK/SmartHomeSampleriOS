//
//  BeaconTriggerTests.m
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 2/19/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "BeaconTrigger.h"

/// Tests for the @c BeaconTrigger class.
@interface BeaconTriggerTests : XCTestCase

@end

@implementation BeaconTriggerTests

#pragma mark - Properties Tests

- (void)testSetUUIDShouldBeStored {
    NSUUID *uuid = [NSUUID new];
    BeaconTrigger *trigger = [[BeaconTrigger alloc] initWithProximityUUID:uuid];

    XCTAssertEqualObjects(trigger.proximityUUID, uuid, @"The UUID must match");
    XCTAssertNil(trigger.major, @"The major must not be setup");
    XCTAssertNil(trigger.minor, @"The minor must not be setup");
}

- (void)testSetPropertiesShouldBeStored {
    NSUUID *uuid = [NSUUID new];
    NSNumber *major = @0;
    NSNumber *minor = @42;
    BeaconTrigger *trigger = [[BeaconTrigger alloc] initWithProximityUUID:uuid
                                                                    major:major
                                                                 andMinor:minor];

    XCTAssertEqualObjects(trigger.proximityUUID, uuid, @"The UUID must match");
    XCTAssertEqualObjects(trigger.major, major, @"The major must match");
    XCTAssertEqualObjects(trigger.minor, minor, @"The minor must match");
}

- (void)testDesignatedInitializerShouldThrowExceptionWithNilUUID {
    XCTAssertThrowsSpecificNamed([[BeaconTrigger alloc] initWithProximityUUID:nil],
                                 NSException, NSInvalidArgumentException,
                                 @"nil UUID must not be accepted");
}

- (void)testInitializerShouldThrowExceptionWithNilUUID {
    XCTAssertThrowsSpecificNamed([[BeaconTrigger alloc] initWithProximityUUID:nil
                                                                        major:@0
                                                                     andMinor:@0],
                                 NSException, NSInvalidArgumentException,
                                 @"nil UUID must not be accepted");
}

- (void)testInitShouldThrowException {
    XCTAssertThrowsSpecificNamed([[BeaconTrigger alloc] init],
                                 NSException, NSInvalidArgumentException,
                                 @"nil UUID must not be accepted");
}

@end

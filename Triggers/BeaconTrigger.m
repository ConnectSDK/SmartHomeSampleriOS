//
//  BeaconTrigger.m
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 2/19/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "BeaconTrigger.h"

@implementation BeaconTrigger

#pragma mark - Init

- (instancetype)init {
    return [self initWithProximityUUID:nil];
}

- (instancetype)initWithProximityUUID:(NSUUID *)uuid {
    return [self initWithProximityUUID:uuid
                                 major:nil
                              andMinor:nil];
}

- (instancetype)initWithProximityUUID:(NSUUID *)uuid
                                major:(NSNumber *)major
                             andMinor:(NSNumber *)minor {
    if (!uuid) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"UUID must not be nil"
                                     userInfo:nil];
    }

    if (self = [super init]) {
        _proximityUUID = uuid;
        _major = major;
        _minor = minor;
    }
    return self;
}

@end

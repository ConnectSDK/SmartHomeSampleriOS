//
//  BeaconTrigger.h
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 2/19/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A trigger that monitors an iBeacon region with the specified parameters.
 *
 * @see @c CLBeaconRegion class
 */
@interface BeaconTrigger : NSObject

/// The proximity UUID of beacons to monitor for.
@property (nonatomic, strong, readonly) NSUUID *proximityUUID;

/// The major value of beacons to match; `nil` if not used.
@property (nonatomic, strong, readonly) NSNumber *major;

/// The minor value of beacons to match; `nil` if not used.
@property (nonatomic, strong, readonly) NSNumber *minor;

/// Designated initializer. The @c uuid parameter must not be @c nil.
/// @warning Do not use the default @c -init method.
- (instancetype)initWithProximityUUID:(NSUUID *)uuid
                                major:(NSNumber *)major
                             andMinor:(NSNumber *)minor;

/// Initializer. The @c uuid parameter must not be @c nil.
- (instancetype)initWithProximityUUID:(NSUUID *)uuid;

@end

//
//  BeaconTrigger.h
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 2/19/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A trigger that monitors an iBeacon region with the specified parameters. The
 * trigger's block is called when a beacon is "near" or "immediate". It's an
 * immutable class.
 *
 * @see @c CLBeaconRegion class
 */
@interface BeaconTrigger : NSObject

/// Notification block type.
typedef void(^TriggerBlock)();

/// The proximity UUID of beacons to monitor for. Cannot be @c nil.
@property (nonatomic, strong, readonly) NSUUID *proximityUUID;

/// The major value of beacons to match; `nil` if not used.
@property (nonatomic, strong, readonly) NSNumber *major;

/// The minor value of beacons to match; `nil` if not used.
@property (nonatomic, strong, readonly) NSNumber *minor;

/// The block to trigger when a matching beacon is found. Cannot be @c nil.
@property (nonatomic, copy, readonly) TriggerBlock triggerBlock;


/// Designated initializer. The @c uuid and @c block parameters must not be
/// @c nil.
/// @warning Do not use the default @c -init method.
- (instancetype)initWithProximityUUID:(NSUUID *)uuid
                                major:(NSNumber *)major
                                minor:(NSNumber *)minor
                      andTriggerBlock:(TriggerBlock)block;

/// Initializer. The @c uuid and @c block parameters must not be @c nil.
- (instancetype)initWithProximityUUID:(NSUUID *)uuid
                      andTriggerBlock:(TriggerBlock)block;

/// Starts iBeacon monitoring.
- (void)start;

/// Stops the monitoring. The trigger block will not be called until @c -start
/// is called.
- (void)stop;

@end

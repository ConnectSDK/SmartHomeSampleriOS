//
//  BeaconTrigger.h
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

#import <Foundation/Foundation.h>

/**
 * A trigger that monitors an iBeacon region with the specified parameters. The
 * trigger's block is called when a beacon is ("immediate") or
 * ("near" or "immediate") – see @c triggerOnNearProximity property.
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

/// Defines whether to trigger the callback on "near" proximity, in addition to
/// "immediate". Default is @c YES.
@property (nonatomic, assign) BOOL triggerOnNearProximity;


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

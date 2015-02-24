//
//  BeaconTrigger.m
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 2/19/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "BeaconTrigger_Private.h"

@interface BeaconTrigger ()

@property (nonatomic, assign) BOOL isStarted;
@property (nonatomic, strong, readonly) CLBeaconRegion *beaconRegion;

@end

@implementation BeaconTrigger

@synthesize beaconRegion = _beaconRegion;

#pragma mark - Init

- (instancetype)init {
    // this will fail
    return [self initWithProximityUUID:nil
                                 major:nil
                                 minor:nil
                       andTriggerBlock:nil];
}

- (instancetype)initWithProximityUUID:(NSUUID *)uuid
                      andTriggerBlock:(TriggerBlock)block {
    return [self initWithProximityUUID:uuid
                                 major:nil
                                 minor:nil
                       andTriggerBlock:block];
}

- (instancetype)initWithProximityUUID:(NSUUID *)uuid
                                major:(NSNumber *)major
                                minor:(NSNumber *)minor
                      andTriggerBlock:(TriggerBlock)block {
    if (!uuid) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"UUID must not be nil"
                                     userInfo:nil];
    }

    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:@"triggerBlock must not be nil"
                                     userInfo:nil];
    }

    if (self = [super init]) {
        _proximityUUID = uuid;
        _major = major;
        _minor = minor;
        _triggerBlock = [block copy];

        _isStarted = NO;
    }
    return self;
}

#pragma mark - Monitoring

- (void)start {
    if (![self hasLocationAuthorization]) {
        [self requestLocationAuthorization];
    }

    self.isStarted = YES;
    [self.locationManager startMonitoringForRegion:self.beaconRegion];
}

- (void)stop {
    self.isStarted = NO;
    [self.locationManager stopRangingBeaconsInRegion:self.beaconRegion];
    [self.locationManager stopMonitoringForRegion:self.beaconRegion];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
didStartMonitoringForRegion:(CLRegion *)region {
    [manager requestStateForRegion:region];
}

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region {
    if (CLRegionStateInside == state) {
        [self locationManager:manager didEnterRegion:region];
    }
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region {
    if (![self isValidRegion:region]) {
        return;
    }

    if ([[self.locationManager class] isRangingAvailable]) {
        [self.locationManager startRangingBeaconsInRegion:(CLBeaconRegion *)region];
    } else {
        NSLog(@"Ranging is not available");
    }
}

- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(CLRegion *)region
              withError:(NSError *)error {
    NSLog(@"Failed to monitor region: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region {
    if (![self isValidRegion:region] || !self.isStarted) {
        return;
    }

    // notify the delegate if at least one of the beacons is closer than "near"
    NSPredicate *beaconClosenessPredicate = [NSPredicate predicateWithFormat:@"%K IN %@",
                                             @"proximity", @[@(CLProximityNear), @(CLProximityImmediate)]];
    NSArray *closeBeacons = [beacons filteredArrayUsingPredicate:beaconClosenessPredicate];
    if (closeBeacons.count > 0) {
        self.triggerBlock();
    }
}

#pragma mark - Private Methods

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
    }
    _locationManager.delegate = self;
    return _locationManager;
}

- (BOOL)hasLocationAuthorization {
    const CLAuthorizationStatus status = [[self.locationManager class] authorizationStatus];
    return ((kCLAuthorizationStatusAuthorizedAlways == status) ||
            (kCLAuthorizationStatusAuthorizedWhenInUse == status));
}

- (void)requestLocationAuthorization {
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    self.locationManager.pausesLocationUpdatesAutomatically = NO;
}

- (CLBeaconRegion *)beaconRegion {
    // since all the region's values are immutable, don't need to recreate it
    if (!_beaconRegion) {
        const BOOL hasMajorAndMinor = (self.major && self.minor);

        _beaconRegion = [CLBeaconRegion alloc];
        if (hasMajorAndMinor) {
            _beaconRegion = [_beaconRegion initWithProximityUUID:self.proximityUUID
                                                           major:[self.major doubleValue]
                                                           minor:[self.minor doubleValue]
                                                      identifier:[self beaconIdentifier]];
        } else {
            _beaconRegion = [_beaconRegion initWithProximityUUID:self.proximityUUID
                                                      identifier:[self beaconIdentifier]];
        }

        _beaconRegion.notifyEntryStateOnDisplay = YES;
        _beaconRegion.notifyOnEntry = YES;
        _beaconRegion.notifyOnExit = NO;
    }
    return _beaconRegion;
}

- (NSString *)beaconIdentifier {
    // the object's address "%p" is used here to add uniqueness to the beacon
    // identifier, in case if another trigger is created with the same UUID
    return [NSString stringWithFormat:@"%@-%p", self.proximityUUID, self];
}

- (BOOL)isValidRegion:(CLRegion *)region {
    return [region.identifier isEqualToString:[self beaconIdentifier]];
}

@end

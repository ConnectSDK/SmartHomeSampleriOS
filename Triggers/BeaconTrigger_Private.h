//
//  BeaconTrigger_Private.h
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 2/20/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

@import CoreLocation;
#import "BeaconTrigger.h"

// yes, the private category breaks the interface immutability, however it's
// private

@interface BeaconTrigger () <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

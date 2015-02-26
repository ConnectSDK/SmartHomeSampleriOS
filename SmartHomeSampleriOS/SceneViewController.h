//
//  SceneViewController.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/20/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ConnectSDK/ConnectSDK.h>

#import "WeMoDiscoveryManager.h"

@interface SceneViewController : UIViewController <DiscoveryManagerDelegate, WeMoDeviceDiscoveryDelegate>

- (IBAction)actionSwitchTheSwitch:(id)sender;

@end

//
//  ConfigureSceneViewController.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 3/31/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ConnectSDK/ConnectSDK.h>

typedef enum {
    ConnectedDeviceType =0,
    HueDeviceType,
    WemoDeviceType,
    WinkDeviceType,
    BeaconDeviceType
}DeviceType;

@interface ConfigureSceneViewController : UIViewController

@property NSInteger currentSceneIndex;
@property(nonatomic, strong) NSMutableDictionary *contentDictionary;
@property(nonatomic, strong) NSMutableDictionary *sceneDictionary;

/// Returns @c YES if the scene config has been updated and saved.
@property (nonatomic, readonly) BOOL configHasChanged;

@property (nonatomic, copy) void (^configChangeBlock)(BOOL configHasChanged);

@end

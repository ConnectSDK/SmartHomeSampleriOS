//
//  ConfigureSceneViewController.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 3/31/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ConnectSDK/ConnectSDK.h>

@protocol ConfigureSceneViewControllerDelegate <NSObject>

-(void)updateDeviceSelected:(NSDictionary *)device withType:(NSInteger)type;

@end

typedef enum {
    ConnectedDeviceType =0,
    HueDeviceType,
    WemoDeviceType,
    WinkDeviceType,
    BeaconDeviceType
}DeviceType;

@interface ConfigureSceneViewController : UIViewController<ConfigureSceneViewControllerDelegate>

@property NSInteger currentSceneIndex;
@property(nonatomic, strong) NSMutableDictionary *contentDictionary;
@property(nonatomic, strong) NSMutableDictionary *sceneDictionary;
@end

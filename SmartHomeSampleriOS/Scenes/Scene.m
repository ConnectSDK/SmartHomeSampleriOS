//
//  Scene.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/19/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "Scene.h"

@implementation Scene


-(instancetype)initWithConfiguration:(NSDictionary *)configuration andSceneInfo:(SceneInfo *)sceneInfo{
    self = [super init];
    
    if (self)
    {
        self.configuration = configuration;
        self.sceneInfo = sceneInfo;
       // [self configureScene];
    }
    
    return self;
}

-(void)configureScene{
    if (self.conectableDevice) {
         [self.conectableDevice connect];
    }
    
    self.hueBridge = [PHBridgeResourcesReader readBridgeResourcesCache];
   
}

- (void)changeSceneState:(SceneState)state sucess:(SuccessBlock)sucess failure:(FailureBlock)failure {
    
}

#pragma mark - ConnectableDeviceDelegate

- (void) connectableDeviceReady:(ConnectableDevice *)device
{
    // TODO: this should be unnecessary
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                   });
}

- (void) connectableDevice:(ConnectableDevice *)device service:(DeviceService *)service pairingRequiredOfType:(int)pairingType withData:(id)pairingData
{
    if (pairingType == DeviceServicePairingTypeAirPlayMirroring)
        [(UIAlertView *) pairingData show];
}

- (void) connectableDeviceDisconnected:(ConnectableDevice *)device withError:(NSError *)error
{
    self.conectableDevice.delegate = nil;
    self.conectableDevice = nil;
}

@end

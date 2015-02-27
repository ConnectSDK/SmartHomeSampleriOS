//
//  SceneViewController.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/20/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "SceneViewController.h"
#import "Scene.h"
#import "SceneInfo.h"
#import "AppDelegate.h"
#import <ConnectSDK/DLNAService.h>
#import <ConnectSDK/WebOSTVService.h>
#import <ConnectSDK/SSDPDiscoveryProvider.h>
#import "BeaconTrigger.h"
#import "WeMoDiscoveryManager.h"

@interface SceneViewController () <DiscoveryManagerDelegate,
                                    WeMoDeviceDiscoveryDelegate>

@property(nonatomic , strong) DiscoveryManager *discoveryManager;
@property(nonatomic , strong) Scene *scene1;
@property(nonatomic , strong) Scene *scene2;
/// Array of currently active beacon triggers (@c beaconTrigger objects).
@property (nonatomic, strong) NSMutableArray *beaconTriggers;
@property (nonatomic, assign) NSUInteger currentSceneIndex;

@end

@implementation SceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentSceneIndex = -1;
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Scene" ofType:@"plist"];
    NSDictionary *contentDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary *scene1Dictionary = [[contentDictionary objectForKey:@"Scenes"] objectAtIndex:0];
    SceneInfo *sceneInfo = [[SceneInfo alloc] init];
    sceneInfo.mediaArray = [contentDictionary objectForKey:@"Media"];
    sceneInfo.currentMediaIndex = 0;
    sceneInfo.currentPosition = 0;
    self.scene1 = [[Scene alloc] initWithConfiguration:scene1Dictionary andSceneInfo:sceneInfo];
    
    NSDictionary *scene2Dictionary = [[contentDictionary objectForKey:@"Scenes"] objectAtIndex:1];
    self.scene2 = [[Scene alloc] initWithConfiguration:scene2Dictionary andSceneInfo:sceneInfo];
    
    // Do any additional setup after loading the view.
    _discoveryManager = [DiscoveryManager sharedManager];
    [_discoveryManager registerDeviceService:[DLNAService class] withDiscovery:[SSDPDiscoveryProvider class]];
    [_discoveryManager registerDeviceService:[WebOSTVService class] withDiscovery:[SSDPDiscoveryProvider class]];
    
    _discoveryManager.pairingLevel = DeviceServicePairingLevelOn;
    _discoveryManager.delegate = self;
    [_discoveryManager startDiscovery];
    
     [UIAppDelegate enableLocalHeartbeat];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [WeMoDiscoveryManager sharedWeMoDiscoveryManager].deviceDiscoveryDelegate = self;
        // * you must have the discovery settings in a file named
        // `DeviceConfigData.plist`
        // * according to the docs, this method returns immediately, which is
        // totally incorrect!
        [[WeMoDiscoveryManager sharedWeMoDiscoveryManager] discoverDevices:WeMoUpnpInterface];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)startScene1:(id)sender{
    [self performSelector:@selector(stopScene2:) withObject:nil afterDelay:2.0];
    self.scene1.sceneInfo = self.scene2.sceneInfo;
    
    [self.scene1 changeSceneState:Running success:^(id responseObject) {
        NSLog(@"Scene1 Started");
    } failure:^(NSError *error) {
        NSLog(@"Scene1 failure");
    }];
}

-(IBAction)startScene2:(id)sender{
    [self performSelector:@selector(stopScene1:) withObject:nil afterDelay:2.0];
    self.scene1.sceneInfo = self.scene2.sceneInfo;
    
    [self.scene2 changeSceneState:Running success:^(id responseObject) {
        NSLog(@"Scene2 Started");
    } failure:^(NSError *error) {
        NSLog(@"Scene2 failure");
    }];
}

-(IBAction)pauseScene1:(id)sender{
    [self.scene1 changeSceneState:Paused success:^(id responseObject) {
        NSLog(@"Scene1 Paused");
    } failure:^(NSError *error) {
        NSLog(@"Scene1 pause failure");
    }];
}

-(IBAction)pauseScene2:(id)sender{
    [self.scene2 changeSceneState:Paused success:^(id responseObject) {
        NSLog(@"Scene2 Paused");
    } failure:^(NSError *error) {
        NSLog(@"Scene2 pause failure");
    }];
}

-(IBAction)stopScene1:(id)sender{
    [self.scene1 changeSceneState:Stopped success:^(id responseObject) {
        NSLog(@"Scene1 Stopped");
    } failure:^(NSError *error) {
        NSLog(@"Scene1 stop failure");
    }];
}

-(IBAction)stopScene2:(id)sender{
    [self.scene2 changeSceneState:Stopped success:^(id responseObject) {
        NSLog(@"Scene2 Stoped");
    } failure:^(NSError *error) {
        NSLog(@"Scene2 stop failure");
    }];
}

- (IBAction)actionSwitchTheSwitch:(id)sender {
    // FIXME: this looks weird; need to create and use self.currentScene object
    WeMoControlDevice *currentDevice = (self.currentSceneIndex == 0 ? self.scene1 : self.scene2).wemoSwitch;

    WeMoSetStateStatus result = [currentDevice setPluginStatus:[self invertDeviceState:currentDevice.state]];
    if (WeMoStatusSuccess != result) {
        NSLog(@"OOps, couldn't update state: %d", result);
    }
}

-(IBAction)wakeMeUP:(id)sender{
    
    if(self.currentSceneIndex == 0){
        [self performSelector:@selector(stopScene1:) withObject:nil afterDelay:3.0];
        [self performSelector:@selector(startScene1:) withObject:nil afterDelay:300.0];
    }else{
        [self performSelector:@selector(stopScene2:) withObject:nil afterDelay:3.0];
        [self performSelector:@selector(startScene2:) withObject:nil afterDelay:30.0];
    }
}

-(IBAction)useBeaconsSwitchPressed:(id)sender{
    if (self.useBeaconsSwitch.on) {
        [self setupBeaconTriggers];
    } else {
        [self stopBeaconTriggering];
    }
}

#pragma mark - Triggers

- (void)setupBeaconTriggers {
    __weak typeof(self) wself = self;
    
    // scene 1
    [self startBeaconTriggerWithUUIDString:@"00001111-2222-3333-4444-555566667777"
                           andTriggerBlock:^{
                               typeof(self) sself = wself;
                               if (sself.currentSceneIndex != 0) {
                                   sself.currentSceneIndex = 0;
                                
                                   [self performSelector:@selector(stopScene2:) withObject:nil afterDelay:2.0];
                                   self.scene1.sceneInfo = self.scene2.sceneInfo;
                                   [self startScene1:nil];
                               }
                           }];
    
    // scene 2
    [self startBeaconTriggerWithUUIDString:@"88889999-aaaa-bbbb-cccc-ddddeeeeffff"
                           andTriggerBlock:^{
                               typeof(self) sself = wself;
                               if (sself.currentSceneIndex != 1) {
                                   sself.currentSceneIndex = 1;
                            
                                    [self performSelector:@selector(stopScene1:) withObject:nil afterDelay:2.0];
                                   self.scene2.sceneInfo = self.scene1.sceneInfo;
                                   [self startScene2:nil];
                               }
                           }];
}

- (void)startBeaconTriggerWithUUIDString:(NSString *)uuidString
                         andTriggerBlock:(TriggerBlock)block {
    NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:uuidString];
    BeaconTrigger *beaconTrigger = [[BeaconTrigger alloc] initWithProximityUUID:uuid
                                                                          major:@0
                                                                          minor:@0
                                                                andTriggerBlock:block];
    [beaconTrigger start];
    
    self.beaconTriggers = self.beaconTriggers ?: [NSMutableArray array];
    [self.beaconTriggers addObject:beaconTrigger];
}


- (void)stopBeaconTriggering {
    self.beaconTriggers = nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


# pragma mark - DiscoveryManagerDelegate methods

- (void)discoveryManager:(DiscoveryManager *)manager didFindDevice:(ConnectableDevice *)device
{
    if(device){
        
        NSLog(@"Device address %@ - %@ ",device.friendlyName,device.address);
        
        if(self.scene1 && self.scene2){
            NSDictionary *sceneDevice1 = [self.scene1.configuration valueForKey:@"device"];
            NSDictionary *sceneDevice2 = [self.scene2.configuration valueForKey:@"device"];
          
            if([device serviceWithName:kConnectSDKWebOSTVServiceId] && [[sceneDevice1 objectForKey:@"ip"] isEqualToString:device.address]){
                self.scene1.conectableDevice = device;
                [self.scene1 configureScene];
            }
            
            if([[sceneDevice2 objectForKey:@"ip"] isEqualToString:device.address]){
                self.scene2.conectableDevice = device;
                [self.scene2 configureScene];
            }
        }
    }
}

- (void)discoveryManager:(DiscoveryManager *)manager didLoseDevice:(ConnectableDevice *)device
{
    NSLog(@"Lost device %@",device.address);
}

- (void)discoveryManager:(DiscoveryManager *)manager didUpdateDevice:(ConnectableDevice *)device
{
    //Nothing
    if(device){
        
        NSLog(@"Device address %@",device.services);
        if(self.scene1 && self.scene2){
            NSDictionary *sceneDevice1 = [self.scene1.configuration valueForKey:@"device"];
            NSDictionary *sceneDevice2 = [self.scene2.configuration valueForKey:@"device"];
            
            if([device serviceWithName:kConnectSDKWebOSTVServiceId] && [[sceneDevice1 objectForKey:@"ip"] isEqualToString:device.address]){
                self.scene1.conectableDevice = device;
                [self.scene1 configureScene];
            }
            
            if([[sceneDevice2 objectForKey:@"ip"] isEqualToString:device.address]){
                self.scene2.conectableDevice = device;
                [self.scene2 configureScene];
            }
        }
    }
}

#pragma mark - WeMoDeviceDiscoveryDelegate

- (NSArray *)scenesForWemoSwitchUdn:(NSString *)udn {
    NSPredicate *udnMatchPredicate = [NSPredicate predicateWithFormat:@"configuration.wemoSwitch.udn == %@", udn];
    return [@[self.scene1, self.scene2] filteredArrayUsingPredicate:udnMatchPredicate];
}

- (void)discoveryManager:(WeMoDiscoveryManager *)manager
          didFoundDevice:(WeMoControlDevice *)device {
    NSLog(@"didFindDevice %@", device);

    [[self scenesForWemoSwitchUdn:device.udn] enumerateObjectsUsingBlock:^(Scene *scene, NSUInteger idx, BOOL *stop) {
        scene.wemoSwitch = device;
    }];
}

- (void)discoveryManager:(WeMoDiscoveryManager *)manager
     removeDeviceWithUdn:(NSString *)udn {
    NSLog(@"didRemoveDevice %@", udn);

    [[self scenesForWemoSwitchUdn:udn] enumerateObjectsUsingBlock:^(Scene *scene, NSUInteger idx, BOOL *stop) {
        scene.wemoSwitch = nil;
    }];
}

- (void)discoveryManagerRemovedAllDevices:(WeMoDiscoveryManager *)manager {
    NSLog(@"didRemoveAllDevices");

    [@[self.scene1, self.scene2] enumerateObjectsUsingBlock:^(Scene *scene, NSUInteger idx, BOOL *stop) {
        scene.wemoSwitch = nil;
    }];
}

- (WeMoDeviceState)invertDeviceState:(WeMoDeviceState)state {
    switch (state) {
        case WeMoDeviceOff:
            return WeMoDeviceOn;

        case WeMoDeviceOn:
            return WeMoDeviceOff;

        default:
            // what is this?
            return state;
    }
}

@end

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
#import <ConnectSDK/GCDWebServer.h>
#import "BeaconTrigger.h"
#import "WeMoDiscoveryManager.h"
#import "NuanceSpeech.h"

@interface SceneViewController () <DiscoveryManagerDelegate,
                                    WeMoDeviceDiscoveryDelegate>

@property(nonatomic , strong) DiscoveryManager *discoveryManager;
@property(nonatomic , strong) Scene *scene1;
@property(nonatomic , strong) Scene *scene2;
/// Array of currently active beacon triggers (@c beaconTrigger objects).
@property (nonatomic, strong) NSMutableArray *beaconTriggers;
@property (nonatomic, assign) NSUInteger currentSceneIndex;
@property (nonatomic,strong) NuanceSpeech *speechKit;
@property (nonatomic, strong) GCDWebServer *webServer;

@end

@implementation SceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.currentSceneIndex = -1;
    [self debugSwitchPressed:self.debugSwitch];
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

    [self setupUI];
    
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
    
    self.speechKit = [[NuanceSpeech alloc] init];
    [self.speechKit configure];

    [self useBeaconsSwitchPressed:self.useBeaconsSwitch];
    [self triggerOnNearSwitchChanged:self.triggerBeaconsOnNearSwitch];
}

- (void)setupUI {
    // sets the tab stop on the voice commands label, so the second column is
    // left-aligned
    static const CGFloat kTabStopPosition = 144.0f;
    NSMutableParagraphStyle *comLabelStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    NSTextTab *secondColumnTab = [[NSTextTab alloc] initWithTextAlignment:NSTextAlignmentLeft
                                                                 location:kTabStopPosition
                                                                  options:nil];
    comLabelStyle.tabStops = @[secondColumnTab];
    comLabelStyle.headIndent = kTabStopPosition;

    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:self.voiceCommandsLabel.text
                                                                   attributes:@{NSParagraphStyleAttributeName: comLabelStyle}];
    self.voiceCommandsLabel.attributedText = attrText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)startScene1:(id)sender{
    [self performSelector:@selector(stopScene2:) withObject:nil afterDelay:2.0];
    self.scene1.sceneInfo = self.scene2.sceneInfo;
  
    self.currentSceneIndex = 0;
    [self.scene1 changeSceneState:Running success:^(id responseObject) {
        NSLog(@"Scene1 Started");
    } failure:^(NSError *error) {
        NSLog(@"Scene1 failure");
    }];
}

-(IBAction)startScene2:(id)sender{
    [self performSelector:@selector(stopScene1:) withObject:nil afterDelay:2.0];
    self.scene1.sceneInfo = self.scene2.sceneInfo;
    self.currentSceneIndex = 1;
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

-(IBAction)wakeMeUp:(id)sender{
    
    [self.scene1 setSceneInfoWithMediaIndex:1 andPosition:0];
    [self.scene2 setSceneInfoWithMediaIndex:1 andPosition:0];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *currentTime = [dateFormatter stringFromDate:today];
    
    NSString *message = [NSString stringWithFormat:@"Its time to wake up. The time is %@",currentTime];
    
    NSString *urlString = [NSString stringWithFormat:@"http://www.translate.google.com/translate_tts?tl=en&q=%@",[message stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURL  *url = [NSURL URLWithString:urlString];
    NSData *urlData = [NSData dataWithContentsOfURL:url];
    if ( urlData )
    {
        //NSArray   *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = NSTemporaryDirectory();
        
        NSString  *filePath = [NSString stringWithFormat:@"%@%@", documentsDirectory,@"translate.mp3"];
        [urlData writeToFile:filePath atomically:YES];
    }
    
    if(self.webServer == nil){
        self.webServer = [[GCDWebServer alloc] init];
        [self.webServer addGETHandlerForBasePath:@"/" directoryPath:NSTemporaryDirectory() indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
        [self.webServer startWithPort:8080 bonjourName:nil];
    }
    
    
    NSString *newURL = [NSString stringWithFormat:@"%@%@",self.webServer.serverURL,@"translate.mp3"];
    
    if(self.currentSceneIndex == 0){
        [self.scene1 stopSceneWithTransition];
        [self.scene1 performSelector:@selector(playMessageFromURL:) withObject:newURL afterDelay:25.0];
        [self.scene1 performSelector:@selector(startSceneWithTransition) withObject:nil afterDelay:35.0];
    }else{
        [self.scene2 stopSceneWithTransition];
        [self.scene2 performSelector:@selector(playMessageFromURL:) withObject:newURL afterDelay:25.0];
        [self.scene2 performSelector:@selector(startSceneWithTransition) withObject:nil afterDelay:35.0];
    }
}

-(IBAction)voiceCommand:(id)sender{
    
    [self.speechKit recordVoiceWithResponse:^(NSString *responseString, NSError *error) {
        if(error){
            NSLog(@"Error in Speech Recognition");
        }
        
        
        if([responseString isEqualToString:@"Wake me up"] ||[responseString isEqualToString:@"Going to sleep"] ){
            [self wakeMeUp:nil];
        }
        
        if([responseString isEqualToString:@"i am home"] || [responseString isEqualToString:@"I'm home"]){
            if(self.currentSceneIndex == 0){
                [self performSelector:@selector(stopScene1:) withObject:nil afterDelay:1.0];
                [self performSelector:@selector(startScene1:) withObject:nil afterDelay:1.0];
            }else{
                [self performSelector:@selector(stopScene2:) withObject:nil afterDelay:1.0];
                [self performSelector:@selector(startScene2:) withObject:nil afterDelay:1.0];
            }
        }
        
        if([responseString isEqualToString:@"Start playing"] || [responseString isEqualToString:@"Play"] || [responseString isEqualToString:@"Start"]){
            if(self.currentSceneIndex == 0){
                [self performSelector:@selector(startScene1:) withObject:nil afterDelay:0.0];
            }else{
                [self performSelector:@selector(startScene2:) withObject:nil afterDelay:0.0];
            }
        }
        
        if([responseString isEqualToString:@"Stop playing"] || [responseString isEqualToString:@"Stop"]|| [responseString isEqualToString:@"I'm going to bed"]){
            if(self.currentSceneIndex == 0){
                [self performSelector:@selector(stopScene1:) withObject:nil afterDelay:0.0];
            }else{
                [self performSelector:@selector(stopScene2:) withObject:nil afterDelay:0.0];
            }
        }
        
        if([responseString isEqualToString:@"Pause"] || [responseString isEqualToString:@"Silence please"]|| [responseString isEqualToString:@"Pause Playing"]){
            if(self.currentSceneIndex == 0){
                [self performSelector:@selector(pauseScene1:) withObject:nil afterDelay:0.0];
            }else{
                [self performSelector:@selector(pauseScene2:) withObject:nil afterDelay:0.0];
            }
        }
    }];
    
}

-(IBAction)useBeaconsSwitchPressed:(id)sender{
    if (self.useBeaconsSwitch.on) {
        [self setupBeaconTriggers];
        [self triggerOnNearSwitchChanged:self.triggerBeaconsOnNearSwitch];
    } else {
        [self stopBeaconTriggering];
    }
}

- (IBAction)debugSwitchPressed:(UISwitch *)sender {
    self.debugView.hidden = !sender.on;
}

#pragma mark - Triggers

- (void)setupBeaconTriggers {
    __weak typeof(self) wself = self;

    // scene 1
    [self startBeaconTriggerWithUUIDString:[self.scene1.configuration valueForKeyPath:@"iBeacon.uuid"]
                           andTriggerBlock:^{
                               typeof(self) sself = wself;
                               if (sself.currentSceneIndex != 0) {
                                   sself.currentSceneIndex = 0;
                                
                                   [self performSelector:@selector(stopScene2:) withObject:nil afterDelay:2.0];
                                   self.scene1.sceneInfo = self.scene2.sceneInfo;
                                   [self startScene1:nil];

                                   sself.sceneInfoLabel.text = [NSString stringWithFormat:@"S1 active @ %@",
                                                                [self.timeFormatter stringFromDate:[NSDate date]]];
                               }
                           }];
    
    // scene 2
    [self startBeaconTriggerWithUUIDString:[self.scene2.configuration valueForKeyPath:@"iBeacon.uuid"]
                           andTriggerBlock:^{
                               typeof(self) sself = wself;
                               if (sself.currentSceneIndex != 1) {
                                   sself.currentSceneIndex = 1;
                            
                                    [self performSelector:@selector(stopScene1:) withObject:nil afterDelay:2.0];
                                   self.scene2.sceneInfo = self.scene1.sceneInfo;
                                   [self startScene2:nil];

                                   sself.sceneInfoLabel.text = [NSString stringWithFormat:@"S2 active @ %@",
                                                                [self.timeFormatter stringFromDate:[NSDate date]]];
                               }
                           }];
}

- (NSDateFormatter *)timeFormatter {
    static NSDateFormatter *timeFormatter = nil;
    if (!timeFormatter) {
        timeFormatter = [NSDateFormatter new];
        timeFormatter.dateFormat = @"HH:mm:ss";
    }

    return timeFormatter;
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

- (IBAction)triggerOnNearSwitchChanged:(UISwitch *)sender {
    const BOOL newTriggerOnNear = sender.on;
    for (BeaconTrigger *trigger in self.beaconTriggers) {
        trigger.triggerOnNearProximity = newTriggerOnNear;
    }
}

# pragma mark - DiscoveryManagerDelegate methods

- (void)discoveryManager:(DiscoveryManager *)manager didFindDevice:(ConnectableDevice *)device
{
    NSLog(@"Found device %@ - %@", device.friendlyName, device.address);
    [self didUpdateConnectableDevice:device];
}

- (void)discoveryManager:(DiscoveryManager *)manager didLoseDevice:(ConnectableDevice *)device
{
    NSLog(@"Lost device %@",device.address);
}

- (void)discoveryManager:(DiscoveryManager *)manager didUpdateDevice:(ConnectableDevice *)device
{
    NSLog(@"Updated device %@ - %@", device.friendlyName, device.address);
    [self didUpdateConnectableDevice:device];
}

- (void)didUpdateConnectableDevice:(ConnectableDevice *)device {
    if (device && self.scene1 && self.scene2) {
        const BOOL deviceHasWebOSService = ([device serviceWithName:kConnectSDKWebOSTVServiceId] != nil);

        for (Scene *scene in @[self.scene1, self.scene2]) {
            NSDictionary *sceneDevice = scene.configuration[@"device"];
            const BOOL requiresWebOSService = [sceneDevice[@"type"] isEqualToString:@"webostv"];
            const BOOL sceneRequiresDevice = [sceneDevice[@"name"] isEqualToString:device.friendlyName];

            if (sceneRequiresDevice &&
                ((requiresWebOSService && deviceHasWebOSService) || !requiresWebOSService)) {
                scene.connectableDevice = device;
                [scene configureScene];
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

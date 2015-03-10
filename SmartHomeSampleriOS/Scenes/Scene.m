//
//  Scene.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/19/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "Scene.h"
#import "UIImage+Color.h"
#import "WeMoControlDevice.h"
#import "WinkAPI.h"
#import "UIImage+ColorArt.h"
#import "Secret.h"

@interface Scene()

@property (nonatomic, strong) NSTimer *mediaInfoTimer;
@property (nonatomic, strong) LaunchSession *launchSession;
@property (nonatomic, strong) id<MediaControl> mediaControl;
@property (nonatomic, strong) MediaPlayStateSuccessBlock playStateHandler;
@property (nonatomic) NSTimeInterval estimatedMediaPosition;
@property (nonatomic) NSTimeInterval mediaDuration;
@property (nonatomic, strong) NSTimer *imageTimer;
@property (nonatomic) CGFloat currentVolume;
@property (nonatomic, strong) ServiceSubscription *volumeSubscription;
@property (nonatomic, strong) SLColorArt *imageColorArt;
@property (nonatomic, strong) WinkAPI *wink;
@property (nonatomic, strong) NuanceSpeech *speechKit;
@property (nonatomic, strong) NSTimer *volumeTimer;
@property (nonatomic, strong) NSTimer *lightTimer;
@property (nonatomic) CGFloat lastKnownVolume;
@end

@implementation Scene


-(instancetype)initWithConfiguration:(NSDictionary *)configuration andSceneInfo:(SceneInfo *)sceneInfo{
    self = [super init];
    
    if (self)
    {
        self.configuration = configuration;
        self.sceneInfo = sceneInfo;
    }
    
    return self;
}

-(void)configureScene{
    if (self.connectableDevice) {
         [self.connectableDevice connect];
    }
    self.currentState = Stopped;
    self.hueBridge = [PHBridgeResourcesReader readBridgeResourcesCache];
    
    if([self.configuration valueForKey:@"wink"]){
        self.wink = [[WinkAPI alloc] initWithUsername:kWinkUsername
                                             password:kWinkPassword
                                             clientId:kWinkClientId
                                         clientSecret:kWinkClientSecret];
        [self.wink authenticateWithResponse:^(NSData *data, NSURLResponse *response, NSError *error) {
            NSLog(@"Authenticated");
        }];
    }
}

- (void)changeSceneState:(SceneState)state success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    if(self.hueBridge == nil){
        self.hueBridge = [PHBridgeResourcesReader readBridgeResourcesCache];
    }
    if(self.mediaInfoTimer){
        [self.mediaInfoTimer invalidate];
    }
    if(self.imageTimer){
        [self.imageTimer invalidate];
    }
    switch (state) {
        case Running:
            if(self.currentState == Stopped ){
                [self startSceneWithSuccess:success andFailure:failure];
            }
            else
            if (self.currentState == Paused){
                [self playSceneWithSuccess:success andFailure:failure];
            }
            break;
        case Paused:
                [self pauseSceneWithSuccess:success andFailure:failure];
            break;
        case Stopped:
                [self stopSceneWithSuccess:success andFailure:failure];
            break;
        default:
            break;
    }
}

-(void)setSceneInfoWithMediaIndex:(NSInteger)index andPosition:(CGFloat)position{
    if(self.mediaInfoTimer){
        [self.mediaInfoTimer invalidate];
    }
    self.sceneInfo.currentMediaIndex = index;
    self.sceneInfo.currentPosition = position;
}

-(void)startSceneWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    [self switchOnLights:YES];
    [self playMediaWithSuccess:success andFailure:failure];
    [self turnOnSwitch];
    self.currentState = Running;
}

-(void)pauseSceneWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    [self pauseMedia];
    self.currentState = Paused;
    [self  switchOnoffWinkBulb:1 brightness:0.1];
}

-(void)playSceneWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    [self playMedia];
    self.currentState = Running;
    [self  switchOnoffWinkBulb:1 brightness:1.0];
}

-(void)stopSceneWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    [self stopMedia];
    [self switchOnLights:NO];
    [self turnOffSwitch];
    [self  switchOnoffWinkBulb:0 brightness:1];
    self.currentState = Stopped;
    
    if(self.volumeSubscription){
        [self.volumeSubscription unsubscribe];
    }
}

-(void)stopSceneWithTransition{
    self.lastKnownVolume = self.currentVolume;
    [self  switchOnoffWinkBulb:1 brightness:0.5];
    NSNumber *volumeUp = [NSNumber numberWithBool:NO];
    self.volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setVolumeTransition:) userInfo:volumeUp repeats:YES];
}

-(void)startSceneWithTransition{
    [self setVolume:0];
    [self setSceneInfoWithMediaIndex:2 andPosition:0];
    [self startSceneWithSuccess:nil andFailure:nil];
    NSNumber *volumeUp = [NSNumber numberWithBool:YES];
    self.volumeTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setVolumeTransition:) userInfo:volumeUp repeats:YES];
    
}

-(void)setVolumeTransition:(NSTimer*)timer{
    
    BOOL volumeUp = [[timer userInfo] boolValue];
    if(volumeUp){
        if(self.currentVolume == self.lastKnownVolume){
            [self.volumeTimer invalidate];
            
        }else{
            [self setVolume:self.currentVolume+0.01];
            [self playLights];
            return;
        }
    }else{
        if(self.currentVolume > 0){
            [self setVolume:self.currentVolume-0.01];
            [self playLights];
        }else{
            [self.volumeTimer invalidate];
            [self stopSceneWithSuccess:nil andFailure:nil];
            return;
        }
        
        
    }
}

-(void)playMediaWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    
    [self setMute:NO];
    if(self.sceneInfo.currentPosition > 0){
        [self setMute:YES];
    }
    if ([self.connectableDevice hasCapability:kVolumeControlVolumeSubscribe])
    {
        _volumeSubscription = [self.connectableDevice.volumeControl subscribeVolumeWithSuccess:^(float volume)
                               {
                                   self.currentVolume = volume;
                                   
                               } failure:^(NSError *error)
                               {
                                   NSLog(@"Subscribe Vol Error %@", error.localizedDescription);
                               }];
    }
    
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    _playStateHandler = ^(MediaControlPlayState playState)
    {
        NSLog(@"play state change %@", @(playState));
        
        if (playState == MediaControlPlayStatePlaying)
        {
            if (weakSelf->_mediaInfoTimer)
                [weakSelf->_mediaInfoTimer invalidate];
            
            weakSelf->_mediaInfoTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:weakSelf selector:@selector(updateMediaInfo) userInfo:nil repeats:YES];

        } else if (playState == MediaControlPlayStateFinished)
        {
        }
    };
    
    NSDictionary *mediaInfoDict = [self.sceneInfo.mediaArray objectAtIndex:self.sceneInfo.currentMediaIndex];
    NSURL *mediaURL =  [NSURL URLWithString:[mediaInfoDict valueForKey:@"mediaURL"]];
    NSURL *iconURL = [NSURL URLWithString:[mediaInfoDict valueForKey:@"iconURL"]];
    NSString *title = [mediaInfoDict valueForKey:@"title"];
    NSString *description = [mediaInfoDict valueForKey:@"description"];
    NSString *mimeType = [mediaInfoDict valueForKey:@"mimeType"];
    BOOL shouldLoop = NO;
    
    MediaInfo *mediaInfo = [[MediaInfo alloc] initWithURL:mediaURL mimeType:mimeType];
    mediaInfo.title = title;
    mediaInfo.description = description;
    ImageInfo *imageInfo = [[ImageInfo alloc] initWithURL:iconURL type:ImageTypeThumb];
    [mediaInfo addImage:imageInfo];
    
    [self.connectableDevice.mediaPlayer playMediaWithMediaInfo:mediaInfo shouldLoop:shouldLoop
                                            success:^(MediaLaunchObject *launchObject) {
                                                NSLog(@"Play audio success");
                                                
                                                _launchSession = launchObject.session;
                                                _mediaControl = launchObject.mediaControl;
                                                
                                                NSData *data = [NSData dataWithContentsOfURL:iconURL];
                                                self.currentImage = [UIImage imageWithData:data];
                                                self.imageColorArt = [self.currentImage colorArt];
                                                [self startTimer:nil];
                                                [self  switchOnoffWinkBulb:1 brightness:1];
                                                if(self.sceneInfo.currentPosition > 0){
                                                    [self performSelector:@selector(seekMedia) withObject:nil afterDelay:2.0];
                                                }else{
                                                 self.mediaInfoTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateMediaInfo) userInfo:nil repeats:YES];
                                                }

                                                if(success)
                                                success(launchObject);
                                                
                                            } failure:^(NSError *error) {
                                                NSLog(@"display audio failure: %@", error.localizedDescription);
                                                if(failure)
                                                failure(error);
                                            }];
}

- (void) updateMediaInfo
{
    if (![self.connectableDevice hasCapability:kMediaControlPlayStateSubscribe])
        [self.mediaControl getPlayStateWithSuccess:_playStateHandler failure:nil];
    
    if ([self.connectableDevice hasCapabilities:@[kMediaControlDuration, kMediaControlPosition]])
    {
        [self.mediaControl getDurationWithSuccess:^(NSTimeInterval duration)
         {
             self.mediaDuration = duration;
            
         } failure:nil];
        
        [_mediaControl getPositionWithSuccess:^(NSTimeInterval position)
         {
             self.estimatedMediaPosition = position;
             self.sceneInfo.currentPosition = position;
             if(self.mediaDuration == self.estimatedMediaPosition){
                 if(self.sceneInfo.currentMediaIndex+1 == self.sceneInfo.mediaArray.count){
                     self.sceneInfo.currentMediaIndex = 0;
                 }else{
                     self.sceneInfo.currentMediaIndex ++;
                 }
                 self.sceneInfo.currentPosition = 0;
                 
                 [self.mediaInfoTimer invalidate];
                 [self playMediaWithSuccess:nil andFailure:nil];
             }

         } failure:nil];
    }
    
}

-(void)playMedia
{
    [self.mediaControl playWithSuccess:^(id responseObject)
     {
         NSLog(@"play success");
          self.mediaInfoTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(updateMediaInfo) userInfo:nil repeats:YES];
         [self startTimer:nil];
     } failure:^(NSError *error)
     {
         NSLog(@"play failure: %@", error.localizedDescription);
     }];
}

-(void)pauseMedia{
    
    [self.mediaControl pauseWithSuccess:^(id responseObject)
     {
         NSLog(@"pause success");
         [self stopTimer:nil];
     } failure:^(NSError *error)
     {
         NSLog(@"pause failure: %@", error.localizedDescription);
     }];
}

-(void)stopMedia{
    
    [self.mediaControl stopWithSuccess:^(id responseObject)
     {
         NSLog(@"stop success");
         [self stopTimer:nil];
     } failure:^(NSError *error)
     {
         NSLog(@"stop failure: %@", error.localizedDescription);
     }];
    
}

-(void)seekMedia{
   [_mediaControl seek:self.sceneInfo.currentPosition success:^(id responseObject)
     {
         [self setMute:NO];
         self.estimatedMediaPosition = self.sceneInfo.currentPosition;
         self->_playStateHandler(MediaControlPlayStatePlaying);
     } failure:^(NSError *error)
     {
         NSLog(@"seek failure: %@", error.localizedDescription);
     }];
    
}

-(void)setMute:(BOOL)mute{
    [self.connectableDevice.volumeControl setMute:mute success:^(id responseObject) {
        NSLog(@"Mute set");
    } failure:^(NSError *error) {
        NSLog(@"Mute set failure");
    }];
}

-(void)setVolume:(CGFloat)volume{
    [self.connectableDevice.volumeControl setVolume:volume success:^(id responseObject) {
        NSLog(@"Volume set");
        [self.connectableDevice.volumeControl getVolumeWithSuccess:^(float volume)
         {
             NSLog(@"Vol rolled back to actual %f", volume);
             
             self.currentVolume = volume;
         } failure:^(NSError *getVolumeError)
         {
             NSLog(@"Vol serious error: %@", getVolumeError.localizedDescription);
         }];
    } failure:^(NSError *error) {
        NSLog(@"Volume set failure");
    }];
}

-(void)playMessageFromURL:(NSString *)urlString{
    [self setVolume:self.lastKnownVolume];
    NSURL *mediaURL =  [NSURL URLWithString:urlString];
    NSURL *iconURL = nil;
    NSString *title = @"Wake up message";
    NSString *description = @"Wake up message";
    NSString *mimeType = @"audio/mp3";
    BOOL shouldLoop = NO;
    
    MediaInfo *mediaInfo = [[MediaInfo alloc] initWithURL:mediaURL mimeType:mimeType];
    mediaInfo.title = title;
    mediaInfo.description = description;
    ImageInfo *imageInfo = [[ImageInfo alloc] initWithURL:iconURL type:ImageTypeThumb];
    [mediaInfo addImage:imageInfo];
    
    [self.connectableDevice.mediaPlayer playMediaWithMediaInfo:mediaInfo shouldLoop:shouldLoop
                                                      success:^(MediaLaunchObject *launchObject) {
                                                          NSLog(@"Play wake up message success");
                                                          [self switchOnLights:YES];
                                                          [self  switchOnoffWinkBulb:1 brightness:0.5];
                                                      } failure:^(NSError *error) {
                                                          NSLog(@"display audio failure: %@", error.localizedDescription);
                                                      }];
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
    self.connectableDevice.delegate = nil;
    self.connectableDevice = nil;
}

#pragma mark - Philips Hue

-(void)switchOnLights:(BOOL)on{
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    NSDictionary *bulbs =  [self.configuration valueForKey:@"hueBulb"];
    
    for (NSString *lightId in bulbs) {
        PHLight *light = [self.hueBridge.lights objectForKey:lightId];
            PHLightState *lightState = [[PHLightState alloc] init];
            [lightState setCt:[NSNumber numberWithInt:153]];
            [lightState setOnBool:on];
            [lightState setBrightness:[NSNumber numberWithInt:self.currentVolume*254]];
            // Send lightstate to light
            [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
                if (errors != nil) {
                    NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                    
                    NSLog(@"Response: %@",message);
                }
                
            }];
        }
}

- (void)playLights{
    UIColor *imageColor;
  //  UIImage *mediaImage = self.currentImage;
//    size_t width = CGImageGetWidth(mediaImage.CGImage);
//    size_t height = CGImageGetHeight(mediaImage.CGImage);
//    int randomX = arc4random() % width;
//    int randomY = arc4random() % height;
//    imageColor = [mediaImage getPixelColorAtLocation:CGPointMake(randomX, randomY)];
    imageColor = [self getRandomColorFromImageColorArt];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    NSDictionary *bulbs =  [self.configuration valueForKey:@"hueBulb"];
    for (NSString *lightId in bulbs) {
        PHLight *light = [self.hueBridge.lights objectForKey:lightId];
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.colormode = COLORMODE_XY;
        CGPoint xy = [PHUtilities calculateXY:imageColor forModel:light.modelNumber];
        [lightState setX:[NSNumber numberWithFloat:xy.x]];
        [lightState setY:[NSNumber numberWithFloat:xy.y]];
        NSNumber *brightness = [NSNumber numberWithInt:self.currentVolume*10*254];
        if([brightness intValue]>254){
            brightness = @(254);
        }
        [lightState setBrightness:brightness];
        [lightState setOnBool:YES];
        NSLog(@"Value %@, Brightness %@",brightness,lightState.brightness);
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
        }];
    }
}

-(IBAction)stopTimer:(id)sender{
    [self.imageTimer invalidate];
    self.imageTimer = nil;
}

-(IBAction)startTimer:(id)sender{
    [self stopTimer:nil];
    [self playLights];
    self.imageTimer =[NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(playLights) userInfo:nil repeats:YES];
}

-(UIColor *)getRandomColorFromImageColorArt{
    UIColor *color = [UIColor whiteColor];
    int random = arc4random()%4;
    if(random == 1){
        color = self.imageColorArt.primaryColor;
    }else if (random == 2){
        color = self.imageColorArt.detailColor;
    }else if (random == 3){
        color = self.imageColorArt.secondaryColor;
    }else if (random == 4){
        color = self.imageColorArt.backgroundColor;
    }
    
    return color;
}

-(void)switchOnoffWinkBulb:(int)power brightness:(float)brightness{
    if(self.wink){
        NSString *bulbId = [[self.configuration valueForKey:@"wink"] valueForKey:@"bulbId"];
        
        [self.wink updateBulb:[bulbId intValue] power:power brightness:brightness];
    }
}

#pragma mark - WemoSwitch

- (void)turnOnSwitch {
    [self setSwitchState:WeMoDeviceOn];
}

- (void)turnOffSwitch {
    [self setSwitchState:WeMoDeviceOff];
}

- (void)setSwitchState:(WeMoDeviceState)state {
    WeMoSetStateStatus result = (self.wemoSwitch ? [self.wemoSwitch setPluginStatus:state] : WeMoStatusSuccess);
    if (WeMoStatusSuccess != result) {
        NSLog(@"Failed to switch wemo switch to state %d: %d", state, result);
    }
}

@end

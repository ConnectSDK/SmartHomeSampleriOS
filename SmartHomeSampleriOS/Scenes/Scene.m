//
//  Scene.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/19/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "Scene.h"
#import "UIImage+Color.h"

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
    if (self.conectableDevice) {
         [self.conectableDevice connect];
    }
    self.currentState = Stopped;
    self.hueBridge = [PHBridgeResourcesReader readBridgeResourcesCache];
   
}

- (void)changeSceneState:(SceneState)state success:(SuccessBlock)success failure:(FailureBlock)failure {
    
    if(self.hueBridge == nil){
        self.hueBridge = [PHBridgeResourcesReader readBridgeResourcesCache];
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
            if(self.currentState == Running){
                [self pauseSceneWithSuccess:success andFailure:failure];
            }
            break;
        case Stopped:
            if(self.currentState == Paused || self.currentState == Running){
                [self stopSceneWithSuccess:success andFailure:failure];
            }
            break;
        default:
            break;
    }
}

-(void)startSceneWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    [self playMediaWithSuccess:success andFailure:failure];
    self.currentState = Running;
}

-(void)pauseSceneWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    [self pauseMedia];
    self.currentState = Paused;
}

-(void)playSceneWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    [self playMedia];
    self.currentState = Running;
}

-(void)stopSceneWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    [self stopMedia];
    [self switchOffLights];
    self.currentState = Stopped;
    
    if(self.volumeSubscription){
        [self.volumeSubscription unsubscribe];
    }
}


-(void)playMediaWithSuccess:(SuccessBlock)success andFailure:(FailureBlock)failure{
    
    if ([self.conectableDevice hasCapability:kVolumeControlVolumeSubscribe])
    {
        _volumeSubscription = [self.conectableDevice.volumeControl subscribeVolumeWithSuccess:^(float volume)
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
    
    [self.conectableDevice.mediaPlayer playMediaWithMediaInfo:mediaInfo shouldLoop:shouldLoop
                                            success:^(MediaLaunchObject *launchObject) {
                                                NSLog(@"Play audio success");
                                                
                                                _launchSession = launchObject.session;
                                                _mediaControl = launchObject.mediaControl;
                                                
                                                NSData *data = [NSData dataWithContentsOfURL:iconURL];
                                                self.currentImage = [UIImage imageWithData:data];
                                                [self startTimer:nil];
                                                
                                                if ([self.conectableDevice hasCapability:kMediaControlPlayStateSubscribe])
                                                {
                                                    [self.mediaControl subscribePlayStateWithSuccess:_playStateHandler failure:^(NSError *error)
                                                     {
                                                         NSLog(@"subscribe play state failure: %@", error.localizedDescription);
                                                     }];
                                                } else
                                                {
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
    if (![self.conectableDevice hasCapability:kMediaControlPlayStateSubscribe])
        [self.mediaControl getPlayStateWithSuccess:_playStateHandler failure:nil];
    
    if ([self.conectableDevice hasCapabilities:@[kMediaControlDuration, kMediaControlPosition]])
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
         NSLog(@"seek success");
         
         self.estimatedMediaPosition = self.sceneInfo.currentPosition;
         self->_playStateHandler(MediaControlPlayStatePlaying);
     } failure:^(NSError *error)
     {
         NSLog(@"seek failure: %@", error.localizedDescription);
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
    self.conectableDevice.delegate = nil;
    self.conectableDevice = nil;
}


#pragma mark - Philips Hue

-(void)switchOffLights{
    
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    NSDictionary *bulbs =  [self.configuration valueForKey:@"hueBulb"];
    
    for (NSString *lightId in bulbs) {
        PHLight *light = [self.hueBridge.lights objectForKey:lightId];
            PHLightState *lightState = [[PHLightState alloc] init];
            [lightState setOnBool:NO];
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
    UIImage *mediaImage = self.currentImage;
    size_t width = CGImageGetWidth(mediaImage.CGImage);
    size_t height = CGImageGetHeight(mediaImage.CGImage);
    int randomX = arc4random() % width;
    int randomY = arc4random() % height;
    imageColor = [mediaImage getPixelColorAtLocation:CGPointMake(randomX, randomY)];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    NSDictionary *bulbs =  [self.configuration valueForKey:@"hueBulb"];
    for (NSString *lightId in bulbs) {
        PHLight *light = [self.hueBridge.lights objectForKey:lightId];
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.colormode = COLORMODE_XY;
        CGPoint xy = [PHUtilities calculateXY:imageColor forModel:light.modelNumber];
        [lightState setX:[NSNumber numberWithFloat:xy.x]];
        [lightState setY:[NSNumber numberWithFloat:xy.y]];
        [lightState setBrightness:[NSNumber numberWithInt:self.currentVolume*254*2]];
        [lightState setOnBool:YES];
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
    self.imageTimer =[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playLights) userInfo:nil repeats:YES];
}


@end

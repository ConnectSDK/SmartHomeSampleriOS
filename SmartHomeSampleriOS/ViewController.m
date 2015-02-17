//
//  ViewController.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/10/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "UIImage+Color.h"

@interface ViewController ()

@end

@implementation ViewController{
    DiscoveryManager *_discoveryManager;
    DevicePicker *_devicePicker;
    LaunchSession *_launchSession;
    id<MediaControl> _mediaControl;
    ServiceSubscription *_volumeSubscription;
    ServiceSubscription *_playStateSubscription;
    NSTimer *_playTimer;
    MediaPlayStateSuccessBlock _playStateHandler;
    NSTimer *_slideShowTimer;
    NSInteger _currentImageIndex;
    NSArray *_imageArray;
    BOOL _isSlideShowRuning;
}

- (void)viewDidLoad {
    
    _discoveryManager = [DiscoveryManager sharedManager];
    _discoveryManager.pairingLevel = DeviceServicePairingLevelOn;
    [_discoveryManager startDiscovery];
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    __unsafe_unretained typeof(self) weakSelf = self;
    
    _playStateHandler = ^(MediaControlPlayState playState)
    {
        if (playState == MediaControlPlayStatePlaying)
        {
            if (weakSelf->_playTimer)
                [weakSelf->_playTimer invalidate];
             weakSelf->_playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:weakSelf selector:@selector(updateControls) userInfo:nil repeats:YES];
            
        } else if (playState == MediaControlPlayStateFinished)
        {
            [weakSelf resetMediaControlComponents];
            [weakSelf stopTimer:nil];
        } else
        {
            if (weakSelf->_playTimer)
                [weakSelf->_playTimer invalidate];
        }
    };
    
    if(!self.device){
        [self removeSubscriptions];
    }
    
    NSMutableDictionary *image1 = [NSMutableDictionary dictionary];
    [image1 setValue:@"http://192.168.1.6/media/sms-data/Public/Photos/slideshow/image1.jpg" forKey:@"imagePath"];
    NSMutableDictionary *image2 = [NSMutableDictionary dictionary];
    [image2 setValue:@"http://192.168.1.6/media/sms-data/Public/Photos/slideshow/image2.jpg" forKey:@"imagePath"];
    NSMutableDictionary *image3 = [NSMutableDictionary dictionary];
    [image3 setValue:@"http://192.168.1.6/media/sms-data/Public/Photos/slideshow/image3.jpg" forKey:@"imagePath"];
    NSMutableDictionary *image4 = [NSMutableDictionary dictionary];
    [image4 setValue:@"http://192.168.1.6/media/sms-data/Public/Photos/slideshow/image4.jpg" forKey:@"imagePath"];
    _imageArray = [[NSArray alloc] initWithObjects:image1,image2,image3,image4, nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Media

- (void) addSubscriptions
{
    if (self.device)
    {
        if ([self.device hasCapability:kMediaPlayerDisplayImage]) [_slideShowButton setEnabled:YES];
        if ([self.device hasCapability:kMediaPlayerPlayVideo]) [_playVideoButton setEnabled:YES];
        if ([self.device hasCapability:kMediaPlayerPlayAudio]) [_playAudioButton setEnabled:YES];
    } else
    {
        [self removeSubscriptions];
    }
}

- (void) removeSubscriptions
{
    [self resetMediaControlComponents];
    
    [_slideShowButton setEnabled:NO];
    [_playVideoButton setEnabled:NO];
    [_playAudioButton setEnabled:NO];
}

- (void) resetMediaControlComponents
{
    if (_playTimer)
    {
        [_playTimer invalidate];
        _playTimer = nil;
    }
    
    [self stopTimer:nil];
    
    if (_playStateSubscription) {
        [_playStateSubscription unsubscribe];
        _playStateSubscription = nil;
    }
    
    if (_volumeSubscription) {
        [_volumeSubscription unsubscribe];
        _volumeSubscription = nil;
    }
    
    _launchSession = nil;
    _mediaControl = nil;
    
    
    [_playButton setEnabled:NO];
    [_pauseButton setEnabled:NO];
    [_stopButton setEnabled:NO];
    [_closeMediaButton setEnabled:NO];
    
    [_volumeSlider setEnabled:NO];
    [_volumeSlider setValue:0 animated:NO];
   
}

- (void) enableMediaControlComponents
{
    if ([self.device hasCapability:kMediaControlPlay]) [_playButton setEnabled:YES];
    if ([self.device hasCapability:kMediaControlPause]) [_pauseButton setEnabled:YES];
    if ([self.device hasCapability:kMediaControlStop]) [_stopButton setEnabled:YES];
    
    if ([self.device hasCapability:kMediaControlPlayStateSubscribe])
    {
        [_mediaControl subscribePlayStateWithSuccess:_playStateHandler failure:^(NSError *error)
         {
             NSLog(@"subscribe play state failure: %@", error.localizedDescription);
         }];
    } else
    {
        _playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateControls) userInfo:nil repeats:YES];
    }
    
    if ([self.device hasCapability:kVolumeControlMuteSet]) [_volumeSlider setEnabled:YES];
    
    if ([self.device hasCapability:kVolumeControlVolumeSubscribe])
    {
        _volumeSubscription = [self.device.volumeControl subscribeVolumeWithSuccess:^(float volume)
                               {
                                   [_volumeSlider setValue:volume];
                                   [_volumeSlider setEnabled:YES];
                                   NSLog(@"volume changed to %f", volume);
                               } failure:^(NSError *error)
                               {
                                   NSLog(@"Subscribe Vol Error %@", error.localizedDescription);
                               }];
    } else if ([self.device hasCapability:kVolumeControlVolumeGet])
    {
        [self.device.volumeControl getVolumeWithSuccess:^(float volume)
         {
             [_volumeSlider setValue:volume];
             NSLog(@"Get vol %f", volume);
         } failure:^(NSError *error)
         {
             NSLog(@"Get Vol Error %@", error.localizedDescription);
         }];
    }
}

- (void) updateControls
{
    
}

#pragma mark - Actions

- (IBAction) hConnect:(id)sender
{
    if (_device)
        [_device disconnect];
    else
        [self findDevice];
}


-(IBAction)connectToHueBridge:(id)sender{
    [UIAppDelegate enableLocalHeartbeat];
}

- (IBAction)startSlideShow:(id)sender {
    
    [self resetMediaControlComponents];
    _currentImageIndex = 0;
    if(_isSlideShowRuning){
        [_slideShowTimer invalidate];
        _slideShowTimer = nil;
    }else{
        _isSlideShowRuning = YES;
        [self displayImage];
        _slideShowTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(displayImage) userInfo:nil repeats:YES];
    }
    
}


-(void)displayImage{
    
    if(_currentImageIndex > [_imageArray count] -1){
        [_slideShowTimer invalidate];
        _isSlideShowRuning = NO;
        [self stopTimer:nil];
        return;
    }
    
    NSDictionary *imageDict = [_imageArray objectAtIndex:_currentImageIndex];
    NSURL *mediaURL = [NSURL URLWithString:[imageDict valueForKey:@"imagePath"]];
    NSURL *iconURL = mediaURL;
    NSString *title = @"Colorful Pictures";
    NSString *description = @"Pictures";
    NSString *mimeType = @"image/jpeg";
    
    MediaInfo *mediaInfo = [[MediaInfo alloc] initWithURL:mediaURL mimeType:mimeType];
    mediaInfo.title = title;
    mediaInfo.description = description;
    ImageInfo *imageInfo = [[ImageInfo alloc] initWithURL:iconURL type:ImageTypeThumb];
    [mediaInfo addImage:imageInfo];
    
    [self.device.mediaPlayer displayImageWithMediaInfo:mediaInfo
                                               success:^(MediaLaunchObject *launchObject) {
                                                   NSLog(@"display photo success");
                                                   _launchSession = launchObject.session;
                                                   if ([self.device hasCapability:kMediaPlayerClose])
                                                       [_closeMediaButton setEnabled:YES];
                                                   
                                                   _currentImageIndex++;
                                                   NSData *data = [NSData dataWithContentsOfURL:mediaURL];
                                                   self.imageView.image  = [[UIImage alloc] initWithData:data];
                                                   [self startTimer:nil];
                                               } failure:^(NSError *error) {
                                                   NSLog(@"display photo failure: %@", error.localizedDescription);
                                                   
                                               }];
}

- (IBAction)playVideo:(id)sender {
    
    [self resetMediaControlComponents];
    
    NSURL *mediaURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"videoPath"]];
    NSURL *iconURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"videoThumbPath"]];
    NSString *title = [[NSUserDefaults standardUserDefaults] stringForKey:@"videoTitle"];
    NSString *description = [[NSUserDefaults standardUserDefaults] stringForKey:@"videoDescription"];
    NSString *mimeType = [[NSUserDefaults standardUserDefaults] stringForKey:@"videoMimeType"];
    BOOL shouldLoop = NO;
    
    MediaInfo *mediaInfo = [[MediaInfo alloc] initWithURL:mediaURL mimeType:mimeType];
    mediaInfo.title = title;
    mediaInfo.description = description;
    ImageInfo *imageInfo = [[ImageInfo alloc] initWithURL:iconURL type:ImageTypeThumb];
    [mediaInfo addImage:imageInfo];
    
    [self.device.mediaPlayer playMediaWithMediaInfo:mediaInfo shouldLoop:shouldLoop
                                            success:^(MediaLaunchObject *launchObject) {
                                                NSLog(@"display video success");
                                                _launchSession = launchObject.session;
                                                _mediaControl = launchObject.mediaControl;
                                                
                                                if ([self.device hasCapability:kMediaPlayerClose])
                                                    [_closeMediaButton setEnabled:YES];
                                            
                                                [self enableMediaControlComponents];
                                                NSData *data = [NSData dataWithContentsOfURL:iconURL];
                                                self.imageView.image  = [[UIImage alloc] initWithData:data];
                                                [self startTimer:nil];
                                            } failure:^(NSError *error) {
                                                NSLog(@"display video failure: %@", error.localizedDescription);
                                            }];
}

- (IBAction)playAudio:(id)sender {
    
    [self resetMediaControlComponents];
    
    NSURL *mediaURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"audioPath"]];
    NSURL *iconURL = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"audioThumbPath"]];
    NSString *title = [[NSUserDefaults standardUserDefaults] stringForKey:@"audioTitle"];
    NSString *description = [[NSUserDefaults standardUserDefaults] stringForKey:@"audioDescription"];
    NSString *mimeType = [[NSUserDefaults standardUserDefaults] stringForKey:@"audioMimeType"];
    BOOL shouldLoop = NO;
    
    MediaInfo *mediaInfo = [[MediaInfo alloc] initWithURL:mediaURL mimeType:mimeType];
    mediaInfo.title = title;
    mediaInfo.description = description;
    ImageInfo *imageInfo = [[ImageInfo alloc] initWithURL:iconURL type:ImageTypeThumb];
    [mediaInfo addImage:imageInfo];
    
    [self.device.mediaPlayer playMediaWithMediaInfo:mediaInfo shouldLoop:shouldLoop
                                            success:^(MediaLaunchObject *launchObject) {
                                                NSLog(@"display audio success");
                                                
                                                _launchSession = launchObject.session;
                                                _mediaControl = launchObject.mediaControl;
                                                
                                                if ([self.device hasCapability:kMediaPlayerClose])
                                                    [_closeMediaButton setEnabled:YES];
                                                NSData *data = [NSData dataWithContentsOfURL:iconURL];
                                                self.imageView.image  = [[UIImage alloc] initWithData:data];
                                                [self startTimer:nil];
                                                
                                                [self enableMediaControlComponents];
                                            } failure:^(NSError *error) {
                                                NSLog(@"display audio failure: %@", error.localizedDescription);
                                            }];
}

- (IBAction)closeMedia:(id)sender
{
    if (!_launchSession)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_launchSession closeWithSuccess:^(id responseObject) {
        NSLog(@"close media success");
        [self resetMediaControlComponents];
    } failure:^(NSError *error) {
        NSLog(@"close media failure: %@", error.localizedDescription);
    }];
}

-(void)playClicked:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_mediaControl playWithSuccess:^(id responseObject)
     {
         NSLog(@"play success");
         [self startTimer:nil];
     } failure:^(NSError *error)
     {
         NSLog(@"play failure: %@", error.localizedDescription);
     }];
}

-(void)pauseClicked:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_mediaControl pauseWithSuccess:^(id responseObject)
     {
         NSLog(@"pause success");
         [self stopTimer:nil];
     } failure:^(NSError *error)
     {
         NSLog(@"pause failure: %@", error.localizedDescription);
     }];
}

-(void)stopClicked:(id)sender
{
    if (!_mediaControl)
    {
        [self resetMediaControlComponents];
        return;
    }
    
    [_mediaControl stopWithSuccess:^(id responseObject)
     {
         NSLog(@"stop success");
         [self resetMediaControlComponents];
     } failure:^(NSError *error)
     {
         NSLog(@"stop failure: %@", error.localizedDescription);
     }];
}

- (IBAction)volumeChanged:(UISlider *)sender
{
    float vol = [_volumeSlider value];
    
    [self.device.volumeControl setVolume:vol success:^(id responseObject)
     {
         NSLog(@"Vol Change Success %f", vol);
     } failure:^(NSError *setVolumeError)
     {
         // For devices which don't support setVolume, we'll disable
         // slider and should encourage volume up/down instead
         
         NSLog(@"Vol Change Error %@", setVolumeError.description);
         
         sender.enabled = NO;
         sender.userInteractionEnabled = NO;
         
         [self.device.volumeControl getVolumeWithSuccess:^(float volume)
          {
              NSLog(@"Vol rolled back to actual %f", volume);
              
              sender.value = volume;
          } failure:^(NSError *getVolumeError)
          {
              NSLog(@"Vol serious error: %@", getVolumeError.localizedDescription);
          }];
     }];
    
    [self updateBrightness];
}

-(void)updateBrightness{
    
    int brightness = ([_volumeSlider value])*254*2;
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        [lightState setBrightness:[NSNumber numberWithInt:brightness]];
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
            
        }];
    }
    
}
#pragma mark - Philips Hue
     
- (void)playLights{
    UIColor *imageColor;
    UIImage *mediaImage = self.imageView.image;
    size_t width = CGImageGetWidth(mediaImage.CGImage);
    size_t height = CGImageGetHeight(mediaImage.CGImage);
    int randomX = arc4random() % width;
    int randomY = arc4random() % height;
    imageColor = [mediaImage getPixelColorAtLocation:CGPointMake(randomX, randomY)];
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        
        PHLightState *lightState = [[PHLightState alloc] init];
        lightState.colormode = COLORMODE_XY;
        CGPoint xy = [PHUtilities calculateXY:imageColor forModel:light.modelNumber];
        [lightState setX:[NSNumber numberWithFloat:xy.x]];
        [lightState setY:[NSNumber numberWithFloat:xy.y]];
        [lightState setBrightness:[NSNumber numberWithInt:[_volumeSlider value]*254*2]];
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

-(void)dealloc{
    [self stopTimer:nil];
}
     

#pragma mark - Device Discovery

-(void)findDevice
{
    [_discoveryManager startDiscovery];
    
    if (_devicePicker == nil)
    {
        _devicePicker = [_discoveryManager devicePicker];
        _devicePicker.delegate = self;
    }
    
    _devicePicker.currentDevice = _device;
    [_devicePicker showPicker:self.connectDevice];
}

#pragma mark - DevicePickerDelegate methods

- (void)devicePicker:(DevicePicker *)picker didSelectDevice:(ConnectableDevice *)device
{
    _device = device;
    _device.delegate = self;
    [_device connect];
    [self addSubscriptions];
}

#pragma mark - ConnectableDeviceDelegate

- (void) connectableDeviceReady:(ConnectableDevice *)device
{
    // TODO: this should be unnecessary
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                      self.connectDevice.titleLabel.text = @"Disconnect";
                   });
}

- (void) connectableDevice:(ConnectableDevice *)device service:(DeviceService *)service pairingRequiredOfType:(int)pairingType withData:(id)pairingData
{
    if (pairingType == DeviceServicePairingTypeAirPlayMirroring)
        [(UIAlertView *) pairingData show];
}

- (void) connectableDeviceDisconnected:(ConnectableDevice *)device withError:(NSError *)error
{
    _device.delegate = nil;
    _device = nil;
    self.connectDevice.titleLabel.text = @"Connect to device";
}

@end

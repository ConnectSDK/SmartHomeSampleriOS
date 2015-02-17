//
//  ViewController.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/10/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ConnectSDK/ConnectSDK.h>

@interface ViewController : UIViewController<ConnectableDeviceDelegate, DiscoveryManagerDelegate ,DevicePickerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *connectDevice;
@property (weak, nonatomic) IBOutlet UIButton *connectHueBridge;
@property (weak, nonatomic) IBOutlet UIButton *slideShowButton;
@property (weak, nonatomic) IBOutlet UIButton *playVideoButton;
@property (weak, nonatomic) IBOutlet UIButton *playAudioButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *closeMediaButton;
@property (nonatomic, assign) ConnectableDevice *device;
@property(nonatomic,weak) IBOutlet UIImageView *imageView;
@property(nonatomic,strong) NSTimer *imageTimer;

- (IBAction)startSlideShow:(id)sender;
- (IBAction)playVideo:(id)sender;
- (IBAction)playAudio:(id)sender;
- (IBAction)playClicked:(id)sender;
- (IBAction)pauseClicked:(id)sender;
- (IBAction)stopClicked:(id)sender;
- (IBAction)volumeChanged:(id)sender;
- (IBAction)closeMedia:(id)sender;

@end


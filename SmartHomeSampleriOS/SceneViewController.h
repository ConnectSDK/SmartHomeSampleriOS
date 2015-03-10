//
//  SceneViewController.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/20/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SceneViewController : UIViewController

- (IBAction)actionSwitchTheSwitch:(id)sender;

@property(nonatomic,weak)IBOutlet UISwitch *useBeaconsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *triggerBeaconsOnNearSwitch;

@property(nonatomic,weak)IBOutlet UIButton *wemoSwitch;
@property(nonatomic,weak)IBOutlet UISwitch *debugSwitch;

@property (weak, nonatomic) IBOutlet UIView *debugView;
@property (weak, nonatomic) IBOutlet UILabel *voiceCommandsLabel;

@property (weak, nonatomic) IBOutlet UILabel *sceneInfoLabel;

- (IBAction)triggerOnNearSwitchChanged:(UISwitch *)sender;

@end

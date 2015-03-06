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
@property(nonatomic,weak)IBOutlet UIButton *startScene1Btn;
@property(nonatomic,weak)IBOutlet UIButton *startScene2Btn;
@property(nonatomic,weak)IBOutlet UIButton *stopScene1Btn;
@property(nonatomic,weak)IBOutlet UIButton *stopScene2Btn;
@property(nonatomic,weak)IBOutlet UIButton *pauseScene1Btn;
@property(nonatomic,weak)IBOutlet UIButton *pauseScene2Btn;
@property(nonatomic,weak)IBOutlet UILabel *useBeaconlabel;
@property(nonatomic,weak)IBOutlet UIButton *wemoSwitch;
@property(nonatomic,weak)IBOutlet UISwitch *debugSwitch;
@end

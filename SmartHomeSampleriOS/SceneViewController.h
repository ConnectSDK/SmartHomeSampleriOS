//
//  SceneViewController.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/20/15.
//  Copyright (c) 2015 LG Electronics.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <UIKit/UIKit.h>

@interface SceneViewController : UIViewController

- (IBAction)actionSwitchTheSwitch:(id)sender;

@property(nonatomic,weak)IBOutlet UISwitch *useBeaconsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *triggerScene1OnNearSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *triggerScene2OnNearSwitch;

@property(nonatomic,weak)IBOutlet UIButton *wemoSwitch;
@property(nonatomic,weak)IBOutlet UISwitch *debugSwitch;

@property (weak, nonatomic) IBOutlet UIView *debugView;
@property (weak, nonatomic) IBOutlet UILabel *voiceCommandsLabel;

@property (weak, nonatomic) IBOutlet UILabel *sceneInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *commandLabel;

- (IBAction)triggerScene1OnNearSwitchChanged:(UISwitch *)sender;
- (IBAction)triggerScene2OnNearSwitchChanged:(UISwitch *)sender;

- (IBAction)aboutAction:(id)sender;

@end

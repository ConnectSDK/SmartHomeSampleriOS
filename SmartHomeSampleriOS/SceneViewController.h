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

@end

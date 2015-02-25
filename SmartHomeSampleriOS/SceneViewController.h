//
//  SceneViewController.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/20/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ConnectSDK/ConnectSDK.h>

@interface SceneViewController : UIViewController<DiscoveryManagerDelegate>

@property(nonatomic,weak)IBOutlet UISwitch *sceneSwitch;

@end

//
//  AppDelegate.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/10/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#define UIAppDelegate  ((AppDelegate *)[[UIApplication sharedApplication] delegate])

#import <UIKit/UIKit.h>
#import "PHBridgeSelectionViewController.h"
#import "PHBridgePushLinkViewController.h"
#import <HueSDK_iOS/HueSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, PHBridgeSelectionViewControllerDelegate, PHBridgePushLinkViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) PHHueSDK *phHueSDK;


#pragma mark - HueSDK

/**
 Starts the local heartbeat
 */
- (void)enableLocalHeartbeat;

/**
 Stops the local heartbeat
 */
- (void)disableLocalHeartbeat;

/**
 Starts a search for a bridge
 */
- (void)searchForBridgeLocal;

@end


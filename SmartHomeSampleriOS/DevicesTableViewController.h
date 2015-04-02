//
//  DevicesTableViewController.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 3/31/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ConfigureSceneViewController.h"
@interface DevicesTableViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)NSMutableDictionary *devices;
@property (nonatomic, weak) id<ConfigureSceneViewControllerDelegate> delegate;
@property NSInteger deviceType;
@property NSMutableDictionary *selectedDevices;
@end

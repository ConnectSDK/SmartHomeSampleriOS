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
@property (nonatomic, strong)NSMutableDictionary *selectedDevices;
@property (nonatomic, strong)NSMutableArray *selectedIndexes;
@property (nonatomic, assign) NSInteger currentSceneIndex;

@end

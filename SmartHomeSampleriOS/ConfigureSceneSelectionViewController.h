//
//  ConfigureSceneSelectionViewController.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 4/1/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfigureSceneSelectionViewController : UIViewController

/// Returns @c YES if at least one of the scene configs has been updated and saved.
@property (nonatomic, readonly) BOOL configHasChanged;
@property (nonatomic, copy) void (^configChangeBlock)(BOOL configHasChanged);

@end

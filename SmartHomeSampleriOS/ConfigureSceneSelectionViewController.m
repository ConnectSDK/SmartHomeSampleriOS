//
//  ConfigureSceneSelectionViewController.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 4/1/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "ConfigureSceneSelectionViewController.h"
#import "ConfigureSceneViewController.h"

@interface ConfigureSceneSelectionViewController ()

@property (nonatomic, assign, readwrite) BOOL configHasChanged;

@end

@implementation ConfigureSceneSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = NSLocalizedString(@"Scenes Configuration", nil);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ConfigureSceneViewController *vc = segue.destinationViewController;
    __weak typeof(self) wself = self;
    vc.configChangeBlock = ^(BOOL configHasChanged) {
        wself.configHasChanged |= configHasChanged;
    };

    UIButton *button = (UIButton *)sender;
    if (button.tag == 1) {
        vc.currentSceneIndex = 0;
    }else{
        vc.currentSceneIndex = 1;
    }
}

- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (!parent) {
        // going back
        if (self.configChangeBlock) {
            self.configChangeBlock(self.configHasChanged);
        }
    }
}

@end

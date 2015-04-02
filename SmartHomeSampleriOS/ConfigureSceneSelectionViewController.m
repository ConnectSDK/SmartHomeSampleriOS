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
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UIButton *button = (UIButton *)sender;
    if (button.tag == 1) {
        ((ConfigureSceneViewController *)[segue destinationViewController]).currentSceneIndex = 0;
    }else{
        ((ConfigureSceneViewController *)[segue destinationViewController]).currentSceneIndex = 1;
    }
}


@end

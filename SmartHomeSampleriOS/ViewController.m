//
//  ViewController.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/10/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)connectToHueBridge:(id)sender{
    [UIAppDelegate enableLocalHeartbeat];
}

@end

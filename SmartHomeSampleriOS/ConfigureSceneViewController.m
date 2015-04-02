//
//  ConfigureSceneViewController.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 3/31/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "ConfigureSceneViewController.h"
#import "DevicesTableViewController.h"
#import "AppDelegate.h"
#import <HueSDK_iOS/HueSDK.h>
#import "WinkAPI.h"
#import "Secret.h"

@interface ConfigureSceneViewController ()

@end

@implementation ConfigureSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showCurrentSceneInfo];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (IBAction)selectDevice:(id)sender{
//    UIStoryboard *stryBoard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    DevicesTableViewController *viewController = [stryBoard instantiateViewControllerWithIdentifier:@"DevicesTableViewController"];
//    viewController.devices = [UIAppDelegate connectedDevices];
//    viewController.navigationItem.title = @"Devices";
//    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:viewController];
//    [self.navigationController presentViewController:navController animated:YES completion:^{
//        [viewController.tableView reloadData];
//    }];
//}

- (void)showCurrentSceneInfo{
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Scene" ofType:@"plist"];
    self.contentDictionary = [NSMutableDictionary new];
   self.contentDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    NSDictionary *sceneDictionary = [[self.contentDictionary objectForKey:@"Scenes"] objectAtIndex:self.currentSceneIndex];
    UILabel *label = (UILabel *)[self.view viewWithTag:ConnectedDeviceType+100];
    label.text = [[sceneDictionary objectForKey:@"device"] valueForKey:@"name"];
    label = (UILabel *)[self.view viewWithTag:HueDeviceType+100];
    NSDictionary *bulbDict = [sceneDictionary objectForKey:@"hueBulb"];
    label.text = [self getBulbString:bulbDict];
    label = (UILabel *)[self.view viewWithTag:WemoDeviceType+100];
    label.text = [[sceneDictionary objectForKey:@"wemoSwitch"] valueForKey:@"name"];
    label = (UILabel *)[self.view viewWithTag:BeaconDeviceType+100];
    label.text = [[sceneDictionary objectForKey:@"iBeacon"] valueForKey:@"uuid"];
    label = (UILabel *)[self.view viewWithTag:WinkDeviceType+100];
    label.text = [[sceneDictionary objectForKey:@"wink"] valueForKey:@"name"];
}

-(NSString*)getBulbString:(NSDictionary *)bulbDict{
    NSMutableString *hueBulbs = [[NSMutableString alloc] init];
    [bulbDict.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if(idx!= 0){
            [hueBulbs appendString:@", "];
        }
        [hueBulbs appendString:obj];
    }];
    return hueBulbs;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIButton *button = (UIButton *)sender;
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    DevicesTableViewController *destinationViewController = (DevicesTableViewController *)[[segue destinationViewController] visibleViewController];
    destinationViewController.deviceType = button.tag;
    destinationViewController.delegate = self;
    
    switch (button.tag) {
        case ConnectedDeviceType: destinationViewController.devices = [UIAppDelegate connectedDevices];
            destinationViewController.tableView.allowsMultipleSelection = NO;
            [destinationViewController.tableView reloadData];
            break;
            
        case HueDeviceType:
            destinationViewController.devices = [self getPhilipsHueLights];
            destinationViewController.tableView.allowsMultipleSelection = YES;
            [destinationViewController.tableView reloadData];
            break;
        case WemoDeviceType:
            destinationViewController.devices = [UIAppDelegate wemoDevices];
            destinationViewController.tableView.allowsMultipleSelection = NO;
            [destinationViewController.tableView reloadData];
            break;
        case WinkDeviceType:
            destinationViewController.devices = [UIAppDelegate winkDevices];
            destinationViewController.tableView.allowsMultipleSelection = NO;
            [destinationViewController.tableView reloadData];
            break;
      
        default: break;
    }
}

-(void)updateDeviceSelected:(NSDictionary *)device withType:(NSInteger)type{
    UILabel *label = (UILabel *)[self.view viewWithTag:type+100];
    
    NSMutableDictionary *sceneDictionary = [[self.contentDictionary objectForKey:@"Scenes"] objectAtIndex:self.currentSceneIndex];
    
    switch (type) {
        case ConnectedDeviceType:
            label.text = [device valueForKey:@"name"];
            [[sceneDictionary objectForKey:@"device"]  setObject:[device valueForKey:@"name"] forKey:@"name"];
            break;
            
        case HueDeviceType:
            label.text = [self getBulbString:device];
            [sceneDictionary setObject:device forKey:@"hueBulb"];
            break;
        case WemoDeviceType:
            label.text = [device valueForKey:@"name"];
            [[sceneDictionary objectForKey:@"wemoSwitch"] setObject:[device valueForKey:@"name"] forKey:@"name"];
            [[sceneDictionary objectForKey:@"wemoSwitch"] setObject:[device valueForKey:@"id"] forKey:@"udn"];
            break;
        case WinkDeviceType:
            label.text = [device valueForKey:@"name"];
            [[sceneDictionary objectForKey:@"wink"] setObject:[device valueForKey:@"name"] forKey:@"name"];
            [[sceneDictionary objectForKey:@"wink"] setObject:[device valueForKey:@"id"] forKey:@"bulbId"];
            break;
        default: break;
    }
     NSLog(@"Content Dic %@",sceneDictionary);
    [[self.contentDictionary objectForKey:@"Scenes"] setObject:sceneDictionary atIndex:self.currentSceneIndex];
}

-(IBAction)saveSceneInfo:(id)sender{
    NSLog(@"Content Dic %@",self.contentDictionary);
     NSString* plistPath = [[NSBundle mainBundle] pathForResource:@"Scene" ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
        [self.contentDictionary writeToFile:plistPath atomically:YES];
    }
}

-(NSMutableDictionary *)getPhilipsHueLights{
    NSMutableDictionary * lights = [NSMutableDictionary dictionary];
    
    [[PHBridgeResourcesReader readBridgeResourcesCache].lights enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [lights setObject:[obj valueForKey:@"name"] forKey:key];
    }];
    return lights;
}



@end

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

@interface ConfigureSceneViewController () <DevicesTableViewControllerDelegate>

@property (nonatomic, assign, readwrite) BOOL configHasChanged;

@end

@implementation ConfigureSceneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showCurrentSceneInfo];
    // Do any additional setup after loading the view.
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Scene %d", nil),
                  (self.currentSceneIndex + 1)];
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
    NSString* plistPath = [UIAppDelegate plistPath];
    self.contentDictionary = [NSMutableDictionary new];
    self.contentDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    self.sceneDictionary = [[self.contentDictionary objectForKey:@"Scenes"] objectAtIndex:self.currentSceneIndex];
    UILabel *label = (UILabel *)[self.view viewWithTag:ConnectedDeviceType+100];
    label.text = [[self.sceneDictionary objectForKey:@"device"] valueForKey:@"name"];
    label = (UILabel *)[self.view viewWithTag:HueDeviceType+100];
    NSDictionary *bulbDict = [self.sceneDictionary objectForKey:@"hueBulb"];
    label.text = [self getBulbString:bulbDict];
    label = (UILabel *)[self.view viewWithTag:WemoDeviceType+100];
    label.text = [[self.sceneDictionary objectForKey:@"wemoSwitch"] valueForKey:@"name"];
    label = (UILabel *)[self.view viewWithTag:BeaconDeviceType+100];
    label.text = [[self.sceneDictionary objectForKey:@"iBeacon"] valueForKey:@"uuid"];
    label = (UILabel *)[self.view viewWithTag:WinkDeviceType+100];
    label.text = [[self.sceneDictionary objectForKey:@"wink"] valueForKey:@"name"];

    self.configHasChanged = NO;
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

- (void)setConfigHasChanged:(BOOL)configHasChanged {
    _configHasChanged = configHasChanged;
    if (self.configChangeBlock) {
        self.configChangeBlock(configHasChanged);
    }
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
    destinationViewController.currentSceneIndex = self.currentSceneIndex;
    
    switch (button.tag) {
        case ConnectedDeviceType: destinationViewController.devices = [UIAppDelegate connectedDevices];
            destinationViewController.selectedIndexes = [self getSelectedIndexes:destinationViewController.devices forType:ConnectedDeviceType];
            destinationViewController.tableView.allowsMultipleSelection = NO;
            [destinationViewController.tableView reloadData];
            break;
            
        case HueDeviceType:
            destinationViewController.devices = [self getPhilipsHueLights];
            destinationViewController.selectedIndexes = [self getSelectedIndexes:destinationViewController.devices forType:HueDeviceType];
            destinationViewController.tableView.allowsMultipleSelection = YES;
            [destinationViewController.tableView reloadData];
            break;
        case WemoDeviceType:
            destinationViewController.devices = [UIAppDelegate wemoDevices];
            destinationViewController.selectedIndexes = [self getSelectedIndexes:destinationViewController.devices forType:WemoDeviceType];
            destinationViewController.tableView.allowsMultipleSelection = NO;
            [destinationViewController.tableView reloadData];
            break;
        case WinkDeviceType:
            destinationViewController.devices = [UIAppDelegate winkDevices];
            destinationViewController.selectedIndexes = [self getSelectedIndexes:destinationViewController.devices forType:WinkDeviceType];
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
            [[sceneDictionary objectForKey:@"device"]  setObject:[device valueForKey:@"type"] forKey:@"type"];
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
    [[self.contentDictionary objectForKey:@"Scenes"] setObject:sceneDictionary atIndex:self.currentSceneIndex];
}

-(IBAction)saveSceneInfo:(id)sender{
    NSLog(@"Config %@",self.contentDictionary);
     NSString* plistPath = [UIAppDelegate plistPath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
        BOOL saveSuccess = [self.contentDictionary writeToFile:plistPath atomically:YES];
        [self showCurrentSceneInfo];
        NSLog(@"Config saved %d", saveSuccess);
        self.configHasChanged = saveSuccess;
    }
}

-(NSMutableDictionary *)getPhilipsHueLights{
    NSMutableDictionary * lights = [NSMutableDictionary dictionary];
    
    [[PHBridgeResourcesReader readBridgeResourcesCache].lights enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [lights setObject:[obj valueForKey:@"name"] forKey:key];
    }];
    return lights;
}

-(NSMutableArray *)getSelectedIndexes:(NSDictionary *)devices forType:(NSInteger)type{
    NSMutableArray *selectedIndexes = [NSMutableArray array];
    NSString *filter = @"";
     __block NSInteger idx = 0;
    if(type == ConnectedDeviceType){
        filter = [[self.sceneDictionary objectForKey:@"device"] valueForKey:@"name"];
        [devices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            ConnectableDevice *cDevice = (ConnectableDevice *) obj;
            if([cDevice.friendlyName isEqualToString:filter]){
                [selectedIndexes addObject:@(idx)];
                *stop = YES;
            }
            idx++;
        }];
    }else if (type == HueDeviceType){
        
        [devices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([[self.sceneDictionary objectForKey:@"hueBulb"] valueForKey:key]){
                [selectedIndexes addObject:@(idx)];
            }
            idx++;
        }];
    }else if (type == WemoDeviceType){
        filter = [[self.sceneDictionary objectForKey:@"wemoSwitch"] valueForKey:@"udn"];
        [devices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([key isEqualToString:filter]){
                [selectedIndexes addObject:@(idx)];
                 *stop = YES;
            }
            idx++;
        }];
    }else if (type == WinkDeviceType){
        filter = [[self.sceneDictionary objectForKey:@"wink"] valueForKey:@"bulbId"];
        [devices enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if([key isEqualToString:filter]){
                [selectedIndexes addObject:@(idx)];
                 *stop = YES;
            }
            idx++;
        }];
    }
    
    return selectedIndexes;
}

@end

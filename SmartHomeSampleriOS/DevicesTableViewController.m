//
//  DevicesTableViewController.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 3/31/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "DevicesTableViewController.h"
#import <ConnectSDK/WebOSTVService.h>

@interface DevicesTableViewController ()

@end

@implementation DevicesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Scene %d.%@", nil),
                  (self.currentSceneIndex + 1),
                  [self deviceTypeToString:self.deviceType]];
}

- (NSString *)deviceTypeToString:(DeviceType)type {
    switch (type) {
        case ConnectedDeviceType:
            return NSLocalizedString(@"Media Device", nil);

        case HueDeviceType:
            return NSLocalizedString(@"Philips Hue", nil);

        case WemoDeviceType:
            return NSLocalizedString(@"WeMo", nil);

        case WinkDeviceType:
            return NSLocalizedString(@"Wink", nil);

        default:
            return @"";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender{
    
    if(self.deviceType == HueDeviceType){
        self.selectedDevices = [NSMutableDictionary dictionary];
        [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.selectedDevices setObject:[[self getDeviceDetailsAtIndex:(NSIndexPath *)obj] valueForKey:@"name"] forKey:[[self getDeviceDetailsAtIndex:(NSIndexPath *)obj] valueForKey:@"id"]];
        }];
        
        [self.delegate updateDeviceSelected:self.selectedDevices withType:self.deviceType];
    }else{
        NSDictionary *deviceDetails = [self getDeviceDetailsAtIndex:self.tableView.indexPathForSelectedRow];
        if (deviceDetails) {
            [self.delegate updateDeviceSelected:deviceDetails
                                       withType:self.deviceType];
        }
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.devices.allValues.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"customcell"];//[tableView dequeueReusableCellWithIdentifier:@"customcell" forIndexPath:indexPath];
    cell.textLabel.text = [[self getDeviceDetailsAtIndex:indexPath] valueForKey:@"name"];
    for ( NSNumber *index in self.selectedIndexes) {
        if([indexPath row] == [index integerValue]){
            NSLog(@"Selected row %d",indexPath.row);
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            break;
        }
    }
    // Configure the cell...
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

- (NSDictionary *)getDeviceDetailsAtIndex :(NSIndexPath *)indexPath{
    if (!indexPath) {
        return nil;
    }

    NSMutableDictionary *device = [NSMutableDictionary dictionary];
    if(self.deviceType == ConnectedDeviceType){
        
        ConnectableDevice *cDevice = [[self.devices allValues] objectAtIndex:indexPath.row];
         const BOOL deviceHasWebOSService = ([cDevice serviceWithName:kConnectSDKWebOSTVServiceId] != nil);
        NSString *type = deviceHasWebOSService ? @"webostv" : @"";
        [device setObject:type forKey:@"type"];
        [device setObject:cDevice.friendlyName forKey:@"name"];
    }else{
        [device setObject:[[self.devices allKeys] objectAtIndex:indexPath.row] forKey:@"id"];
        [device setObject:[[self.devices allValues]objectAtIndex:indexPath.row] forKey:@"name"];
    }
    return device;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

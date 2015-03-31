//
//  WinkAPI.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/26/15.
//  Copyright (c) 2015 LG Electronics.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

@interface WinkAPI : NSObject

typedef void (^WinkResponseBlock)(NSData *data, NSURLResponse *response, NSError *error);


@property(nonatomic,strong)NSMutableDictionary *winkDevices;

-(instancetype)initWithUsername:(NSString *)username password:(NSString *)password clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

-(void)authenticateWithResponse:(WinkResponseBlock)responseBlock;
-(void)retrieveUserDevices:(WinkResponseBlock)responseBlock;
-(void)updateBulb:(int)bulbId power:(int)power brightness:(float)brightness;

@end

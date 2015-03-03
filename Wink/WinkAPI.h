//
//  WinkAPI.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/26/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
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

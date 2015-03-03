//
//  WinkAPI.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/26/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "WinkAPI.h"

@interface WinkAPI()


@property (nonatomic,strong)NSString *username;
@property (nonatomic,strong)NSString *password;
@property (nonatomic,strong)NSString *clientId;
@property (nonatomic,strong)NSString *clientSecret;
@property (nonatomic,strong)NSString *accessToken;
@end

@implementation WinkAPI

NSString *const API_URL = @"https://winkapi.quirky.com/";

-(instancetype)initWithUsername:(NSString *)username password:(NSString *)password clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
    self = [super init];
    
    if (self)
    {
        self.username = username;
        self.password = password;
        self.clientId = clientId;
        self.clientSecret = clientSecret;
    }
    
    return self;
}


-(void)authenticateWithResponse:(WinkResponseBlock)responseBlock{
    NSURL *URL = [NSURL URLWithString:[API_URL stringByAppendingString:@"oauth2/token"]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSString *requestString = [NSString stringWithFormat:@"{\n    \"client_id\": \"%@\",\n    \"client_secret\": \"%@\",\n    \"username\": \"%@\",\n    \"password\": \"%@\",\n    \"grant_type\": \"password\"\n}",self.clientId,self.clientSecret,self.username,self.password];
    [request setHTTPBody:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          responseBlock(data,response,error);
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                          NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                      }
                                      
                                      
                                      NSError* jsonError;
                                      NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:kNilOptions
                                                                                             error:&jsonError];
                                     self.accessToken = [json valueForKey:@"access_token"];
                                      
                                       NSLog(@"Response Json:\n%@\n", json);
                                      responseBlock(data,response,error);
                                  }];
    [task resume];
}

-(void)retrieveUserDevices:(WinkResponseBlock)responseBlock{
    NSURL *URL = [NSURL URLWithString:[API_URL stringByAppendingString:@"users/me/wink_devices"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:[NSString stringWithFormat:@"Bearer %@",self.accessToken] forHTTPHeaderField:@"Authorization"];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          // Handle error...
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                          NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                      }
                                      
                                      NSError* jsonError;
                                      NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                           options:kNilOptions
                                                                                             error:&jsonError];
                                      
                                      self.winkDevices = json;
                                  }];
    [task resume];
    
}

-(void)updateBulb:(int)bulbId power:(int)power brightness:(float)brightness{
    
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@light_bulbs/%d",API_URL,bulbId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setHTTPMethod:@"PUT"];
    
    [request setValue:[NSString stringWithFormat:@"Bearer %@",self.accessToken] forHTTPHeaderField:@"Authorization"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    NSString *requestString = [NSString stringWithFormat:@"\n{\"desired_state\": \n {\"powered\": \"%d\",\n \"brightness\": %f \n} \n}",power,brightness];
    [request setHTTPBody:[requestString dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          // Handle error...
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                          NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                      }
                                      
                                      NSError* jsonError;
                                      NSMutableDictionary* json = [NSJSONSerialization JSONObjectWithData:data
                                                                                                  options:kNilOptions
                                                                                                    error:&jsonError];
                                      
                                      NSLog(@"Json : %@",json);
                                  }];
    [task resume];
    
}
@end

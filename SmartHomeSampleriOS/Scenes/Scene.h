//
//  Scene.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/19/15.
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
#import <ConnectSDK/ConnectSDK.h>
#import <HueSDK_iOS/HueSDK.h>
#import "SceneInfo.h"
#import "NuanceSpeech.h"

@class WeMoControlDevice;

typedef enum {
    Stopped,
    Running,
    Paused
} SceneState;


@interface Scene : NSObject<ConnectableDeviceDelegate>

@property(nonatomic) SceneState currentState;
@property(nonatomic,strong) SceneInfo *sceneInfo;

@property(nonatomic,strong) ConnectableDevice *connectableDevice;
@property(nonatomic,strong) PHBridgeResourcesCache *hueBridge;
@property (nonatomic, strong) WeMoControlDevice *wemoSwitch;

@property(nonatomic,strong) NSDictionary *configuration;
@property(nonatomic,strong) UIImage *currentImage;

-(instancetype)initWithConfiguration:(NSDictionary *)configuration andSceneInfo:(SceneInfo *)sceneInfo;
- (void)changeSceneState:(SceneState)state success:(SuccessBlock)success failure:(FailureBlock)failure;
-(void)configureScene;
-(void)playMessageFromURL:(NSString *)urlString;

-(void)setSceneInfoWithMediaIndex:(NSInteger)index andPosition:(CGFloat)position;
-(void)stopSceneWithTransition;
-(void)startSceneWithTransition;
@end

//
//  SceneInfo.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 2/19/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreGraphics;

@interface SceneInfo : NSObject

@property(nonatomic, strong) NSArray *mediaArray;
@property CGFloat currentPosition;
@property NSInteger currentMediaIndex;

@end

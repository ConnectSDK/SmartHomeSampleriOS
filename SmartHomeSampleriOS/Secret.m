//
//  Secret.m
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 3/6/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "Secret.h"

// DO NOT commit any actual secrets here, use placeholders instead!

// to avoid committing changes, run this command from the working copy root:
// git config filter.mask_secrets.clean ./mask_secrets.sed

NSString *const kNuanceAppId = @"CHANGE_ME";
const unsigned char SpeechKitApplicationKey[] = {0x00, 0xff /*CHANGE_ME*/};

NSString *const kWinkUsername = @"CHANGE_ME";
NSString *const kWinkPassword = @"CHANGE_ME";
NSString *const kWinkClientId = @"CHANGE_ME";
NSString *const kWinkClientSecret = @"CHANGE_ME";

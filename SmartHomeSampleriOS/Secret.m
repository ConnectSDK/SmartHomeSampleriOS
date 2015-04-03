//
//  Secret.m
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 3/6/15.
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

#import "Secret.h"

// DO NOT commit any actual secrets here, use placeholders instead!

// to avoid committing changes, run this command from the working copy root:
// git config filter.mask_secrets.clean ./mask_secrets.sed

// to ignore the file being shown as changed in `git status` you the command:
// git update-index --assume-unchanged SmartHomeSampleriOS/Secret.m

NSString *const kNuanceAppId = @"CHANGE_ME";
NSString *const kNuanceAppHost = @"CHANGE_ME";
long const kNuanceAppPort = 443;
const unsigned char SpeechKitApplicationKey[] = {0x00, 0xff /*CHANGE_ME*/};

NSString *const kWinkUsername = @"CHANGE_ME";
NSString *const kWinkPassword = @"CHANGE_ME";
NSString *const kWinkClientId = @"CHANGE_ME";
NSString *const kWinkClientSecret = @"CHANGE_ME";

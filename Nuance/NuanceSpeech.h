//
//  NuanceSpeech.h
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 3/4/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpeechKit/SpeechKit.h>

@interface NuanceSpeech : NSObject<SpeechKitDelegate, SKRecognizerDelegate,SKVocalizerDelegate>


typedef enum {
    TS_IDLE,
    TS_INITIAL,
    TS_RECORDING,
    TS_PROCESSING,
} TransactionState;

typedef void (^SpeechResponse)(NSString *responseString , NSError *error);

- (void)configure;
-(void)recordVoiceWithResponse:(SpeechResponse)response;
-(void)readAMessage:(NSString *)message;

@end

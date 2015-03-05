//
//  NuanceSpeech.m
//  SmartHomeSampleriOS
//
//  Created by Ibrahim Adnan on 3/4/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import "NuanceSpeech.h"
#import "Secret.h"

@interface NuanceSpeech()

@property(nonatomic,strong) SKRecognizer* voiceSearch;
@property BOOL isSpeaking;
@property(nonatomic,strong) SKVocalizer* vocalizer;
@property(assign) TransactionState state;
@property (nonatomic,strong) SpeechResponse response;
@end

@implementation NuanceSpeech

- (void)configure {
    [SpeechKit setupWithID:kNuanceAppId
                      host:@"sslsandbox.nmdp.nuancemobility.net"
                      port:443
                    useSSL:YES
                  delegate:nil];
    
    SKEarcon* earconStart	= [SKEarcon earconWithName:@"earcon_listening.wav"];
    SKEarcon* earconStop	= [SKEarcon earconWithName:@"earcon_done_listening.wav"];
    SKEarcon* earconCancel	= [SKEarcon earconWithName:@"earcon_cancel.wav"];
    
    [SpeechKit setEarcon:earconStart forType:SKStartRecordingEarconType];
    [SpeechKit setEarcon:earconStop forType:SKStopRecordingEarconType];
    [SpeechKit setEarcon:earconCancel forType:SKCancelRecordingEarconType];
}


-(void)recordVoiceWithResponse:(SpeechResponse)response{
    
    self.response = response;
    if (self.state == TS_RECORDING) {
        [self.voiceSearch stopRecording];
    }
    else if (self.state == TS_IDLE) {
        SKEndOfSpeechDetection detectionType;
        NSString* recoType;
        NSString* langType;
        
        self.state = TS_INITIAL;
        detectionType = SKShortEndOfSpeechDetection; /* Searches tend to be short utterances free of pauses. */
        recoType = SKSearchRecognizerType; /* Optimize recognition performance for search text. */
        langType = @"en_US";
        /* Nuance can also create a custom recognition type optimized for your application if neither search nor dictation are appropriate. */
        
        NSLog(@"Recognizing type:'%@' Language Code: '%@' using end-of-speech detection:%d.", recoType, langType, detectionType);
        
        
        self.voiceSearch = [[SKRecognizer alloc] initWithType:recoType
                                               detection:detectionType
                                                language:langType 
                                                delegate:self];
    }
}

#pragma mark -
#pragma mark SKRecognizerDelegate methods

- (void)recognizerDidBeginRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording started.");
    self.state = TS_RECORDING;
}

- (void)recognizerDidFinishRecording:(SKRecognizer *)recognizer
{
    NSLog(@"Recording finished.");
    self.state = TS_PROCESSING;
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithResults:(SKRecognition *)results
{
    NSLog(@"Got results.");
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    long numOfResults = [results.results count];
    
    self.state = TS_IDLE;
    NSString *outputString;
    if (numOfResults > 0)
        outputString = [results firstResult];
//    if (self.isSpeaking) {
//        [self.vocalizer cancel];
//        self.isSpeaking = NO;
//    }
//    else {
//        self.isSpeaking = YES;
//        self.vocalizer = [[SKVocalizer alloc] initWithLanguage:@"en_US" delegate:self];
//        [self.vocalizer speakString:outputString];
//    }
    self.voiceSearch = nil;
    
    self.response(outputString,nil);
}

- (void)recognizer:(SKRecognizer *)recognizer didFinishWithError:(NSError *)error suggestion:(NSString *)suggestion
{
    NSLog(@"Got error. %@",error.description);
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
    
    self.state = TS_IDLE;
    self.voiceSearch = nil;
    self.response(nil,error);
}

#pragma mark -
#pragma mark SKVocalizerDelegate methods

- (void)vocalizer:(SKVocalizer *)vocalizer willBeginSpeakingString:(NSString *)text {
    self.isSpeaking = YES;
    
}

- (void)vocalizer:(SKVocalizer *)vocalizer willSpeakTextAtCharacter:(NSUInteger)index ofString:(NSString *)text {
    NSLog(@"Session id [%@].", [SpeechKit sessionID]); // for debugging purpose: printing out the speechkit session id
}

- (void)vocalizer:(SKVocalizer *)vocalizer didFinishSpeakingString:(NSString *)text withError:(NSError *)error {
    NSLog(@"Session id [%@]. \n  Error :%@", [SpeechKit sessionID],error.description); // for debugging purpose: printing out the speechkit session id
    self.isSpeaking = NO;
    
}

@end

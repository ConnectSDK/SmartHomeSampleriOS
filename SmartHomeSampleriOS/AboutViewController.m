//
//  AboutViewController.m
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 4/1/15.
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

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = NSLocalizedString(@"About", nil);

    self.view.backgroundColor = [UIColor whiteColor];

    UITextView *textView = [[UITextView alloc] initWithFrame:self.view.bounds];
    textView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                 UIViewAutoresizingFlexibleHeight);
    textView.editable = NO;

    NSError *error;
    NSString *acknowledgmentsFilepath = [[NSBundle mainBundle] pathForResource:@"ACKNOWLEDGMENTS"
                                                                        ofType:@"html"];
    NSData *acknowledgments = [NSData dataWithContentsOfFile:acknowledgmentsFilepath
                                                     options:0
                                                       error:&error];
    if (!error) {
        error = nil;
        NSAttributedString *htmlString = [[NSAttributedString alloc] initWithData:acknowledgments
                                                                          options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                                    NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                               documentAttributes:nil
                                                                            error:&error];
        if (!error) {
            textView.attributedText = htmlString;
        } else {
            textView.text = [NSString stringWithFormat:@"Couldn't format the about info (%@)",
                             error.localizedDescription];
        }
    } else {
        textView.text = [NSString stringWithFormat:@"Sorry, the about info is unavailable (%@)",
                         error.localizedDescription];
    }

    [self.view addSubview:textView];
}

@end

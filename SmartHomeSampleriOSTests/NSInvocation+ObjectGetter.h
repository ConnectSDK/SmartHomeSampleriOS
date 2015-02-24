//
//  NSInvocation+ObjectGetter.h
//  SmartHomeSampleriOS
//
//  Created by Eugene Nikolskyi on 2/23/15.
//  Copyright (c) 2015 Ibrahim Adnan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSInvocation (ObjectGetter)

/// Returns an object argument in the invocation at the given index.
/// @warning The index is zero-based, as in a method definition!
- (id)objectArgumentAtIndex:(NSInteger)idx;

@end

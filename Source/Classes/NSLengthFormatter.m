//
//  NSLengthFormatter.m
//  Transmission Tunneler
//
//  Created by Josh Bernfeld on 11/14/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import "NSLengthFormatter.h"

@implementation NSLengthFormatter
- (BOOL) isPartialStringValid:(NSString *)partialString newEditingString:(NSString *__autoreleasing *)newString errorDescription:(NSString *__autoreleasing *)error {
    if (partialString.length <= 5)
        return YES;
    else
        return NO;
}


- (NSString *)stringForObjectValue:(id)obj {
    if (![obj isKindOfClass:[NSString class]]) {
        return nil;
    }
    
    return obj;
}

- (BOOL)getObjectValue:(out __autoreleasing id *)obj forString:(NSString *)string errorDescription:(out NSString *__autoreleasing *)error {
    if (string != NULL) {
        *obj = [NSString stringWithString:string];
        return YES;
    } else {
        return NO;
    }
}
@end

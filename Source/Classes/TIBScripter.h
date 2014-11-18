//
//  TIBScripter.h
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIBScripter : NSObject

+ (NSString *)runScript:(NSString*)scriptName args:(NSArray *)args;
+ (NSString *)runScript:(NSString*)scriptName args:(NSArray *)args task:(NSTask *)task;

@end

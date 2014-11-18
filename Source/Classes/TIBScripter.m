//
//  TIBScripter.m
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import "TIBScripter.h"

@implementation TIBScripter

+ (NSString *)runScript:(NSString*)scriptName args:(NSArray *)args
{
    return [self runScript:scriptName args:args task:[[NSTask alloc] init]];
}

+ (NSString *)runScript:(NSString*)scriptName args:(NSArray *)args task:(NSTask *)task
{
    NSMutableArray *argsMut = [NSMutableArray arrayWithArray:args];
    
    [task setLaunchPath: @"/bin/sh"];
    
    NSString* newpath = [[NSBundle mainBundle] pathForResource:scriptName ofType:@"sh"];
    [argsMut insertObject:newpath atIndex:0];
    [task setArguments: argsMut];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *string;
    string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSLog (@"Script Completed: %@.sh\n%@", scriptName, string);
    return string;
}

@end

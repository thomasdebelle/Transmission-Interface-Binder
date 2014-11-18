//
//  TIBTransmissionAutoKiller.m
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import "TIBTransmissionAutoKiller.h"
#import "TIBScripter.h"
@interface  TIBTransmissionAutoKiller()

@property (nonatomic, readwrite) BOOL isRunning;

@property (nonatomic, strong) NSTask *isClosedTask;
@property (nonatomic, strong) NSTask *autoKillerTask;

@property (nonatomic, strong) dispatch_queue_t backgroundAutoKillerQue;

@end

@implementation TIBTransmissionAutoKiller

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundAutoKillerQue = dispatch_queue_create("com.onepixeldev.Transmission-Interface-Binder.TranissmionAutoKillerQue", NULL);
    }
    return self;
}

- (void)start {
    dispatch_async(self.backgroundAutoKillerQue, ^(void) {
        if (self.isRunning)
            [self stop];
        
        NSLog(@"Starting Transmission AutoKiller");
        
        self.isRunning = YES;
        
        //This can change at any time because we are on a seperate que.
        if (!self.isRunning)
            return;
        
        //Wait for transmission to close if open.
        self.isClosedTask = [[NSTask alloc] init];
        [TIBScripter runScript:@"transmission_is_closed" args:nil task:self.isClosedTask];
        
        //This can change at any time because we are on a seperate que.
        if (!self.isRunning)
            return;
        
        //Wait for transmission to open, then close.
        self.autoKillerTask = [[NSTask alloc] init];
        [TIBScripter runScript:@"transmission_autokiller" args:nil task:self.autoKillerTask];
        
        if(!self.isRunning)
            return;
        
        self.autoKillerTask = nil;
        self.isClosedTask = nil;
        
        //Open Transmission, only if user approves.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.killedSuccessfully)
                self.killedSuccessfully();
        });

        
        //Start Over only if autokiller was never stopped.
        if(self.isRunning)
            [self start];
    });
}

- (void)stop {
    if (!self.isRunning)
        return;
    
    self.isRunning = NO;
    
    NSLog(@"Stopping Transmission AutoKiller");
    
    if (self.isClosedTask) {
        [self.isClosedTask interrupt];
        self.isClosedTask = nil;
    }
    if (self.autoKillerTask) {
        [self.autoKillerTask interrupt];
        self.autoKillerTask = nil;
    }
}

@end

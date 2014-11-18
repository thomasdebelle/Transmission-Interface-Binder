//
//  TIBTransmissionAutoKiller.h
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIBTransmissionAutoKiller : NSObject

@property (nonatomic, readonly) BOOL isRunning;
@property (nonatomic, copy) void(^ killedSuccessfully)(void);

- (void)start;
- (void)stop;

@end

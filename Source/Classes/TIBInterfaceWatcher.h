//
//  TIBInterfaceWatcher.h
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface TIBInterfaceWatcher : NSObject

@property (nonatomic, readwrite) BOOL isRunning;
@property (nonatomic, readonly) NSString *interface;

//This is called when a change is detected.
@property (nonatomic, readwrite) SEL selector;
@property (nonatomic, readwrite) id target;

- (void)startWithInterface:(NSString *)interface;
- (void)stop;

@end

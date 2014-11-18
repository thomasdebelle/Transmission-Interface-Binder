//
//  TIBAlertWindowController.h
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TIBAlertWindowController : NSWindowController

@property (nonatomic, copy) void(^ leftButtonCompletion)(void);
@property (nonatomic, copy) void(^ rightButtonCompletion)(void);

- (void)show;
@end

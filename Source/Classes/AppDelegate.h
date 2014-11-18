//
//  AppDelegate.h
//  Transmission Tunneler
//
//  Created by Josh Bernfeld on 11/14/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MainWindowController;

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, strong) MainWindowController *mainController;

@end


//
//  AppDelegate.m
//  Transmission Tunneler
//
//  Created by Josh Bernfeld on 11/14/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@interface AppDelegate ()

@property (nonatomic, readwrite) BOOL windowHasAppearedBefore;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.mainController = [[MainWindowController alloc] init];
    
    BOOL openSilent = NO;
    NSArray *arguments = [[NSProcessInfo processInfo] arguments];
    for (NSString *arg in arguments) {
        if ([arg isEqualToString:@"-s"]) {
            openSilent = YES;
        }
    }
    if (!openSilent) {
        [self showMainWindow];
    }
    else {
        //If we opened the App Silently, auto activate.
        [self.mainController activationButtonPressed:nil];
    }
    NSLog(@"Startup Args: %@",arguments);
}

- (void)showMainWindow {
    NSRect screenSize = [[[NSScreen screens] objectAtIndex:0] visibleFrame];
    [self.mainController.window setFrameOrigin:NSMakePoint(screenSize.size.width/2 - self.mainController.window.frame.size.width/2, screenSize.size.height/2)];
    
    self.windowHasAppearedBefore = YES;
    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!self.windowHasAppearedBefore) {
        [self showMainWindow];
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        [self.mainController.window makeKeyAndOrderFront:self];
    }
    else {
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        [self.mainController.window makeKeyAndOrderFront:self];
    }
    return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end

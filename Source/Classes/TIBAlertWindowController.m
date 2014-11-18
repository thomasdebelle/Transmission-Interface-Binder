//
//  TIBAlertWindowController.m
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import "TIBAlertWindowController.h"
#import "AppDelegate.h"
@interface TIBAlertWindowController ()
@property (nonatomic, strong) IBOutlet NSButton *leftButton;
@property (nonatomic, strong) IBOutlet NSButton *rightButton;

- (IBAction)leftButtonClicked:(id)sender;
- (IBAction)rightButtonClicked:(id)sender;

@end

@implementation TIBAlertWindowController

- (id)init {
    if (self = [super initWithWindowNibName:@"TIBAlertWindowController"]) {
        
    }
    return self;
}

- (void)windowDidLoad {
    [self.window setStyleMask:NSTitledWindowMask];
    
    [super windowDidLoad];
}

- (void)show {
    [self.window setLevel:NSModalPanelWindowLevel];
    NSRect screenSize = [[[NSScreen screens] objectAtIndex:0] visibleFrame];
    [self.window setFrameOrigin:NSMakePoint(screenSize.size.width/2 - self.window.frame.size.width/2, screenSize.size.height/2 + self.window.frame.size.height)];
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    [self.window makeKeyAndOrderFront:self];
}

- (IBAction)leftButtonClicked:(id)sender {
    [self.window close];
    if (self.leftButtonCompletion) {
        self.leftButtonCompletion();
    }
}

- (IBAction)rightButtonClicked:(id)sender {
    [self.window close];
    if (self.rightButtonCompletion) {
       self.rightButtonCompletion();
    }
}

@end

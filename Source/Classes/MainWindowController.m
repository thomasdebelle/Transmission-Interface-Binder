//
//  MainWindowController.m
//  Transmission Tunneler
//
//  Created by Josh Bernfeld on 11/14/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import "MainWindowController.h"
#import "TIBAlertWindowController.h"
#import "TIBOnLogin.h"
#import "TIBInterfaceWatcher.h"
#import "TIBTransmissionAutoKiller.h"
#import "TIBScripter.h"

#define kTIBDefaultsBindToInterfaceKey @"BindToInterface"

@interface MainWindowController() <NSTextFieldDelegate>

- (void)runUpdate;

- (IBAction)openIPCheckTorrent:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)startAtLoginButtonPressed:(id)sender;

- (void)showTransmissionOpenWarning;

@property (nonatomic, strong) IBOutlet NSTextField *interfaceField;
@property (nonatomic, strong) IBOutlet NSTextField *ipAddressLabel;

@property (nonatomic, strong) IBOutlet NSButton *activationButton;
@property (nonatomic, strong) NSString *activationButtonTitle;

@property (nonatomic, strong) IBOutlet NSTextField *statusLabel;
@property (nonatomic, strong) NSString *statusLabelTitle;

@property (nonatomic, strong) NSString *interface;
@property (nonatomic, strong) NSString *interfaceIP;

@property (nonatomic, readwrite) BOOL updateInterface;
@property (nonatomic, readwrite) BOOL updateIP;

@property (nonatomic, strong) IBOutlet NSButton *checkBoxButton;

@property (nonatomic, strong) dispatch_queue_t backgroundQueue;

@property (nonatomic, readwrite) BOOL isUpdateRunning;

@property (nonatomic, strong) TIBAlertWindowController *alertWindowController;

@property (nonatomic, strong) TIBInterfaceWatcher *interfaceWatcher;

@property (nonatomic, strong) TIBTransmissionAutoKiller *autoKiller;

@end

@implementation MainWindowController

- (id)init {
    if (self = [super initWithWindowNibName:@"MainWindow"]) {
        //Retrieve the saved interface.
        self.interface = [[NSUserDefaults standardUserDefaults] objectForKey:kTIBDefaultsBindToInterfaceKey];
        if (!self.interface)
            self.interface = @"tun0";
        
        self.statusLabelTitle = @"Press Start to begin interface binding.";
        self.activationButtonTitle = @"Start";
        
        self.backgroundQueue = dispatch_queue_create("com.onepixeldev.Transmission-Interface-Binder.BackgroundQue", NULL);
        
        self.interfaceWatcher = [[TIBInterfaceWatcher alloc] init];
        self.interfaceWatcher.selector = @selector(runUpdate);
        self.interfaceWatcher.target = self;
        
        self.autoKiller = [[TIBTransmissionAutoKiller alloc] init];
        
        __unsafe_unretained typeof(self) weakSelf = self;
        self.autoKiller.killedSuccessfully = ^{
            if([weakSelf.interfaceIP isEqualToString:@""])
                [weakSelf showTransmissionOpenWarning];
        };
        
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    //Prevent the interfaceField from heighlighting.
    [self.window makeFirstResponder:nil];
    [self.window setLevel:NSFloatingWindowLevel];
    
    NSLengthFormatter *formatter = [[NSLengthFormatter alloc] init];
    [self.interfaceField setFormatter:formatter];
    [self.interfaceField setDelegate:self];
    
    [self displayStatusMessage:self.statusLabelTitle];
    
    [self setActivationButtonMessage:self.activationButtonTitle];
    
    //Set the initial IP text.
    NSString *displayText;
    if (!self.interfaceIP || [self.interfaceIP isEqualToString:@""]) {
        displayText = @"Interface IP: N/A";
    }
    else {
        displayText = [NSString stringWithFormat:@"Interface IP: %@",self.interfaceIP];
    }
    
    NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell:displayText];
    [cell setFont:[NSFont systemFontOfSize:13]];
    [self.ipAddressLabel setCell:cell];
    [self.ipAddressLabel setNeedsDisplay];
    
    //Set the intial interface text
    NSCell *cell2 = [[NSTextFieldCell alloc] initTextCell:self.interface];
    [cell2 setFont:[NSFont systemFontOfSize:13]];
    [cell2 setEditable:YES];
    [cell2 setBordered:YES];
    [cell2 setBezeled:YES];
    [cell2 setBackgroundStyle:NSBackgroundStyleLowered];
    [self.interfaceField setCell:cell2];
    [self.interfaceField setNeedsDisplay];
    
    if ([TIBOnLogin startOnLoginSet]) {
        if ([TIBOnLogin doesStartOnLogin])
            [self.checkBoxButton setState:NSOnState];
        else
            [self.checkBoxButton setState:NSOffState];
    }
    else {//Set start on login for the first time to on, because it hasnt been set in the past.
        [TIBOnLogin setStartOnLogin:YES];
        [self.checkBoxButton setState:NSOnState];
    }
}


- (void)runUpdate {
    if (self.isUpdateRunning == YES)
        return;
    
    self.isUpdateRunning = YES;
    
    dispatch_async(self.backgroundQueue, ^(void) {
        //Run bash script to retrive new IP for set interface.
        NSString *newIp = [TIBScripter runScript:@"bash_get_ip" args:[NSArray arrayWithObjects:self.interface, nil]];
        
        //Is this new IP different from the current one we have on file?
        if (![newIp isEqualToString:self.interfaceIP]) {
            self.updateIP = YES;
            self.interfaceIP = newIp;
        }
        
        //Update UI components
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *displayText = nil;
            if ([self.interfaceIP isEqualToString:@""]) {
                displayText = @"Interface IP: N/A";
                
                //IP is not set, autokill Transmission when it opens.
                //Upon autokill completion, the block of autoKiller - killedSuccesfully, custom defined at intializiation will be called.
                //The warning should be displayed and from there the autokiller restarted.
                [self.autoKiller start];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self displayStatusMessage:@"Interface not found, leaving Bind IP as is."];
                });
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                    [self displayStatusMessage:[NSString stringWithFormat:@"Wating for changes on interface %@",self.interface]];
                });
            }
            else {
                displayText = [NSString stringWithFormat:@"Interface IP: %@",self.interfaceIP];
                
                //Stop the checker to see if transmission opens.
                //The user is now connected to a VPN, so there is no need to warn them if they are about to open Transmission.
                [self.autoKiller stop];
            }
            
            NSLog(@"Interface: %@ Interface IP: %@",self.interface,self.interfaceIP);
            
            NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell:displayText];
            [cell setFont:[NSFont systemFontOfSize:13]];
            [self.ipAddressLabel setCell:cell];
            [self.ipAddressLabel setNeedsDisplay];
            
            [self displayStatusMessage:[NSString stringWithFormat:@"Wating for changes on interface %@",self.interface]];
        });
        
        
        //Ony write new IP address and restart transmission if the IP exists, and it is different from the previous one.
        if ([self.interfaceIP isEqualToString:@""] || !self.updateIP) {
            self.isUpdateRunning = NO;
            self.updateInterface = NO;
            return;
        }
        
        //We are about to do this, so lets put these back to defaults
        //Bailout can be expected anytime during the execuation from here on out.
        self.updateInterface = NO;
        self.updateIP = NO;
        
        if (!self.isUpdateRunning)
            return;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self displayStatusMessage:@"Writing new Bind IP to Transmission config file"];
        });
        
        [TIBScripter runScript:@"bash_write_ip" args:[NSArray arrayWithObjects:self.interfaceIP, nil]];
        
        [TIBScripter runScript:@"bash_restart_transmission" args:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (!self.isUpdateRunning)
                return;
            [self displayStatusMessage:[NSString stringWithFormat:@"Wating for changes on interface %@",self.interface]];
            
            self.isUpdateRunning = NO;
        });
        
    });
    
}

//Text changed in the interface field
- (void)controlTextDidChange:(NSNotification *)obj {
    if (![self.interfaceField.stringValue isEqualToString:self.interface]) {
        self.updateInterface = YES;
        self.interface = self.interfaceField.stringValue;
        [[NSUserDefaults standardUserDefaults] setObject:self.interface forKey:kTIBDefaultsBindToInterfaceKey];
    }
    else {
        self.updateInterface = NO;
    }
    
    if (self.interfaceWatcher.isRunning) {
        if (self.updateInterface) {
            [self setActivationButtonMessage:@"Apply"];
        }
        else {
            [self setActivationButtonMessage:@"Stop"];
        }
        
    }
    else {
        [self setActivationButtonMessage:@"Start"];
    }
}

- (IBAction)activationButtonPressed:(id)sender {
    if (self.interfaceWatcher.isRunning) {
        //If the set interface differs from a previously set interface, the user has requested an updated of interface.
        if(self.updateInterface){//Start
            [self setActivationButtonMessage:@"Stop"];
            
            [self runUpdate];
        }
        else {//Stop
            [self setActivationButtonMessage:@"Start"];
            
            [self.interfaceWatcher stop];
            [self.autoKiller stop];
            [self displayStatusMessage:@"Press Start to begin interface binding."];
        }
        
    }
    else {//Start
        [self setActivationButtonMessage:@"Stop"];
        
        [self.interfaceWatcher startWithInterface:self.interface];
        [self runUpdate];
    }
    
}

- (void)setActivationButtonMessage:(NSString *)title {
    self.activationButtonTitle = title;
    self.activationButton.title = title;
}

- (IBAction)openIPCheckTorrent:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"checkip" ofType:@"torrent"];
    [[NSWorkspace sharedWorkspace] openFile:path];
}

- (IBAction)quit:(id)sender {
    [NSApp performSelector:@selector(terminate:) withObject:nil afterDelay:0.0];
}

- (IBAction)startAtLoginButtonPressed:(id)sender {
    if ([sender state] == NSOnState) {
        [TIBOnLogin setStartOnLogin:YES completion:^(BOOL success) {
            if (!success)
                [self.checkBoxButton setState:NSOffState];
        }];
    }
    else {
        [TIBOnLogin setStartOnLogin:NO];
    }
}

- (void)showTransmissionOpenWarning {
    NSLog(@"Show Transmission Open Warning");
    if (self.alertWindowController) {
        [self.alertWindowController.window makeKeyAndOrderFront:self];
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        return;
    }
    
    self.alertWindowController = [[TIBAlertWindowController alloc] init];
    
     __unsafe_unretained typeof(self) weakSelf = self;
    [self.alertWindowController setLeftButtonCompletion:^{
        //Maintain the state of the autokiller once we have opened Transmission
        BOOL autoKillerWasRunning = weakSelf.autoKiller.isRunning;
        [weakSelf.autoKiller stop];
        
        NSLog(@"Bypass permitted, opening Tansmission");
        [[NSWorkspace sharedWorkspace] launchApplication:@"Transmission"];
        
        //Only start the autokiller again if it was running before.
        if (autoKillerWasRunning)
            [weakSelf.autoKiller start];
        
        weakSelf.alertWindowController = nil;
    }];
    
    [self.alertWindowController setRightButtonCompletion:^{
        weakSelf.alertWindowController = nil;
    }];
    
    [self.alertWindowController show];
    
}

- (void)displayStatusMessage:(NSString *)message {
    self.statusLabelTitle = message;
    NSTextFieldCell *cell = [[NSTextFieldCell alloc] initTextCell:message];
    [cell setFont:[NSFont systemFontOfSize:13]];
    [cell setAlignment:NSCenterTextAlignment];
    [self.statusLabel setCell:cell];
    [self.statusLabel setNeedsDisplay];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [self.window makeFirstResponder:nil];
}

- (BOOL)textView:(NSTextView *)aTextView shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString*)replacementString
{
    if ([aTextView.string length] > 5)
        return NO;
    else
        return YES;
}

@end

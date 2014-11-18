//
//  TIBInterfaceWatcher.m
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import "TIBInterfaceWatcher.h"
@interface TIBInterfaceWatcher ()

@property (nonatomic, readwrite) NSString *interface;
@property (nonatomic, readwrite) SCDynamicStoreRef storeRef;
@property (nonatomic, readwrite) CFRunLoopSourceRef rlSrc;


@end

@implementation TIBInterfaceWatcher

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

void callback(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info)
{
    TIBInterfaceWatcher *watcher = (__bridge TIBInterfaceWatcher *)info;
    NSLog(@"Detected Interface Change on Interface %@", watcher.interface);
    if (!watcher.selector)
        return;
    
    IMP imp = [watcher.target methodForSelector:watcher.selector];
    void (*func)(id, SEL) = (void *)imp;
    func(watcher.target,watcher.selector);
}

- (void)startWithInterface:(NSString *)interface {
    if (self.isRunning)
        return;
    self.interface = interface;
    
    NSLog(@"Starting Watcher on Interface %@",self.interface);
    
    SCDynamicStoreContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    self.storeRef = SCDynamicStoreCreate(kCFAllocatorDefault,  CFBundleGetIdentifier(CFBundleGetMainBundle()), (SCDynamicStoreCallBack)callback, &context);
    
    NSString *keysSetup = [NSString stringWithFormat:@"State:/Network/Interface/%@/IPv4",self.interface];
    
    const CFStringRef keys[3] = {
        (__bridge CFStringRef)(keysSetup)
    };
    
    CFArrayRef watchedKeys = CFArrayCreate(kCFAllocatorDefault, (const void **)keys, 1, &kCFTypeArrayCallBacks);
    
    if (!SCDynamicStoreSetNotificationKeys(self.storeRef, NULL, watchedKeys))
    {
        CFRelease(watchedKeys);
        fprintf(stderr, "SCDynamicStoreSetNotificationKeys() failed: %s", SCErrorString(SCError()));
        CFRelease(self.storeRef);
        self.storeRef = NULL;
        
    }
    CFRelease(watchedKeys);
    
    self.rlSrc = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, self.storeRef, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), self.rlSrc, kCFRunLoopDefaultMode);
    
    self.isRunning = YES;
}

- (void)stop {
    if (!self.isRunning)
        return;
    
    NSLog(@"Stopping Watcher on Interface %@",self.interface);
    
    CFRunLoopRemoveSource(CFRunLoopGetCurrent(), self.rlSrc, kCFRunLoopDefaultMode);
    CFRelease(self.rlSrc);
    self.rlSrc = NULL;
    CFRelease(self.storeRef);
    self.storeRef = NULL;
    
    self.isRunning = NO;
}


@end

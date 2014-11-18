//
//  TIBOnLogin.m
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import "TIBOnLogin.h"
#define kTIBStartsOnLoginKey @"StartsOnLogin"

@implementation TIBOnLogin

+ (void)setStartOnLogin:(BOOL)startOnLogin {
    [TIBOnLogin setStartOnLogin:startOnLogin completion:nil];
}

+ (void)setStartOnLogin:(BOOL)startOnLogin completion:(void (^)(BOOL success))completion {
    dispatch_queue_t backgroundQueue = dispatch_queue_create("com.onepixeldev.Transmission-Interface-Binder.StatupOnLoginSetter", NULL);
    
    dispatch_async(backgroundQueue, ^{
        NSError *error = nil;
        NSString *launchPlistTo = @"~/Library/LaunchAgents/com.onepixeldev.Transmission-Interface-Binder.plist";
        launchPlistTo = [launchPlistTo stringByExpandingTildeInPath];
        NSString *launchPlistFrom = [[NSBundle mainBundle] pathForResource:@"com.onepixeldev.Transmission-Interface-Binder" ofType:@"plist"];
        
        if (startOnLogin) {
            if ([[NSFileManager defaultManager] copyItemAtPath:launchPlistFrom  toPath:launchPlistTo error:&error]) {
                NSLog(@"Copy Launch Plist Success");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kTIBStartsOnLoginKey];
                if(completion)
                    completion(YES);
            } else {
                NSLog(@"Copy Launch Plist Failed: %@",error);
                if(completion)
                    completion(NO);
            }
        }
        else {
            if ([[NSFileManager defaultManager] removeItemAtPath:launchPlistTo error:&error]) {
                NSLog(@"Remove Launch Plist Success");
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kTIBStartsOnLoginKey];
                if(completion)
                    completion(YES);
            } else {
                NSLog(@"Remove Launch Plist Failed: %@",error);
                if(completion)
                    completion(NO);
            }
        }
    });
    
}

+ (BOOL)startOnLoginSet {
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSNumber *startsOnLogin = [[NSUserDefaults standardUserDefaults] objectForKey:kTIBStartsOnLoginKey];
    if (startsOnLogin) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (BOOL)doesStartOnLogin {
    NSNumber *startsOnLogin = [[NSUserDefaults standardUserDefaults] objectForKey:kTIBStartsOnLoginKey];
    if (!startsOnLogin || startsOnLogin.boolValue == NO) {
        return NO;
    } else {
        return YES;
    }
}


@end

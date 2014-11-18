//
//  TIBOnLogin.h
//  Transmission Interface Binder
//
//  Created by Josh Bernfeld on 11/17/14.
//  Copyright (c) 2014 Josh Bernfeld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIBOnLogin : NSObject

+ (void)setStartOnLogin:(BOOL)startOnLogin;
+ (void)setStartOnLogin:(BOOL)startOnLogin completion:(void (^)(BOOL success))completion;

+ (BOOL)doesStartOnLogin;
+ (BOOL)startOnLoginSet;

@end

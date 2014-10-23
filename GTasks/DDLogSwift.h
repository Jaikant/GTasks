//
//  DDLogSwift.h
//  GTasks
//
//  Created by Jai on 29/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

#ifndef GTasks_DDLogSwift_h
#define GTasks_DDLogSwift_h

#import <Foundation/Foundation.h>

@interface DDLogSwift : NSObject

+ (void) logError:(NSString *)message;
+ (void) logWarn:(NSString *)message;
+ (void) logInfo:(NSString *)message;
+ (void) logDebug:(NSString *)message;
+ (void) logVerbose:(NSString *)message;

@end

#endif

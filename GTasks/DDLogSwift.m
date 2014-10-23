//
//  DDLogSwift.m
//  GTasks
//
//  Created by Jai on 29/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DDLogSwift.h"

#import <CocoaLumberjack/DDLog.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>


/*
#ifdef DEBUG
 */
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

/*
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif
*/

@implementation DDLogSwift

+ (void) logError:(NSString *)message {
    DDLogError(message);
}

+ (void) logWarn:(NSString *)message {
    DDLogWarn(message);
}

+ (void) logInfo:(NSString *)message {
    DDLogInfo(message);
}

+ (void) logDebug:(NSString *)message {
    DDLogDebug(message);
}

+ (void) logVerbose:(NSString *)message {
    DDLogVerbose(message);
}
@end
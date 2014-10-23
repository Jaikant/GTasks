//
//  SwiftLumberjack.h
//  GTasks
//
//  Created by Jai on 30/09/14.
//  Copyright (c) 2014 Jaikant Kumaran. All rights reserved.
//

#ifndef GTasks_SwiftLumberjack_h
#define GTasks_SwiftLumberjack_h

@interface DDLogWrapper : NSObject
+ (void) logVerbose:(NSString *)message;
+ (void) logError:(NSString *)message;
+ (void) logInfo:(NSString *)message;
@end


#endif

//
//  CRLCrashManualNotify.m
//  CrashProbe
//
//  Created by Conrad Irwin on 11/14/14.
//  Copyright (c) 2014 Bit Stadium GmbH. All rights reserved.
//

#import "CRLCrashManualNotify.h"

@implementation CRLCrashManualNotify

- (NSString *)category { return @"Exceptions"; }
- (NSString *)title { return @"Manual notify"; }
- (NSString *)desc { return @"Send a notification to your crashing service. Not a crash per-se, but an essential feature of any error reporting solution."; }

- (void)crash
{
    NSLog(@"%s %s: manual notification support is not implemented.", __FILE__, __FUNCTION__);
}

@end

//
//  CCNWindow.m
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNWindow.h"


@implementation CCNWindow

- (void)disableUpdatesUntilFlush
{
    if ( !_needsEnableUpdate )
    {
        NSDisableScreenUpdates();
        _needsEnableUpdate = YES;
    }
}

- (void) flushWindow
{
    [super flushWindow];
    
    if (_needsEnableUpdate)
    {
        NSEnableScreenUpdates();
        _needsEnableUpdate = NO;
    }
}

@end

/*
 * Coconade
 *
 * Copyright (c) 2012 Alexey Lang
 *
 */

#import "CCNWindow.h"


@implementation CCNWindow

- (void)disableUpdatesUntilFlush
{
    if ( !_needsEnableUpdate )
    {
        NSDisableScreenUpdates();
    }
    _needsEnableUpdate = YES;
}

- (void) flushWindow
{
    [super flushWindow];
    
    if (_needsEnableUpdate)
    {
        _needsEnableUpdate = NO;
        NSEnableScreenUpdates();
    }
}

@end

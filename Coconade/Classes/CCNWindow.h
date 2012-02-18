/*
 * Coconade
 *
 * Copyright (c) 2012 Alexey Lang
 *
 */

#import <AppKit/AppKit.h>


@interface CCNWindow : NSWindow
{
    BOOL _needsEnableUpdate;    
}

- (void)disableUpdatesUntilFlush;

@end

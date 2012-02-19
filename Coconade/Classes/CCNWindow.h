/*
 * Coconade
 *
 * Copyright (c) 2012 Alexey Lang
 *
 */

#import <AppKit/AppKit.h>


/** @class CCNWindow main window for Coconade */
@interface CCNWindow : NSWindow
{
    BOOL _needsEnableUpdate;    
}

/** Disables drawing of window until window’s offscreen buffer flushes to the screen.
 * This method need to fix flickers of glView on window resize / splitVew resize. 
 */
- (void)disableUpdatesUntilFlush;

@end

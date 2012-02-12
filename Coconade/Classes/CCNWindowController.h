/*
 * Coconade
 *
 * Copyright (c) 2012 Alexey Lang
 *
 */

#import <AppKit/AppKit.h>

// @TODO: add comments to ALL
@class CSMacGLView;
@interface CCNWindowController : NSWindowController <NSToolbarDelegate, NSSplitViewDelegate>
{
	CSMacGLView	*_glView;
}

@property (readwrite, retain) CSMacGLView *glView;

- (void) prepareWindow;

@end

/*
 * Coconade
 *
 * Copyright (c) 2012 Alexey Lang
 *
 */

#import <AppKit/AppKit.h>

@class CSMacGLView;
@interface CNWindowController : NSWindowController
{
	CSMacGLView	*_glView;
}

@property (readwrite, retain) CSMacGLView *glView;

- (void) prepareWindow;

@end

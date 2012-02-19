//
//  CCNWindowController.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import <AppKit/AppKit.h>


@class CCNMacGLView;
/** @class CCNWindowController controller for Coconade window and its subviews. 
 * Contains all logic of creating, setup and work menus, toolbars, views, etc.
 */
@interface CCNWindowController : NSWindowController <NSToolbarDelegate, NSSplitViewDelegate>
{
	CCNMacGLView	*_glView;
}

/** Holds OpenGL view that used for representation all Cocos2D objects. */
@property (readwrite, retain) CCNMacGLView *glView;

/** Prepare Coconade window - creates and sets up main menu, toolbar, glView, 
 * splitView, scrollView, etc.
 */
- (void) prepareWindow;

@end

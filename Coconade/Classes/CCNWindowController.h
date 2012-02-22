//
//  CCNWindowController.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import <AppKit/AppKit.h>


@class CCNMacGLView;
@class CCNWorkspaceController;
@class CCNWindow;
/** @class CCNWindowController controller for Coconade window and its subviews. 
 * Contains all logic of creating, setup and work menus, toolbars, views, etc.
 */
@interface CCNWindowController : NSWindowController <NSToolbarDelegate, NSSplitViewDelegate>
{
	CCNMacGLView *_glView;
    CCNWorkspaceController *_workspaceController;
}

/** Holds OpenGL view that used for representation all Cocos2D objects. */
@property (readwrite, retain) CCNMacGLView *glView;

/** Holds workspace controller - main logic controller for Coconade. */
@property (readwrite, retain) CCNWorkspaceController *workspaceController;

/** Designated init for CCNWindowController.
 *
 * @param window - main window of Coconade.
 *
 * @param workspaceController - main logic controller for Coconade.
 */
- (id)  initWithWindow: (CCNWindow *) window 
   workspaceController: (CCNWorkspaceController *) workspaceController;

/** Prepare Coconade window - creates and sets up main menu, toolbar, glView, 
 * splitView, scrollView, etc.
 */
- (void) prepareWindow;

@end

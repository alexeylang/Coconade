//
//  CCNWindowController.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import <AppKit/AppKit.h>

#define kCCNWindowControllerCoconadeProjectFileExtension    @"ccn"


@class CCNWorkspaceController;
@class CCNWindow;
/** @class CCNWindowController controller for Coconade window and its subviews. 
 * Contains all logic of creating, setup and work menus, toolbars, views, etc.
 */
@interface CCNWindowController : NSWindowController <NSToolbarDelegate, NSSplitViewDelegate>
{
    CCNWorkspaceController *_workspaceController;
    NSView *_leftView;
    NSScrollView *_centerScrollView;
    NSView *_rightView;
}

/** Holds workspace controller - main logic controller for Coconade. */
@property (readwrite, retain) CCNWorkspaceController *workspaceController;

/** Returns new autoreleased window controller with given window & workspaceController. 
 * @see -initWithWindow:workspaceController:
 */
+ (id) controllerWithWindow: (CCNWindow *) window 
        workspaceController: (CCNWorkspaceController *) workspaceController;

/** Designated init for CCNWindowController.
 *
 * @param window - main window of Coconade.
 *
 * @param workspaceController - main logic controller for Coconade.
 */
- (id)  initWithWindow: (CCNWindow *) window 
   workspaceController: (CCNWorkspaceController *) workspaceController;

@end

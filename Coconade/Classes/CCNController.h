//
//  CCNController.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCEventDispatcher+Gestures.h"
#import "CSMacGLView.h"

@class CCNModel;

/** @class CCNController Main logic controller for Coconade. */
@interface CCNController : NSObject <CCMouseEventDelegate, CCKeyboardEventDelegate, CCGestureEventDelegate, CCNMacGLViewDragAndDropDelegate>
{
    CSMacGLView *_glView;
    
    CCNModel *_model;
    
    // Mouse events.
    BOOL _deselectNodeOnMouseUp;
	BOOL _moveNodeOnMouseDrag;
    CGPoint _prevMouseLocation;
}

/** Model of current project. Changing model will lead to changing all
 * current open context.
 */
@property(readwrite, retain) CCNModel *model;

/** Should be called after finishing work with CCNController & before releasing it.
 * It's simillar to CCNode#enExit method - unregisters controller in EventDispatcher, etc.
 * Without invoking this method CCNController will not be dealloced.
 */
- (void) halt;

#pragma mark Project

/** Removes old model & creates new empty instead. */
- (void) newProject;

#pragma mark Pasteboard

/** Looks for any supported node in pasteboard and adds them with 
 * -addNode:withUniqueNameFromName: 
 */
- (void)addNodesFromPasteboard;

#pragma mark Import

/** Returns array of file extensions (excludng dot), that are supported by Coconade
 * and can be used as images (textures).
 *
 * @todo remove method prototype from public interface or private interface in implementation file
 */
- (NSArray *) allowedImageFileTypes;

/** Creates CCSprites from given filenames and adds it to current selected node
 * (curRootNode or selected node).
 * If sprite can't be added to that node - tries to add it to it's parent.
 * If it can't be added to anything - registers a problem in CCNProblemManager
 *
 * @todo remove method prototype from public interface or private interface in implementation file
 */
- (void)importSpritesWithFiles: (NSArray *) filenames;

/** Adds given node to current selected one 
 * (curRootNode or selected node).
 * If node can't be added to that node - tries to add it to it's parent.
 * If it can't be added to anything - registers a problem in CCNProblemManager
 *
 * @param aNode Node to add to hierarchy.
 *
 * @param name that will be used to create uniqueName and use as name for 
 * added node.
 * Can be nil - aNode.name than will be used instead.
 * If a aNode.name is also nil - className of aNode will be used.
 */
- (void) addNode: (CCNode *) aNode withUniqueNameFromName: (NSString *) name;

@end

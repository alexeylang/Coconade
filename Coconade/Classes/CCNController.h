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

#pragma mark Start / Stop

/** Should be called after initing CCNController and before doing anything with him.
 * It's simillar to CCNode#onEnter method - registers controller in EventDispatcher, etc.
 */
- (void) start;

/** Should be called after finishing work with CCNController.
 * It's simillar to CCNode#enExit method - unregisters controller in EventDispatcher, etc.
 * Without invoking this method CCNController will not get released.
 */
- (void) stop;

#pragma mark Project

/** Removes old model & creates new empty instead. */
- (void) newProject;

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

@end

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
@class CCNScene;
/** @class CCNController Main logic controller for Coconade. */
@interface CCNController : NSObject <CCMouseEventDelegate, CCKeyboardEventDelegate, CCGestureEventDelegate, CCNMacGLViewDragAndDropDelegate>
{
    CSMacGLView *_glView;
    CCNScene *_scene;
    
    CCNModel *_model;
    
    // Mouse events.
    BOOL _deselectNodeOnMouseUp;
	BOOL _moveNodeOnMouseDrag;
    CGPoint _prevMouseLocation;
}

/** Scene that is used to hold everything in Coconade. */
@property(readwrite, retain) CCNScene *scene;

/** Model of current project. Changing model will lead to changing all
 * current open context.
 */
@property(readwrite, retain) CCNModel *model;

/** Returns new autoreleased controller, inited with given glView. 
 * @see -initWithGLView:
 */
+ (id) controllerWithGLView: (CSMacGLView *) glView;

/** Designated init for CCNController.
 *
 * @param glView GLView in which Coconade will run, can't be nil, shouldn't b changed
 * during runtime.
 */
- (id) initWithGLView: (CSMacGLView *) glView;

/** Should be called after finishing work with CCNController & before releasing it.
 * It's simillar to CCNode#enExit method - unregisters controller in EventDispatcher, etc.
 * Without invoking this method CCNController will not be dealloced.
 */
- (void) halt;

#pragma mark Project

/** Removes old model & creates new empty instead. */
- (void) newProject;

/** Loads new model from given file and, if it succeeds - replaces
 * old model with loaded one.
 *
 * @param filepath path to file that holds project.
 *
 * Should be called on cocos thread.
 */
- (void) loadProject: (NSString *) filepath;

#pragma mark Pasteboard

/** Returns YES if there's anything selected now, that can be copied
 * to pasteboard.
 */
- (BOOL) canCopyToPasteboard;

/** Returns YES if there's anything selected now, that can be copied
 * to pasteboard.
 */
- (BOOL) canCutToPasteboard;

/** Returns YES if there's anything in the pasteboard, that can be pasted.
 */
- (BOOL) canPasteFromPasteboard;

/** Copies anything selected to pasteboard and deletes it.
 * If nothing can't be cut to pasteboard - does nothing.
 *
 * Should be called on cocos thread.
 */
- (void)cutToPasteboard;

/** Copies anything selected to pasteboard.
 * If nothing can't be copied to pasteboard - does nothing.
 *
 * Should be called on cocos thread.
 */
- (void)copyToPasteboard;

/** Looks for any supported stuff in pasteboard and adds it with 
 * -addNode:withUniqueNameFromName: 
 *
 * Should be called on cocos thread.
 */
- (void)pasteFromPasteboard;

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

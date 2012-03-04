//
//  CCNWorkspaceController.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCEventDispatcher+Gestures.h"
#import "CCNMacGLView.h"

@class CCNModel;
@class CCNScene;
/** @class CCNWorkspaceController Main logic controller for Coconade. */
@interface CCNWorkspaceController : NSObject <CCMouseEventDelegate, CCKeyboardEventDelegate, CCGestureEventDelegate, CCNMacGLViewDragAndDropDelegate>
{
    CCNMacGLView *_glView;
    CCNScene *_scene;
    
    CCNModel *_model;
    
    // Mouse events.
    CGPoint _prevMouseLocation;
    
    // Dragging nodes.
    int _state;    
    CCNode *_nodeBeingEdited;
}

/** Property to hold glView, provided from outside. */
@property(readwrite, retain) CCNMacGLView *glView;

/** Scene that is used to hold everything in Coconade. */
@property(readwrite, retain) CCNScene *scene;

/** Model of current project. Changing model will lead to changing all
 * current open context.
 */
@property(readwrite, retain) CCNModel *model;

/** Returns new autoreleased controller, inited with given glView. 
 * @see -initWithGLView:
 */
+ (id) controllerWithGLView: (CCNMacGLView *) glView;

/** Designated init for CCNWorkspaceController.
 *
 * @param glView GLView in which Coconade will run, can't be nil, shouldn't be changed
 * during runtime.
 */
- (id) initWithGLView: (CCNMacGLView *) glView;

/** Should be called after finishing work with CCNWorkspaceController & before releasing it.
 * It's simillar to CCNode#enExit method - unregisters controller in EventDispatcher, etc.
 * Without invoking this method CCNWorkspaceController will not be dealloced.
 */
- (void) halt;

#pragma mark - Project ("File" Menu Items Callbacks)

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

/** Loads new model from current projectFilePath if it is set.
 * If loading succeeds - replaces old model with loaded one.
 *
 * Should be called on cocos thread.
 * Does nothing if projectFilePath isn't set.
 */
- (void) revertToSavedProject;

/** Returns YES if there's any current projectFilepath
 * specified and project can be reloaded from it.
 * Otherwise returns NO.
 */
- (BOOL) canRevertToSavedProject;

/** Returns YES if there's any current projectFilepath
 * specified and project can be saved to it, without providing
 * filepath from the outside.
 * Otherwise returns NO.
 */
- (BOOL) canSaveProject;

/** Saves current model to current projectFilePath.
 * If projectFilePath isn't specified - does nothing.
 *
 * @see -saveProjectToFile:
 * @see -canSaveProject
 */
- (void) saveProject;

/** Saves current model to given file.
 * Sets projectFilePath to filepath.
 *
 * @param filepath Path to project file, where project should be saved.
 * This method does nothing if filepath is nil or empty string.
 */
- (void) saveProjectToFile: (NSString *) filepath;

#pragma mark - Edit Menu

#pragma mark Edit Menu Items Validators

/** Returns YES if there's anything selected now that can be deleted.
 * Otherwise returns NO.
 */
- (BOOL) canDeleteSelected;

/** Returns YES if there's anything selected now, that can be copied
 * to pasteboard.
 * Otherwise returns NO.
 */
- (BOOL) canCopySelectedToPasteboard;

/** Returns YES if there's anything selected now, that can be copied
 * to pasteboard.
 * Otherwise returns NO.
 */
- (BOOL) canCutSelectedToPasteboard;

/** Returns YES if there's anything in the pasteboard, that can be pasted.
 * Otherwise returns NO.
 */
- (BOOL) canPasteFromPasteboard;

#pragma mark Edit Menu Items Callbacks

/** Deletes anything selected.
 * If there's nothing that can be deleted - does nothing.
 *
 * Should be called on cocos thread.
 */
- (void) deleteSelected;

/** Copies anything selected to pasteboard and deletes it.
 * If nothing can't be cut to pasteboard - does nothing.
 *
 * Should be called on cocos thread.
 */
- (void) cutSelectedToPasteboard;

/** Copies anything selected to pasteboard.
 * If nothing can't be copied to pasteboard - does nothing.
 *
 * Should be called on cocos thread.
 */
- (void) copySelectedToPasteboard;

/** Looks for any supported stuff in pasteboard and adds it with 
 * -addNode:withUniqueNameFromName: 
 *
 * Should be called on cocos thread.
 */
- (void)pasteFromPasteboard;

#pragma mark  - Import

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
 * @param positionInScene Position in world coordinates, near what sprites should be positioned.
 */
- (void)importSpritesWithFiles: (NSArray *) filenames withPositionInScene: (CGPoint) positionInScene;

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

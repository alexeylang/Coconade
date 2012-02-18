//
//  CCNModel.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCNode;

/** @class CCNModel Main model class. Manages Coconade's project. */
@interface CCNModel : NSObject
{
    // TODO: change to NSBundle
    NSString *_projectFilePath;
    
    
    NSMutableArray *_rootNodes;    
    CCNode *_currentRootNode; //< Weakref.
    CCNode *_selectedNode; //< Weakref.
    NSArray *_currentNodes;
}

/** Holds path to current location of project's file.
 * Can be changed during runtime - this means that next time project will
 * be saved to that path.
 */
@property(readwrite, copy) NSString *projectFilePath;

/** Holds all hierarchies of a project with their children. */
@property(readonly, retain) NSArray *rootNodes;

/** Current root node, that represents current hierarchy that is being edited.
 * Can be non-CCScene.
 *
 * Can't be nil - there's always at least one root node.
 * Changing value of this property to nil will do nothing.
 */
@property (readwrite, assign) CCNode *currentRootNode;

/** Current selected node in current hierarchy, that is being edited.
 * Can be nil - this means that currently no node is selected.
 * Will be changed to nil if currentRootNode will be changed to another root node.
 */
@property (readwrite, assign) CCNode *selectedNode;

/** Array of all nodes in current hierarchy that is being edited, including
 * currentRootNode, it's children, grandchildren, grandgrandchildren and so on.
 * Used to iterate over all nodes in current hierarchy.
 * Changes automatically, when currentRootNode is changed.
 *
 * Nodes in this array are sorted by their order of arrival in scene.
 * First node is the one that's on top.
 *
 * Can't be nil, count is always >=1
 * (because there's always at least one root node in the project).
 */
@property (readonly, retain) NSArray *currentNodes;


/** Removes given node from model.
 * It can be selectedNode, rootNode or curRootNode.
 * Does nothing if aNode is nil or isn't present in model.
 *
 * If aNode is selectedNode - it will be unselected.
 *
 * If last rootNode is removed - new default one will be created to always have
 * at least one rootNode.
 *
 * If aNode is currentRootNode - closest hierarchy will be selected as current instead.
 *
 * Should be called in Cocos2D thread.
 */
- (void) removeNode: (CCNode *) aNode;


@end

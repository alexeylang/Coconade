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
    /** Holds all hierarchies of a project with their children. */
    NSDictionary *_rootNodes;
    
    /* Weakref to current hierarchy that is being edited (one of the rootNodes). */
    CCNode *_currentRootNode;
    
    /* Weakref to selected node in current hierarchy.  */
    CCNode *_selectedNode;
    
    /* SelectedRootNode & All it's Children, sorted by their Z-Order.
     * Used to search through all nodes in current hierarchy, that is being edited.
     */
    NSArray *_currentNodes;
}

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
 * Can't be nil, count is always >=1
 * (because there's always at least one root node in the project).
 */
@property (readonly, retain) NSArray *currentNodes;



@end

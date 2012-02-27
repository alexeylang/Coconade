//
//  CCNModel.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCCNModelDefaultRootNodeClass           CCScene
#define kCCNModelDefaultRootNodeContentSize()   CGSizeMake(480,320)

@class CCNode;

/** @class CCNModel Main model class. Manages Coconade's project. */
@interface CCNModel : NSObject
{
    // TODO: change to NSBundle
    NSString *_projectFilePath;
    
    
    NSMutableArray *_rootNodes;    
    CCNode *_currentRootNode; //< Weakref.
    NSMutableArray *_selectedNodes;
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

/** Array of selected CCNodes in current hierarchy, that is being edited.
 * Can't be nil - only empty - this means that currently no node is selected.
 * Will be changed to empty array automatically if currentRootNode will be changed to another root node.
 */
@property(readonly, retain) NSArray *selectedNodes;

/** Array of all nodes in current hierarchy that is being edited, including
 * currentRootNode's children (but not currentRootNode itself), grandchildren, 
 * grandgrandchildren and so on.
 * Used to iterate over all nodes in current hierarchy.
 * Changes automatically, when currentRootNode is changed.
 *
 * Nodes in this array are sorted by their order of arrival in scene.
 * First node is the one that's on top.
 *
 * Can't be nil.
 */
@property (readonly, retain) NSArray *currentNodes;

#pragma mark Init/Loading

/** Returns new autoreleased model, loaded from file. 
 * @see -initWithFile:
 */
+ (id) modelFromFile: (NSString *) filepath;

/** Inits model from conents of given file.
 *
 * @param filepath path to file to init from, will be used to set projectFilePath.
 * That file should be plist with AMC dictionary with rootNodes.
 * @todo Support JSON files too.
 *
 * @return nil if there was any problem loading rootNodes from filepath or model
 * object is everything is ok.
 */
- (id) initWithFile: (NSString *) filepath;

#pragma mark Saving

/** Saves rootNodes as dictionary to given file.
 * If filename is different from projectFilePath - projectFilePath will be
 * set to filename.
 */
- (void)saveToFile:(NSString *)filename;

#pragma mark Working with Nodes

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

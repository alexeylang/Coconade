//
//  CCNScene.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNSelection.h" 

#define kCCNSceneUserDefaultsKeyShowBorders         @"CSMainLayerShowBorders" //< TODO: change to @"CCNSceneShowBorders"
#define kCCNSceneUserDefaultsKeyShowCheckerboard    @"CCNSceneShowCheckerboard"

/** @class CCNScene Scene subclass that is used as running scene in Coconade.
 * CCNScene incapsulates Cocos2D nodes that are used as a part of Coconade UI
 * (checkerboard background, scene borders, etc).
 * It holds current selected root node, providing parent for non-CCScene
 * root nodes.
 */
@interface CCNScene : CCScene 
{
    CCNode *_targetNode;
    CCSprite *_checkerboardSprite;
    NSMutableArray *_selections;
    
    BOOL _showBordersAndCheckerboard;
    BOOL _updateForScreenReshapeNextVisit;
}

/**
 * When set to YES - CCNScene renders border around itself & checkerboard instead
 * of simple black background.
 * Default value is YES.
 *
 * Saved in UserDefault with key = kCCNSceneUserDefaultsKeyShowBorders
 */
@property(readwrite) BOOL showBordersAndCheckerboard;

/** Current selected root node of Coconade, that we work in.
 * It can be CCScene - then this class will delegate visit to targetNode.
 * Can be nil.
 */
@property(readwrite, retain) CCNode *targetNode;

/** Repeated sprite that is used as a background. */
@property(readwrite, retain) CCSprite *checkerboardSprite;

#pragma mark Updates

/** Thread-safe version of updateForScreenReshape.  */
- (void) updateForScreenReshapeSafely: (NSNotification *) aNotification;

/** Updates it's size & contents to fit current winSize. */
- (void) updateForScreenReshape;

#pragma mark Selection Controls

/** Disables all selections highlights. */
- (void) removeAllNodesSelections;

/** Ensures that given node is highlighted with selection. 
 * Does nothing if node is nil or already selected.
 */
- (void) addNodeToSelection: (CCNode *) aNode;

@end

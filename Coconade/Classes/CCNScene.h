//
//  CCNScene.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CCNSelection.h" 

/** @class CCNScene Scene subclass that is used as running scene in Coconade.
 * CCNScene incapsulates Cocos2D nodes that are used as a part of Coconade UI
 * (checkerboard background, scene borders, etc).
 * It holds current selected root node, providing parent for non-CCScene
 * root nodes.
 */
@interface CCNScene : CCScene 
{
    CCNode *_targetNode;
    CCSprite *_backgroundSprite;
    CCNSelection *_selection;
    
    BOOL _showBorders;
    BOOL _updateForScreenReshapeNextVisit;
}

/**
 * When set to YES - CCNScene renders border around itself.
 */
@property(readwrite) BOOL showBorders;

// TODO: implement:
/**
 * When set to YES - CCNScene renders repeated backgroundSprite filling it's contentSize.
 */
//@property(readwrite) BOOL showBackground;

/** Current selected root node of Coconade, that we work in.
 * It can be CCScene - then this class will delegate visit to targetNode.
 * Can be nil.
 */
@property(readwrite, retain) CCNode *targetNode;

/** Repeated sprite that is used as a background. */
@property(readwrite, retain) CCSprite *backgroundSprite;

/** Selection Effect & Tools for Selected Node. */
@property(readonly, retain) CCNSelection *selection;

/** Thread-safe version of updateForScreenReshape.  */
- (void) updateForScreenReshapeSafely: (NSNotification *) aNotification;

/** Updates it's size & contents to fit current winSize. */
- (void) updateForScreenReshape;

@end

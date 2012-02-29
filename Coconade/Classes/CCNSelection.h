//
//  CCNSelection.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

enum CCNSelectionMode
{
    /** In that mode selection can be used to move node & scale it from any corner or side. */
    kCCNSelectionModePositionAndScale,
    
    /** In that mode selection can be used to move node, rotate it with corners & skew at any side. */
    kCCNSelectionModePositionAndRotate,
    
    kCCNSelectionModeFirst = kCCNSelectionModePositionAndScale,
    kCCNSelectionModeLast = kCCNSelectionModePositionAndRotate,
};

/** @class CCNSelection Node that located in the root level of
 * node hierarchy, grabs another node and highlights it, applying targetNode
 * transformation to self.
 *
 * @todo Add ability to transform target node via GUI of CCNSelection
 */
@interface CCNSelection : CCNode <CCMouseEventDelegate> {
    
    CCNode *_targetNode;
    
    CCLayerColor *_fill;
	CCSprite *_anchor;
	CCLabelBMFont *_positionLabel;
    
    // Selection mode. Should be one of the kCCNSelectionNodeXXX.
    int _mode;
    
    // Scale mode elements (weak refs to children).
    CCSprite *_scaleRight;
    CCSprite *_scaleRightTop;
    CCSprite *_scaleTop;
    CCSprite *_scaleLeftTop;
    CCSprite *_scaleLeft;
    CCSprite *_scaleLeftBottom;
    CCSprite *_scaleBottom;
    CCSprite *_scaleRightBottom;
    
    // Rotate/Skew mode elements (weak refs to children).
    CCSprite *_skewRight;
    CCSprite *_rotateRightTop;
    CCSprite *_skewTop;
    CCSprite *_rotateLeftTop;
    CCSprite *_skewLeft;
    CCSprite *_rotateLeftBottom;
    CCSprite *_skewBottom;
    CCSprite *_rotateRightBottom;
    
    BOOL _dragAnchor;
    CGPoint _prevMouseLocation;
}

/** Node that will be highlated by CCNSelection.
 * Can be located anywhere in node hierarchy - nodeToWorldTransform will be used
 * to set transform of CCNSelection.
 * Can be nil - this means that nothing get's highlighted and CCNSelection is hidden.
 */
@property(readwrite, retain) CCNode *targetNode;

/** Changes selection mode to next, if already last mode is used - starts again from first. */
- (void) toggleMode;

@end

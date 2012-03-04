//
//  CCNSelection.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** @class CCNSelection Node that located in the root level of
 * node hierarchy, grabs another node and highlights it, applying targetNode
 * transformation to self.
 * It's used only as highlight, and doesn't change anything in targetNode by itself.
 */
@interface CCNSelection : CCNode {
    
    CCNode *_targetNode;
    
    CCLayerColor *_fill;
	CCSprite *_anchor;
	CCLabelBMFont *_positionLabel;
    
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
}

/** Node that will be highlated by CCNSelection.
 * Can be located anywhere in node hierarchy - nodeToWorldTransform will be used
 * to set transform of CCNSelection.
 * Can be nil - this means that nothing get's highlighted and CCNSelection is hidden.
 */
@property(readwrite, retain) CCNode *targetNode;

/** Returns node, that is positioned at targetNode's anchorPoint. */
@property(readonly, retain) CCNode *anchorPointIndicator;

@end

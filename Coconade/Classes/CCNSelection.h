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
    CCSprite *_elementRight;
    CCSprite *_elementRightTop;
    CCSprite *_elementTop;
    CCSprite *_elementLeftTop;
    CCSprite *_elementLeft;
    CCSprite *_elementLeftBottom;
    CCSprite *_elementBottom;
    CCSprite *_elementRightBottom;
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

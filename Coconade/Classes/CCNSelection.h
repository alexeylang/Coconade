//
//  CCNSelection.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

typedef enum
{
    kCCNSelectionElementTypeWrong = 0, //< Element that doesn't exist.
    
    kCCNSelectionElementTypeTop,
    kCCNSelectionElementTypeBottom,
    kCCNSelectionElementTypeLeft,
    kCCNSelectionElementTypeRight,
    
    kCCNSelectionElementTypeTopLeft,
    kCCNSelectionElementTypeTopRight,
    kCCNSelectionElementTypeBottomLeft,
    kCCNSelectionElementTypeBottomRight,
} CCNSelectionElementType;

typedef enum
{
    kCCNSelectionElementsModeSquaresAndRectangles,
    kCCNSelectionElementsModeCirclesAndParallelograms,
} CCNSelectionElementsMode;

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
    
    // Corners & sides elements (weak refs to children).
    CCSprite *_elementRight;
    CCSprite *_elementRightTop;
    CCSprite *_elementTop;
    CCSprite *_elementLeftTop;
    CCSprite *_elementLeft;
    CCSprite *_elementLeftBottom;
    CCSprite *_elementBottom;
    CCSprite *_elementRightBottom;
    
    CCNSelectionElementsMode _elementsMode;
}

/** Node that will be highlated by CCNSelection.
 * Can be located anywhere in node hierarchy - nodeToWorldTransform will be used
 * to set transform of CCNSelection.
 * Can be nil - this means that nothing get's highlighted and CCNSelection is hidden.
 */
@property(readwrite, retain) CCNode *targetNode;

/** Selection mode, can be one of the kCCNSelectionElementsModeXXX constants.
 * Changing this property will affect CCNSelection's look.
 */
@property(readwrite, assign) CCNSelectionElementsMode elementsMode;

/** Returns node, that is positioned at targetNode's anchorPoint. */
@property(readonly, retain) CCNode *anchorPointIndicator;

/** Returns node of element with given type. */
- (CCNode *) elementNodeWithType: (CCNSelectionElementType) type;

@end

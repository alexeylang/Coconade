//
//  CCNSelection.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/** @class CCNSelection Node that located in the root level of
 * node hierarchy, grabs another node and highlights it, applying targetNode
 * transformation to self.
 *
 * @todo Add ability to transform target node via GUI of CCNSelection
 */
@interface CCNSelection : CCNode {
    
    CCNode *_targetNode;
    
    CCLayerColor *_fill;
	CCSprite *_anchor;
	CCLabelBMFont *_positionLabel;
}

/** Node that will be highlated by CCNSelection.
 * Can be located anywhere in node hierarchy - nodeToWorldTransform will be used
 * to set transform of CCNSelection.
 * Can be nil - this means that nothing get's highlighted and CCNSelection is hidden.
 */
@property(readwrite, retain) CCNode *targetNode;

@end

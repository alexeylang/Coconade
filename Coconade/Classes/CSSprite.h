/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
 * Copyright (c) 2011-2012 Stepan Generalov
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

// TODO: refactor to CCNSelection : CCNode
// It should be rendered as notificationNode in CCDirector & attached to a node
// in a scene.
// It should use node's transform to transform itself around this node.
// It SHOULD NOT contain any transform logic.
// It SHOULD NOT be saved anywhere.
// TODO: Create new file to exclude Andrew's copyright & MIT License.

#import "cocos2d.h"

#define kCSSpriteStrokeSize 1

/*
	CSSprite is a CCSprite subclass, that is used in cocoshop to display sprites
 on the workspace.
	It can be selected - in that state it is highlighted with a rectangle around
 its contents, shows anchorPoint and position.
	Also it supports NSCoding and provides methods to load & save self to/from 
 NSDictionary.
 */
@interface CSSprite : CCSprite <NSCoding,NSPasteboardReading, NSPasteboardWriting>
{
	BOOL isSelected_;
	
	CCLayerColor *fill_;
	CCSprite *anchor_;
	CCLabelBMFont *positionLabel_;
	
	BOOL willUpdatePositionLabel_;
}

@property(nonatomic, assign) BOOL isSelected;

// changes position and text of positionLabel
// must be called on Cocos2D thread
- (void)updatePositionLabel;

// marks that updatePositionLabel must be called once at next visit
- (void)updatePositionLabelSafely;

@end

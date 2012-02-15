/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
 * Copyright (c) 2011 Stepan Generalov
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

#import "CSModel.h"
#import "cocos2d.h"
#import "CCNScene.h"

@implementation CSModel

@synthesize selectedSprite=selectedSprite_;
@synthesize spriteArray=spriteArray_;

@synthesize posX=posX_;
@synthesize posY=posY_;
@synthesize posZ=posZ_;
@synthesize anchorX=anchorX_;
@synthesize anchorY=anchorY_;
@synthesize scaleX=scaleX_;
@synthesize scaleY=scaleY_;
@synthesize rotation=rotation_;
@synthesize contentSizeWidth=contentSizeWidth_;
@synthesize contentSizeHeight=contentSizeHeight_;
@synthesize relativeAnchor=relativeAnchor_;
@synthesize tag=tag_;

@synthesize flipX=flipX_;
@synthesize flipY=flipY_;
@synthesize opacity=opacity_;
@synthesize color=color_;

@synthesize name=name_;

#pragma mark Init / DeInit

- (id)init
{
	if((self=[super init]))
	{
		[self setSpriteArray:[NSMutableArray array]];
	}
	return self;
}

- (void)awakeFromNib
{
}

- (void)dealloc
{
	[self setSpriteArray:nil];
	[self setColor:nil];
	[super dealloc];
}

#pragma mark Sprite Access 

- (void)setSelectedSprite:(CCNode *)aSprite
{
	// make sure that sprites aren't same key or both nil
	if( ![selectedSprite_ isEqualTo:aSprite] )
	{		
		selectedSprite_ = aSprite;
		
		// select new sprite
		CCNode *new = selectedSprite_;
		if(new)
		{
            CCNScene *scene = (CCNScene *)[[CCDirector sharedDirector] runningScene];
            if ([scene isKindOfClass: [CCNScene class] ])
            {
                CCNSelection *selection = scene.selection;
                scene.selection.targetNode = new;
            }
            
            id <CCRGBAProtocol> newWithRGBAProtocol = nil; 
            
            if ([new conformsToProtocol: @protocol(CCRGBAProtocol)])
            {
                newWithRGBAProtocol = (id <CCRGBAProtocol>) new;
            }
            
            CCSprite *newSprite = nil;
            if ([new isKindOfClass: [CCSprite class]])
            {
                newSprite = (CCSprite *) newSprite;
            }
            
            
			CGPoint pos = [new position];
			CGPoint anchor = [new anchorPoint];
			NSColor *col = [NSColor colorWithDeviceRed:[newWithRGBAProtocol color].r/255.0f green:[newWithRGBAProtocol color].g/255.0f blue:[newWithRGBAProtocol color].b/255.0f alpha:255];
			
			[self setName:[new name]];
			[self setPosX:pos.x];
			[self setPosY:pos.y];
			[self setPosZ: [new zOrder]];
			[self setAnchorX:anchor.x];
			[self setAnchorY:anchor.y];
			[self setFlipX:([newSprite flipX]) ? NSOnState : NSOffState];
			[self setFlipY:([newSprite flipY]) ? NSOnState : NSOffState];
			[self setRotation:[new rotation]];
			[self setScaleX:[new scaleX]];
			[self setScaleY:[new scaleY]];
            [self setOpacity:[newWithRGBAProtocol opacity]];
            
			[self setColor:col];
			[self setRelativeAnchor:([new isRelativeAnchorPoint]) ? NSOnState : NSOffState];
		}
		
		// tell controller we changed the selected sprite
		[[NSNotificationCenter defaultCenter] postNotificationName:@"didChangeSelectedSprite" object:nil];
	}
}

- (CCNode *)spriteWithName: (NSString *) name
{
	for (CCNode *sprite in spriteArray_)
	{
		if ([sprite.name isEqualToString: name]) {
			return sprite;
		}
	}
	
	return nil;
}

//TODO: add ability to have multiple selection and return array of selected sprites here
- (NSArray *)selectedSprites
{
	if ([self selectedSprite])
	{
		return [NSArray arrayWithObjects: [self selectedSprite], nil];
	}
	return nil;
}

#pragma mark AntiNibCrash Spikes

- (float) stageWidth
{
    return 1337.0f;
}

- (float) stageHeight
{
    return 1337.0f;
}

@end

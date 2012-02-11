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

#import "CSMainLayer.h"
#import "CCNode+Helpers.h"
#import "CSSprite.h"
#import "CSObjectController.h"
#import "CSModel.h"
#import "CSMacGLView.h"
#import "NSString+RelativePath.h"
#import "cocoshopAppDelegate.h"

@implementation CSMainLayer

@synthesize controller=controller_;

#pragma mark Init / DeInit
+ (id)nodeWithController:(CSObjectController *)aController
{
	return [[[self alloc] initWithController:aController] autorelease];
}

- (id)initWithController:(CSObjectController *)aController
{
	if((self=[super init]))
	{
		[self setIsMouseEnabled:YES];
		[self setIsKeyboardEnabled:YES];
		[self setController:aController];
		
		// Register for Notifications
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addedSprite:) name:@"addedSprite" object:nil];
		
		// Add Colored Background
		CCLayerColor *bgLayer = [[controller_ modelObject] backgroundLayer];
		if (bgLayer)
			[self addChild:bgLayer z:NSIntegerMin];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[self setController:nil];
	[super dealloc];
}

#pragma mark Children Getters

- (CSSprite *)spriteForEvent:(NSEvent *)event
{
    CCNode *bgLayer = [[controller_ modelObject] backgroundLayer];
    CCArray *children = [bgLayer children];
    
    NSUInteger childrenCount = [children count];
	for(NSUInteger i = 0; i < childrenCount; ++i)
	{
        // Use reversedIndex to iterate backwards.
        NSUInteger reversedIndex = childrenCount - i - 1;
        
		CCNode *child = [children objectAtIndex:reversedIndex];
		if([child isKindOfClass:[CSSprite class]] && [CCNode isEvent:event locatedInNode:child])
		{
			return (CSSprite *)child;
		}
	}
	
	return nil;
}


#pragma mark Notifications

- (void)addedSprite:(NSNotification *)aNotification
{
	// queue sprites update on next visit (in Cocos2D Thread)
	didAddSprite_ = YES;
	[[controller_ spriteTableView] reloadData];
}

// adds new sprites as children if needed - should be called on Cocos2D Thread
- (void) updateSpritesFromModel
{
	CSModel *model = [controller_ modelObject];
	NSMutableArray *spriteArray = [model spriteArray];
    CCNode *bgLayer = [model backgroundLayer];
	
	@synchronized(spriteArray)
	{
		for(CSSprite *sprite in spriteArray)
		{
			if( ![sprite parent] )
			{
				[bgLayer addChild:sprite z: [sprite zOrder]];
				[model setSelectedSprite:sprite];
			}
		}
	}
}

#pragma mark CCNode Reimplemented Methods

- (void) onEnter
{
	[super onEnter];
	
	// Update Background Info View at App Start
	[[controller_ modelObject] setSelectedSprite: nil];
	
	NSString *filename = nil;
	if ( (filename = [(cocoshopAppDelegate *)[[NSApplication sharedApplication ] delegate] filenameToOpen]))
	{
		[self runAction:[CCCallBlock actionWithBlock: ^{
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: filename];
			controller_.projectFilename = filename;
			[controller_ loadProjectFromDictionarySafely: dict];			
			[(cocoshopAppDelegate *)[[NSApplication sharedApplication ] delegate] setFilenameToOpen: nil];
		}]];
		
	}
}

- (void) visit
{	
	if (didAddSprite_)
		[self updateSpritesFromModel];
	didAddSprite_ = NO;
	
	[super visit];
}

#pragma mark Touch Events

- (void)csMagnifyWithEvent:(NSEvent *)event
{
	CSSprite *sprite = [[controller_ modelObject] selectedSprite];
	CSModel *model = [controller_ modelObject];
	if (sprite)
	{
		float currentScaleX = [model scaleX];
		float currentScaleY = [model scaleY];
		float newScaleX = currentScaleX + [event magnification];
		float newScaleY = currentScaleY + [event magnification];
		
		// round to nearest hundredth
		newScaleX = roundf(newScaleX * 100)/100.0f;
		newScaleY = roundf(newScaleY * 100)/100.0f;
		
		[[controller_ modelObject] setScaleX:newScaleX];
		[[controller_ modelObject] setScaleY:newScaleY];
	}
}

- (void)csRotateWithEvent:(NSEvent *)event
{
	CSSprite *sprite = [[controller_ modelObject] selectedSprite];
	if (sprite)
	{
		float currentRotation = [sprite rotation];
		float rotationChange = -[event rotation]; // need to negate
		float newRotation = currentRotation + rotationChange;
		
		// make the new rotation 0 - 360
		if (newRotation < 0)
			newRotation += 360;
		else if (newRotation > 360)
			newRotation -= 360;
		
		// rounding
		newRotation = roundf(newRotation);
		
		[[controller_ modelObject] setRotation:newRotation];
	}
}

#pragma mark Mouse Events

- (BOOL)ccMouseDown:(NSEvent *)event
{
	shouldToggleVisibility_ = NO;
	shouldDragSprite_ = NO;
	
	CSModel *model = [controller_ modelObject];
	
	CSSprite *sprite = [self spriteForEvent:event];
	if(sprite)
	{
		// if this isn't the selected sprite, select it
		// otherwise, plan on deselecting it (unless it is moved)
		if([model selectedSprite] != sprite)
			[model setSelectedSprite:sprite];
		else
			shouldToggleVisibility_ = YES;
		
		shouldDragSprite_ = YES;
	}
	
	// if we touch outside of selected sprite, deselect it
	CSSprite *selectedSprite = [model selectedSprite];
	if(selectedSprite)
	{
		if(![CCNode isEvent:event locatedInNode:selectedSprite])
		{
			[model setSelectedSprite:nil];
		}
	}
	
	prevLocation_ = [[CCDirector sharedDirector] convertEventToGL:event];
	
	return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
	// we're dragging the sprite, so don't deselect it
	shouldToggleVisibility_ = NO;
	
	CGPoint location = [[CCDirector sharedDirector] convertEventToGL:event];
	
	CSModel *model = [controller_ modelObject];
	
	// drag the sprite
	if(shouldDragSprite_)
	{
		CSSprite *sprite = [model selectedSprite];
		if(sprite)
		{
			// note that we don't change the position value directly
			// the control will observe the change in posX and do it
			// for us
			CGPoint diff = ccpSub(location, prevLocation_);
			CGPoint currentPos = [sprite position];
			CGPoint newPos = ccpAdd(currentPos, diff);
			[[controller_ modelObject] setPosX:newPos.x];
			[[controller_ modelObject] setPosY:newPos.y];
		}
	}
	
	prevLocation_ = location;
	
	return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	// are we supposed to toggle the visibility?
	if(shouldToggleVisibility_)
	{
		CSModel *model = [controller_ modelObject];
		[model setSelectedSprite:nil];
	}
	
	prevLocation_ = [[CCDirector sharedDirector] convertEventToGL:event];
	
	return YES;
}

#pragma mark Keyboard Events

// Keycodes available here: http://forums.macrumors.com/showpost.php?p=8428116&postcount=2
- (BOOL)ccKeyDown:(NSEvent *)event
{
	NSUInteger modifiers = [event modifierFlags];
	unsigned short keyCode = [event keyCode];
	CSModel *model = [controller_ modelObject];
	
	// delete sprites
	switch(keyCode)
	{
		case 0x33: // delete
		case 0x75: // forward delete
			[controller_ performSelectorOnMainThread:@selector(deleteSprite:) withObject:[[controller_ modelObject] selectedSprite] waitUntilDone:NO];
			return YES;
		default:
			break;
	}
	
	// if option/alt key is pressed....
	if(modifiers & NSAlternateKeyMask)
	{
		// move anchor point
		CGFloat increment = (modifiers & NSShiftKeyMask) ? 0.1f : 0.01f;
		
		switch(keyCode)
		{
			case 0x7B: // left arrow
				[model setAnchorX:[model anchorX]-increment];
				return YES;
			case 0x7C: // right arrow
				[model setAnchorX:[model anchorX]+increment];
				return YES;
			case 0x7D: // down arrow
				[model setAnchorY:[model anchorY]-increment];
				return YES;
			case 0x7E: // up arrow
				[model setAnchorY:[model anchorY]+increment];
				return YES;
			default:
				return NO;
		}		
	}
	else if (modifiers & NSControlKeyMask)
	{
		// rotate sprite
		CGFloat increment = (modifiers & NSShiftKeyMask) ? 10.0f : 1.0f;
		
		switch(keyCode)
		{
			case 0x7B: // left arrow
				[model setRotation:[model rotation]-increment];
				return YES;
			case 0x7C: // right arrow
				[model setRotation:[model rotation]+increment];
				return YES;
			default:
				return NO;
		}
	}
	else
	{
		// move position & change z
		NSInteger increment = (modifiers & NSShiftKeyMask) ? 10 : 1;
		
		switch(keyCode)
		{
			case 0x7B: // left arrow
				[model setPosX:[model posX]-increment];
				return YES;
			case 0x7C: // right arrow
				[model setPosX:[model posX]+increment];
				return YES;
			case 0x7D: // down arrow
				[model setPosY:[model posY]-increment];
				return YES;
			case 0x7E: // up arrow
				[model setPosY:[model posY]+increment];
				return YES;
			case 0x74: // page up
				[model setPosZ:[model posZ]+increment];
				return YES;
			case 0x79: // page down
				[model setPosZ:[model posZ]-increment];
				return YES;
			default:
				return NO;
		}
	}
	
	return NO;
}


@end

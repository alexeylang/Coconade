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

- (void) visit
{	
	if (didAddSprite_)
		[self updateSpritesFromModel];
	didAddSprite_ = NO;
	
	[super visit];
}


@end

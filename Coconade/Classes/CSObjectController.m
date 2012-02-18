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

#import "CSObjectController.h"
#import "CSModel.h"
#import "cocoshopAppDelegate.h"
#import "DebugLog.h"
#import "NSString+RelativePath.h"
#import "CCNScene.h"
#import "CCNode+Helpers.h"
#import "CCEventDispatcher+Gestures.h"
#import "CCNModel.h"
#import "NSObject+Blocks.h"

@implementation CSObjectController

@synthesize ccnController = _ccnController;
@synthesize modelObject=modelObject_;
@synthesize spriteTableView=spriteTableView_;
@synthesize spriteInfoView = spriteInfoView_;
@synthesize backgroundInfoView = backgroundInfoView_;
@synthesize projectFilename = projectFilename_;

#pragma mark Init / DeInit

- (void)awakeFromNib
{
    self.ccnController = [[CCNController new] autorelease];
    [self.ccnController start];
}

- (void)dealloc
{
    self.ccnController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];	
	[super dealloc];
}

- (void)deleteSprite:(CCNode *)sprite
{
	[self.ccnController.model removeNode: sprite];
}


#pragma mark IBActions

// TODO: move to CCNWindowController
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	DebugLog(@"fuck");
	
	// "Save"
	if ([menuItem action] == @selector(saveProject:))
		return YES;
	
	// "Revert to Saved"
	if ([menuItem action] == @selector(saveProject:))
	{
		if (self.projectFilename)
			return YES;
		return NO;
	}
	
	// "Cut"
	if ([menuItem action] == @selector(cutMenuItemPressed:))
	{
		if ([modelObject_ selectedSprite])
			return YES;
		return NO;
	}
	
	// "Copy"
	if ([menuItem action] == @selector(copyMenuItemPressed:))
	{
		if ([modelObject_ selectedSprite])
			return YES;
		return NO;
	}
	
	// "Paste"
	if ([menuItem action] == @selector(pasteMenuItemPressed:))
	{
		NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
        NSDictionary *options = [NSDictionary dictionary];
        return [generalPasteboard canReadObjectForClasses:[NSArray arrayWithObject:[CCNode class]] options:options];
	}
	
	// "Delete"
	if ([menuItem action] == @selector(deleteMenuItemPressed:))
	{
		if ([modelObject_ selectedSprite])
			return YES;
		return NO;
	}
	
	// "Show Borders"- using ivar, because NSOnState doesn't set right in IB
    CCNScene *scene = (CCNScene *)[[CCDirector sharedDirector] runningScene];
	showBordersMenuItem_.state = (scene.showBorders) ? NSOnState : NSOffState;
	
	return YES;
}

// TODO: move to CCNWindowController
- (IBAction)saveProject:(id)sender
{
	if (! self.projectFilename) 
	{
		[self saveProjectAs: sender];
		return;
	}
	
	[self performBlockOnCocosThread: ^()
     {
         [self.ccnController.model saveToFile: self.ccnController.model.projectFilePath];
     }];
}

// TODO: move to CCNWindowControler
- (IBAction)saveProjectAs:(id)sender
{	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"csd", @"ccb", nil]];
	
	// handle the save panel
	[savePanel beginSheetModalForWindow:[[[CCDirector sharedDirector] openGLView] window] completionHandler:^(NSInteger result) {
		if(result == NSOKButton)
		{
            NSString *file = [savePanel filename];
            
            [self performBlockOnCocosThread: ^()
             {
                 [self.ccnController.model saveToFile: file];
             }];
		}
	}];
}

- (IBAction)newProject:(id)sender
{
    [self performBlockOnCocosThread:^()
     {
         [self.ccnController newProject];	
     }];
}

// TODO: move to CCNWindowController
- (IBAction)openProject:(id)sender
{
	// initialize panel + set flags
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"csd"]];
	[openPanel setAllowsOtherFileTypes:NO];	
	
	// handle the open panel
	[openPanel beginSheetModalForWindow:[[[CCDirector sharedDirector] openGLView] window] completionHandler:^(NSInteger result) {
		if(result == NSOKButton)
		{
			NSArray *files = [openPanel filenames];
			NSString *file = [files objectAtIndex:0];
			
			if(file)
			{
                [self performBlockOnCocosThread:^()
                 {
                     CCNModel *newModel = [CCNModel modelFromFile: file ];
                     if (!newModel)
                     {
                         [self performBlockOnMainThread:^()
                          {
                              [[NSAlert alertWithMessageText: @"Can't open file." 
                                               defaultButton: @"OK"
                                             alternateButton: nil
                                                 otherButton: nil 
                                   informativeTextWithFormat: @"Can't create CCNModel from %@", file] runModal];
                          }];
                     }
                     else
                     {
                         self.ccnController.model = newModel;
                     }
                 }];
			}
		}
	}];
}

// TODO: move to CCNWindowController
- (IBAction)revertToSavedProject:(id)sender
{
    [self performBlockOnCocosThread:^()
     {
         CCNModel *newModel = [CCNModel modelFromFile: self.ccnController.model.projectFilePath ];
         if (!newModel)
         {
             [self performBlockOnMainThread:^()
              {
                  [[NSAlert alertWithMessageText: @"Can't open file." 
                                   defaultButton: @"OK"
                                 alternateButton: nil
                                     otherButton: nil 
                       informativeTextWithFormat: @"Can't create CCNModel from %@", self.ccnController.model.projectFilePath] runModal];
              }];
         }
         else
         {
             self.ccnController.model = newModel;
         }
     }];
}

#pragma mark IBActions - Sprites

// TODO: move to CCNWindowController
- (IBAction)addSprite:(id)sender
{
	// allowed file types
	NSArray *allowedTypes = [self.ccnController allowedImageFileTypes];
	
	// initialize panel + set flags
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setAllowedFileTypes:allowedTypes];
	[openPanel setAllowsOtherFileTypes:NO];
	
	// handle the open panel
	[openPanel beginSheetModalForWindow:[[[CCDirector sharedDirector] openGLView] window] completionHandler:^(NSInteger result) {
		if(result == NSOKButton)
		{
			NSArray *files = [openPanel filenames];
			
            [self performBlockOnCocosThread:^()
             {
                 [self.ccnController importSpritesWithFiles: files];
             }];
			
		}
	}];
}

#pragma mark IBActions - Zoom

// TODO: move to CCNWindowController
- (IBAction)resetZoom:(id)sender
{
	[(CSMacGLView *)[[CCDirector sharedDirector] openGLView] resetZoom];
}

#pragma mark IBActions - Menus
// TODO: forward
- (IBAction) showBordersMenuItemPressed: (id) sender
{
    CCNScene *scene = (CCNScene *)[[CCDirector sharedDirector] runningScene];
	scene.showBorders = ([sender state] == NSOffState);
}

// TODO: move to CCNWindowController or CCNController
- (IBAction) deleteMenuItemPressed: (id) sender
{
	[self deleteSprite:[modelObject_ selectedSprite]];
}

// TODO: move to CCNWindowController or CCNController
- (IBAction) cutMenuItemPressed: (id) sender
{
	[self copyMenuItemPressed: sender];
	[self deleteSprite:[modelObject_ selectedSprite]];
}

// TODO: move to CCNWindowController or CCNController
- (IBAction) copyMenuItemPressed: (id) sender
{
	// write selected sprite to pasteboard
	NSArray *objectsToCopy = [modelObject_ selectedSprites];
	if (objectsToCopy)
	{
		NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
		[pasteboard clearContents];		
		
		if (![pasteboard writeObjects:objectsToCopy] )
		{
			DebugLog(@"Error writing to pasteboard, sprites = %@", objectsToCopy);
		}
	}
}

// TODO: move to CCNController
// SHOULD BE CALLED ON COCOS2D THREAD
- (void)addNodesFromPasteboard
{
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    NSDictionary *options = [NSDictionary dictionary];
    
    NSArray *newNodes = [generalPasteboard readObjectsForClasses:[NSArray arrayWithObject:[CCNode class]] options:options];
	
	for(CCNode *node in newNodes)
	{
        // TODO: convert to CCNModel
        // if there's selectedNode - add children to it.
        // if there's no selectedNode - add children to currentRootNode.
        // No synchronized needed - all CCNModel methods should be called in cocos2d thread.
		@synchronized( [modelObject_ spriteArray] )
		{			
			[[modelObject_ spriteArray] addObject:node];
		}
		
		[self updateSpritesFromModel];
	}
}

// TODO: move to CCNWindowController or CCNController
- (IBAction) pasteMenuItemPressed: (id) sender
{    
    [self performSelector:@selector(addNodesFromPasteboard) onThread:[[CCDirector sharedDirector] runningThread] withObject:nil waitUntilDone:NO];
}


// BELOW THIS LINE EVERYTHING IS MOVED TO CCNController


#pragma mark - Events
#pragma mark Touch Events

- (BOOL)ccMagnifyWithEvent:(NSEvent *)event
{
	CCNode *sprite = [[self modelObject] selectedSprite];
	CSModel *model = [self modelObject];
	if (sprite)
	{
		float currentScaleX = [model scaleX];
		float currentScaleY = [model scaleY];
		float newScaleX = currentScaleX + [event magnification];
		float newScaleY = currentScaleY + [event magnification];
		
		// round to nearest hundredth
		newScaleX = roundf(newScaleX * 100)/100.0f;
		newScaleY = roundf(newScaleY * 100)/100.0f;
		
		[[self modelObject] setScaleX:newScaleX];
		[[self modelObject] setScaleY:newScaleY];
        
        return YES;
	}
    
    return NO;
}

- (BOOL)ccRotateWithEvent:(NSEvent *)event
{
	CCNode *sprite = [[self modelObject] selectedSprite];
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
		
		[[self modelObject] setRotation:newRotation];
        
        return YES;
	}
    
    return NO;
}

#pragma mark Mouse Events


- (CCNode *)spriteForEvent:(NSEvent *)event
{
    CCArray *children = [[self curRootNode] children];
    
    NSUInteger childrenCount = [children count];
	for(NSUInteger i = 0; i < childrenCount; ++i)
	{
        // Use reversedIndex to iterate backwards.
        NSUInteger reversedIndex = childrenCount - i - 1;
        
		CCNode *child = [children objectAtIndex:reversedIndex];
		if([child isKindOfClass:[CCNode class]] && [CCNode isEvent:event locatedInNode:child])
		{
			return (CCNode *)child;
		}
	}
	
	return nil;
}

-(BOOL) ccScrollWheel:(NSEvent *)theEvent 
{
    CSMacGLView *glView = (CSMacGLView *)[[CCDirector sharedDirector] openGLView];
    
	// Zoom
	if ( [theEvent modifierFlags] & NSCommandKeyMask )
	{
		glView.zoomFactor += [theEvent deltaY] * glView.zoomSpeed;
		glView.zoomFactor = MAX(glView.zoomFactorMin, MIN(glView.zoomFactor, glView.zoomFactorMax));		
		[glView updateWindow];		
		
		return YES;
	}
	
	// Or Scroll
	[[glView enclosingScrollView] scrollWheel: theEvent];	
	
    return YES;
}

- (BOOL)ccMouseDown:(NSEvent *)event
{
	shouldToggleVisibility_ = NO;
	shouldDragSprite_ = NO;
	
	CSModel *model = [self modelObject];
	
	CCNode *sprite = [self spriteForEvent:event];
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
	CCNode *selectedSprite = [model selectedSprite];
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
	
	CSModel *model = [self modelObject];
	
	// drag the sprite
	if(shouldDragSprite_)
	{
		CCNode *sprite = [model selectedSprite];
		if(sprite)
		{
			// note that we don't change the position value directly
			// the control will observe the change in posX and do it
			// for us
			CGPoint diff = ccpSub(location, prevLocation_);
			CGPoint currentPos = [sprite position];
			CGPoint newPos = ccpAdd(currentPos, diff);
			[[self modelObject] setPosX:newPos.x];
			[[self modelObject] setPosY:newPos.y];
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
		CSModel *model = [self modelObject];
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
	CSModel *model = [self modelObject];
	
	// delete sprites
	switch(keyCode)
	{
		case 0x33: // delete
		case 0x75: // forward delete
			[self performSelectorOnMainThread:@selector(deleteSprite:) withObject:[[self modelObject] selectedSprite] waitUntilDone:NO];
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

// SHIT
- (IBAction)spriteAddButtonClicked:(id)sender{}
- (IBAction)spriteDeleteButtonClicked:(id)sender{}
- (IBAction)openInfoPanel:(id)sender{}
- (IBAction)openSpritesPanel: (id) sender{}
- (IBAction)openMainWindow:(id)sender{}
- (void)registerAsObserver{}
- (void)unregisterForChangeNotification{}
- (void)setInfoPanelView: (NSView *) aView{}

@end

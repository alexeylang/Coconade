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

@implementation CSObjectController

@synthesize modelObject=modelObject_;
@synthesize spriteTableView=spriteTableView_;
@synthesize spriteInfoView = spriteInfoView_;
@synthesize backgroundInfoView = backgroundInfoView_;
@synthesize projectFilename = projectFilename_;

#pragma mark Init / DeInit

- (void)awakeFromNib
{
    // OK
    [[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority: NSIntegerMin];
	[[CCEventDispatcher sharedDispatcher] addKeyboardDelegate:self priority: NSIntegerMin];
    [[CCEventDispatcher sharedDispatcher] addGestureDelegate:self priority: NSIntegerMin];
	
	// SHIT
    {
	[infoPanel_ setBecomesKeyOnlyIfNeeded: YES];
	[spritesPanel_ setBecomesKeyOnlyIfNeeded: YES];
    }
    //< SHIT
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    // OK
    [[CCEventDispatcher sharedDispatcher] removeMouseDelegate:self];
    [[CCEventDispatcher sharedDispatcher] removeKeyboardDelegate:self];
    [[CCEventDispatcher sharedDispatcher] removeGestureDelegate:self];
    
	self.projectFilename = nil;
	self.spriteInfoView = nil;
	self.backgroundInfoView = nil;
	
	[super dealloc];
}

#pragma mark Values Observer


// SHIT
- (void)registerAsObserver
{	
	[modelObject_ addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"posX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"posY" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"posZ" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"anchorX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"anchorY" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"scaleX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"scaleY" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"flipX" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"flipY" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"opacity" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"color" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"relativeAnchor" options:NSKeyValueObservingOptionNew context:NULL];
	[modelObject_ addObserver:self forKeyPath:@"rotation" options:NSKeyValueObservingOptionNew context:NULL];
}

// SHIT
- (void)unregisterForChangeNotification
{
//	[modelObject_ removeObserver:self forKeyPath:@"name"];
}

// SHIT
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	DebugLog(@"keyPath  = %@", keyPath);
    CCNode *sprite = [modelObject_ selectedSprite];
    CCSprite *realySprite = nil;
    if ([sprite isKindOfClass: [CCSprite class]])
    {
        realySprite = (CCSprite *)sprite;
    }
	
	if( [keyPath isEqualToString:@"name"] )
	{
		if(sprite)
		{
			NSString *currentName = [sprite name];
			NSString *newName = [modelObject_ name];
			if( ![currentName isEqualToString:newName] )
			{
				[sprite setUniqueName:newName];
				[nameField_ setStringValue:[sprite name]];
			}
		}
	}
	else if( [keyPath isEqualToString:@"posX"] )
	{
		if(sprite)
		{
			CGPoint currentPos = [sprite position];
			currentPos.x = [modelObject_ posX];
			[sprite setPosition:currentPos];
		}

	}
	else if( [keyPath isEqualToString:@"posY"] )
	{
		if(sprite)
		{
			CGPoint currentPos = [sprite position];
			currentPos.y = [modelObject_ posY];
			[sprite setPosition:currentPos];
		}

	}
	else if( [keyPath isEqualToString:@"posZ"] )
	{
		if(sprite)
		{
			CGFloat currentZ = [sprite zOrder];
			currentZ = [modelObject_ posZ];
			[[sprite parent] reorderChild: sprite z: currentZ ];
		}
	}
	else if( [keyPath isEqualToString:@"anchorX"] )
	{
		if(sprite)
		{
			CGPoint currentAnchor = [sprite anchorPoint];
			currentAnchor.x = [modelObject_ anchorX];
			[sprite setAnchorPoint:currentAnchor];
		}
	}
	else if( [keyPath isEqualToString:@"anchorY"] )
	{
		if(sprite)
		{
			CGPoint currentAnchor = [sprite anchorPoint];
			currentAnchor.y = [modelObject_ anchorY];
			[sprite setAnchorPoint:currentAnchor];
		}		
	}
	else if( [keyPath isEqualToString:@"scaleX"] )
	{
		if(sprite)
		{
			[sprite setScaleX:[modelObject_ scaleX]];
		}
	}
	else if( [keyPath isEqualToString:@"scaleY"] )
	{
		if(sprite)
		{
			[sprite setScaleY:[modelObject_ scaleY]];
		}
	}	
	else if( [keyPath isEqualToString:@"flipX"] )
	{
		if(sprite)
		{
			NSInteger state = [modelObject_ flipX];
			if(state == NSOnState)
			{
                
				[realySprite setFlipX:YES];
			}
			else
			{
				[realySprite setFlipX:NO];
			}
		}
	}
	else if( [keyPath isEqualToString:@"flipY"] )
	{
		if(sprite)
		{
			NSInteger state = [modelObject_ flipY];
			if(state == NSOnState)
			{
				[realySprite setFlipY:YES];
			}
			else
			{
				[realySprite setFlipY:NO];
			}
		}
	}
	else if( [keyPath isEqualToString:@"opacity"] )
	{
		if(sprite)
		{
			[realySprite setOpacity:[modelObject_ opacity]];
		}

	}
	else if( [keyPath isEqualToString:@"color"] )
	{
		// grab rgba values
		NSColor *color = [[modelObject_ color] colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		
		CGFloat r, g, b, a;			
		a = [color alphaComponent];
		r = [color redComponent] * a * 255;
		g = [color greenComponent] * a * 255;
		b = [color blueComponent] * a * 255;
		
		CCNode *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			[realySprite setColor:ccc3(r, g, b)];
		}
	}
	else if( [keyPath isEqualToString:@"relativeAnchor"] )
	{
		CCNode *sprite = [modelObject_ selectedSprite];
		if(sprite)
		{
			NSInteger state = [modelObject_ relativeAnchor];
			if(state == NSOnState)
			{
				[sprite setIsRelativeAnchorPoint:YES];
			}
			else
			{
				[sprite setIsRelativeAnchorPoint:NO];
			}
		}

	}
	else if( [keyPath isEqualToString:@"rotation"] )
	{
		
		if(sprite)
		{
			[sprite setRotation:[modelObject_ rotation]];
		}
	}
	
	[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark Sprites

// TODO: move, rename to allowedTextureFiles,
// Use for "Add CCSPrite" menuItem.
- (NSArray *) allowedFileTypes
{
	return [NSArray arrayWithObjects:@"png", @"gif", @"jpg", @"jpeg", @"tif", @"tiff", @"bmp", @"ccz", @"pvr", nil];
}

// TODO: move, refactor to filterFiles:withAllowedFileTypes:
- (NSArray *) allowedFilesWithFiles: (NSArray *) files
{
	if (!files)
		return nil;
	
	NSMutableArray *allowedFiles = [NSMutableArray arrayWithCapacity:[files count]];
	
	for (NSString *file in files)
	{
		if ( ![file isKindOfClass:[NSString class]] )
			continue;
		
		NSString *curFileExtension = [file pathExtension];
		
		for (NSString *fileType in [self allowedFileTypes] )
		{
			if ([fileType isEqualToString: curFileExtension])
			{
				[allowedFiles addObject:file];
				break;
			}
		}
	}
	
	return allowedFiles;
}

// adds sprites on cocos thread
// executes immediatly if curThread == cocosThread
// TODO: move, probably refactor, currently used for drag n drop & adding sprites
// from "Add Sprite" menu.
- (void)addSpritesWithFilesSafely:(NSArray *)files
{
	NSThread *cocosThread = [[CCDirector sharedDirector] runningThread] ;
	
	[self performSelector:@selector(addSpritesWithFiles:)
				 onThread:cocosThread
			   withObject:files 
			waitUntilDone:([[NSThread currentThread] isEqualTo:cocosThread])];
}

// Should be used from CCNModel
- (CCNode *) curRootNode
{
    CCNScene *scene = (CCNScene *) [[CCDirector sharedDirector] runningScene ];
    return scene.targetNode;
}

// TODO: think, maybe should be moved to CCNModel
- (void) setCurRootNode: (CCNode *) aNode
{
    CCNScene *scene = (CCNScene *) [[CCDirector sharedDirector] runningScene ];
    scene.targetNode = aNode;
}

// SHIT
// adds new sprites as children if needed - should be called on Cocos2D Thread
- (void) updateSpritesFromModel
{
	CSModel *model = self.modelObject;
	NSMutableArray *spriteArray = [model spriteArray];
	
	@synchronized(spriteArray)
	{
		for(CCNode *sprite in spriteArray)
		{
			if( ![sprite parent] )
			{
				[[self curRootNode] addChild:sprite z: [sprite zOrder]];
				[model setSelectedSprite:sprite];
			}
		}
	}
}

// TODO: refactor and move some part of it to CCNController
// designated sprites adding method
- (void)addSpritesWithFiles:(NSArray *)files
{
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	for(NSString *filename in files)
	{		
        // TODO: creating sprite from file
        // {
		// create key for the sprite
		NSString *originalName = [filename lastPathComponent];
		NSString *name = [NSString stringWithString:originalName];
		
		CCNode *sprite = [CCSprite spriteWithFile:filename];
		[sprite setUniqueName:name];
        //} < TODO
		
		@synchronized( [modelObject_ spriteArray] )
		{
			[[modelObject_ spriteArray] addObject:sprite];
		}
		
		[self updateSpritesFromModel];
	}
	
	// reload the table
	[spriteTableView_ reloadData];
}

// SHIT
- (void)deleteAllSprites
{
	// deselect everything
	[modelObject_ setSelectedSprite:nil];
		
	// remove all sprites from main layer
	for (CCNode * sprite in [modelObject_ spriteArray])
	{
		// Remove sprite from it's parent if any.
		if( [sprite parent] )
			[[sprite parent] removeChild:sprite cleanup:YES];
	}
		
	// remove all sprites from the dictionary
	@synchronized([modelObject_ spriteArray])
	{
		[[modelObject_ spriteArray] removeAllObjects];
	}	
}

// SHIT, but same functionality should be in CCNController.
- (void)deleteSprite:(CCNode *)sprite
{
	// delete sprite
	if(sprite)
	{
		// deselect sprite 
		[modelObject_ setSelectedSprite:nil];
		[spriteTableView_ deselectAll:nil];
		[spriteTableView_ setDataSource: nil];
		
		// Remove sprite from it's parent if any.
		if( [sprite parent] )
			[[sprite parent] removeChild:sprite cleanup:YES];
		
		// remove the sprite from the dictionary
		@synchronized([modelObject_ spriteArray])
		{
			[[modelObject_ spriteArray] removeObject:sprite];
		}
	}	
}

#pragma mark Notifications

- (void) setInfoPanelView: (NSView *) aView
{
	//CGRect frame = [infoPanel_ frame];
	//frame.size = [aView frame].size;
	[infoPanel_ setContentView:aView];
	//[infoPanel_ setFrame: frame display: YES];
}

#pragma mark Save / Load

// TODO: move save/load to model, save all rootNodes.
- (NSDictionary *)dictionaryFromLayerForBaseDirPath: (NSString *) baseDirPath
{
    
    // Just save current root node.
    // Ignore baseDirPath.
    
	return [[self curRootNode] dictionaryRepresentation];
}

// TODO: move save/load to model, save all rootNodes.
- (void)saveProjectToFile:(NSString *)filename
{
	NSDictionary *dict = [self dictionaryFromLayerForBaseDirPath:[filename stringByDeletingLastPathComponent]];
	[dict writeToFile:filename atomically:YES];
	
	// Rembember filename for fast save next time.
	self.projectFilename = filename;
}

#pragma mark Loading CSD Files

// TODO: move save/load to model, save all rootNodes.
- (void)loadProjectFromDictionarySafely:(NSDictionary *)dict
{
	NSThread *cocosThread = [[CCDirector sharedDirector] runningThread] ;
	
	[self performSelector:@selector(loadProjectFromDictionary:)
				 onThread:cocosThread
			   withObject:dict
			waitUntilDone:([[NSThread currentThread] isEqualTo:cocosThread])];
}

// TODO: move save/load to model, save all rootNodes.
- (void)loadProjectFromDictionary:(NSDictionary *)dict
{
    if (![dict count])
        return;
    
    // TODO: load content in try block, if any exception gets thrown - don't
    // update anything - just show loading error alert and keep old scene.
    
    // Clear all existing sprites first.
    [self deleteAllSprites];
    [[self modelObject] setSelectedSprite: nil];
    
    // Load background layer without alloc.
    CCNode *rootNode = [NSObject objectWithDictionaryRepresentation:dict];
    [self setCurRootNode: rootNode];
    
    // [Rusty: Cocoshop] Change workspace size from bgLayer.contentSize.
    CGSize workspaceSize = rootNode.contentSize;
    [(CSMacGLView *)[[CCDirector sharedDirector] openGLView] setWorkspaceSize: workspaceSize];
    [(CCNScene *)[[CCDirector sharedDirector] runningScene] updateForScreenReshapeSafely: nil];
    
    // [Rusty: Cocoshop] Readd new sprites to model.
    @synchronized ([[self modelObject] spriteArray])
    {
        for (CCSprite *child in [rootNode children])
        {
            [[[self modelObject] spriteArray] addObject:child];
        }
    }
    
    [self updateSpritesFromModel];
}

#pragma mark IBActions - Windows

// SHIT
- (IBAction)openInfoPanel:(id)sender
{
	[infoPanel_ makeKeyAndOrderFront:nil];
	[infoPanel_ setLevel:[[[[CCDirector sharedDirector] openGLView] window] level]+1];
}

// SHIT
- (IBAction) openSpritesPanel: (id) sender
{
	[spritesPanel_ makeKeyAndOrderFront: nil];
	[spritesPanel_ setLevel:[[[[CCDirector sharedDirector] openGLView] window] level]+1];
}

// SHIT
- (IBAction)openMainWindow:(id)sender
{
	[[[[CCDirector sharedDirector] openGLView] window] makeKeyAndOrderFront:nil];
	[infoPanel_ setLevel:NSNormalWindowLevel];
	[spritesPanel_ setLevel:NSNormalWindowLevel];
}

#pragma mark IBActions - Save/Load

// TODO: probably should be a part of something like CCNWindowController
// if we're opened a file - we can revert to saved and save without save as
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

// TODO: move save/load to model, save all rootNodes.
- (IBAction)saveProject:(id)sender
{
	if (! self.projectFilename) 
	{
		[self saveProjectAs: sender];
		return;
	}
	
	[self saveProjectToFile:self.projectFilename];
}

// TODO: move save/load to model, save all rootNodes.
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
			[self saveProjectToFile:file];
		}
	}];
}

// TODO: move to CCNController, remove unneded code, creating new project
// should be simple - remove one model, load another - that's it.
- (IBAction)newProject:(id)sender
{
	// remove all sprites
	[self deleteAllSprites];
	
	// reset background
	modelObject_.color = [NSColor colorWithDeviceRed:0 green:0 blue:0 alpha:0];
	modelObject_.opacity = 0;
    
    // Set stageSize.
    [(CSMacGLView *) [[CCDirector sharedDirector] openGLView] setWorkspaceSize:CGSizeMake(800, 600)];
    [(CCNScene *)[[CCDirector sharedDirector] runningScene] updateForScreenReshapeSafely: nil];
	
	// reset filename
	self.projectFilename = nil;
	
	// reload the table
	[spriteTableView_ reloadData];
	
}

// TODO: move to CCNController or CCNWindowController
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
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:file];
			
			if(dict)
			{
				[self loadProjectFromDictionarySafely:dict];
				self.projectFilename = file;
			}
		}
	}];
}

// TODO: move to CCNController or ( CCNController & CCNWindowController )
- (IBAction)revertToSavedProject:(id)sender
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:self.projectFilename];
	[self loadProjectFromDictionarySafely:dict];
}

#pragma mark IBActions - Sprites

// TODO: move to CCNController or ( CCNController & CCNWindowController )
- (IBAction)addSprite:(id)sender
{
	// allowed file types
	NSArray *allowedTypes = [self allowedFileTypes];
	
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
			
			[self addSpritesWithFilesSafely: files];
		}
	}];
}

// SHIT
- (IBAction)spriteAddButtonClicked:(id)sender
{
	[self addSprite:sender];
}

// TODO: move to CCNController or ( CCNController & CCNWindowController )
- (IBAction)spriteDeleteButtonClicked:(id)sender
{
	NSInteger index =  [spriteTableView_ selectedRow];
	NSArray *values = [modelObject_ spriteArray];
	
	if ( values && (index >= 0) && (index < [values count]) )
	{
		CCNode *sprite = [values objectAtIndex:index];
		[self deleteSprite:sprite];
	}
}

#pragma mark IBActions - Zoom

// TODO: move to CCNWindowController or CCNController
- (IBAction)resetZoom:(id)sender
{
	[(CSMacGLView *)[[CCDirector sharedDirector] openGLView] resetZoom];
}

#pragma mark IBActions - Menus
// TODO: move to CCNWindowController or CCNController
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

@end

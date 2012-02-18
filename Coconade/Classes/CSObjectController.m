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

- (IBAction) pasteMenuItemPressed: (id) sender
{    
    [self performBlockOnCocosThread:^()
     {
         [self.ccnController addNodesFromPasteboard];
     }];
}


// BELOW THIS LINE EVERYTHING IS MOVED TO CCNController


#pragma mark - Events
#pragma mark Touch Events

- (BOOL)ccMagnifyWithEvent:(NSEvent *)event
{
	return [self.ccnController ccMagnifyWithEvent:event];
}

- (BOOL)ccRotateWithEvent:(NSEvent *)event
{
	return [self.ccnController ccRotateWithEvent:event];
}

#pragma mark Mouse Events

-(BOOL) ccScrollWheel:(NSEvent *)theEvent 
{
    return [self.ccnController ccScrollWheel: theEvent];
}

- (BOOL)ccMouseDown:(NSEvent *)event
{
	return [self.ccnController ccMouseDown: event];
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
	return [self.ccnController ccMouseDragged: event];
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	return [self.ccnController ccMouseUp: event];
}

#pragma mark Keyboard Events

- (BOOL)ccKeyDown:(NSEvent *)event
{
    return [self.ccnController ccKeyDown: event];
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

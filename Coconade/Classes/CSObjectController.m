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
#import "cocoshopAppDelegate.h"
#import "DebugLog.h"
#import "NSString+RelativePath.h"
#import "CCNScene.h"
#import "CCNode+Helpers.h"
#import "CCEventDispatcher+Gestures.h"
#import "NSObject+Blocks.h"

@implementation CSObjectController

@synthesize ccnController = _ccnController;
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

#pragma mark IBActions

// TODO: move to CCNWindowController
- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	DebugLog(@"fuck");
	
	// "Save"
	if ([menuItem action] == @selector(saveProject:))
		return YES;
	
	// "Revert to Saved"
	if ([menuItem action] == @selector(revertToSavedProject:))
	{
		return [self.ccnController canRevertToSavedProject];
	}
	
	// "Cut"
	if ([menuItem action] == @selector(cutMenuItemPressed:))
	{
		return [self.ccnController canCutSelectedToPasteboard];
	}
	
	// "Copy"
	if ([menuItem action] == @selector(copyMenuItemPressed:))
	{
		return [self.ccnController canCopySelectedToPasteboard];
	}
	
	// "Paste"
	if ([menuItem action] == @selector(pasteMenuItemPressed:))
	{
		return [self.ccnController canPasteFromPasteboard];
	}
	
	// "Delete"
	if ([menuItem action] == @selector(deleteMenuItemPressed:))
	{
        return [self.ccnController canDeleteSelected];
	}
	
	// "Show Borders"- using ivar, because NSOnState doesn't set right in IB
    CCNScene *scene = (CCNScene *)[[CCDirector sharedDirector] runningScene];
	showBordersMenuItem_.state = (scene.showBorders) ? NSOnState : NSOffState;
    
    // TODO: add showCheckerboard.
	
	return YES;
}

// TODO: move to CCNWindowController
- (IBAction)saveProject:(id)sender
{
	if (! [self.ccnController canSaveProject]) 
	{
		[self saveProjectAs: sender];
		return;
	}
	
	[self performBlockOnCocosThread: ^()
     {
         [self.ccnController saveProject];
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
                 [self.ccnController saveProjectToFile: file]; //< TODO: use CCNController method instead.
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
                     [self.ccnController loadProject: file];
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
         [self.ccnController revertToSavedProject];
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
	[(CCNMacGLView *)[[CCDirector sharedDirector] openGLView] resetZoom];
}

#pragma mark IBActions - Menus

// TODO: move to CCNWindowController
- (IBAction) showBordersMenuItemPressed: (id) sender
{
    CCNScene *scene = (CCNScene *)[[CCDirector sharedDirector] runningScene];
	scene.showBorders = ([sender state] == NSOffState);
}

// TODO: move to CCNWindowController
- (IBAction) deleteMenuItemPressed: (id) sender
{
    [self performBlockOnCocosThread:^()
     {
         [self.ccnController deleteSelected];
     }];
}

// TODO: move to CCNWindowController
- (IBAction) cutMenuItemPressed: (id) sender
{
	[self performBlockOnCocosThread:^()
     {
         [self.ccnController cutSelectedToPasteboard];
     }];
}

// TODO: move to CCNWindowController
- (IBAction) copyMenuItemPressed: (id) sender
{
    [self performBlockOnCocosThread:^()
     {
         [self.ccnController copySelectedToPasteboard];
     }];
}

// TODO: move to CCNWindowController
- (IBAction) pasteMenuItemPressed: (id) sender
{    
    [self performBlockOnCocosThread:^()
     {
         [self.ccnController pasteFromPasteboard];
     }];
}

#pragma mark Shit to remove with Xib
// Note: that ugly shit is still here, cause it will crash in loading xib
// if we remove them now.
//
// Xib must die!!!!
// VIVA LA REVOLUTION!!!

- (id) model
{
    return [[NSClassFromString(@"CSModel") new] autorelease];
}
- (IBAction)spriteAddButtonClicked:(id)sender{}
- (IBAction)spriteDeleteButtonClicked:(id)sender{}
- (IBAction)openInfoPanel:(id)sender{}
- (IBAction)openSpritesPanel: (id) sender{}
- (IBAction)openMainWindow:(id)sender{}
- (void)registerAsObserver{}
- (void)unregisterForChangeNotification{}
- (void)setInfoPanelView: (NSView *) aView{}

@end

@interface CSModel : NSObject 
{
}
@end

@implementation CSModel
- (id)valueForUndefinedKey:(NSString *)key
{
    return nil;
}

@end

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

#import "cocoshopAppDelegate.h"
#import "CSObjectController.h"
#import "DebugLog.h"
#import "CCNScene.h"
#import "NSObject+Blocks.h"
#import "CCNModel.h"
#import "CCNWindowController.h"
#import "CCNWindow.h"


@implementation cocoshopAppDelegate

@synthesize windowController = _windowController;
@synthesize controller = _controller;
@synthesize appIsRunning = _appIsRunning; 
@synthesize filenameToOpen = _filenameToOpen;

// Can be called before -applicationDidFinishLaunching: if app is open by double-clicking csd file.
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if ([[filename pathExtension] isEqualToString: @"csd"])
	{
		DebugLog(@"Will Open File: %@", filename);
		self.filenameToOpen = filename;
		
		if (self.appIsRunning)
		{
			[self performBlockOnCocosThread:^()
             {
                 [self.controller.ccnController loadProject: self.filenameToOpen];             
                 self.filenameToOpen = nil;
             }];
		}
		return YES;
	}
	
	return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Prepare window & window controller.
    NSRect frame = [[NSScreen mainScreen] visibleFrame];
    NSUInteger styleMask = NSResizableWindowMask | NSClosableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask;
    NSRect contentRect = [NSWindow contentRectForFrameRect:frame styleMask:styleMask];
    CCNWindow *window = [[[CCNWindow alloc] initWithContentRect: contentRect 
                                                      styleMask: styleMask
                                                        backing: NSBackingStoreBuffered 
                                                          defer: NO] autorelease];
    self.windowController = [[CCNWindowController alloc] initWithWindow:window];
    [self.windowController prepareWindow];
    
    // Prepare CCDirector.
	CCDirectorMac *director = (CCDirectorMac *) [CCDirector sharedDirector];	
	[director setDisplayFPS:NO];	
	[director setOpenGLView:self.windowController.glView];
	[director setResizeMode:kCCDirectorResize_NoScale]; //< We use NoScale with own Projection for NSScrollView
	[director setProjection: kCCDirectorProjectionCustom];
	[director setProjectionDelegate: self.windowController.glView];
	CGSize s = [[CCDirector sharedDirector] winSize];
    [self.windowController.glView setWorkspaceSize: s];
    
    // Prepare controller & run scene.
    self.controller.ccnController = [CCNController controllerWithGLView: self.windowController.glView];
    [director runWithScene: self.controller.ccnController.scene];
	
	self.appIsRunning = YES;

    // Open file if needed ( self.filenameToOpen can be set in -application:openFile ).
	if (self.filenameToOpen)
	{
        [self performBlockOnCocosThread:^()
         {
             [self.controller.ccnController loadProject: self.filenameToOpen];             
             self.filenameToOpen = nil;
         }];       
	}
    
    [self.windowController.window makeKeyAndOrderFront: NSApp];
}

- (void)applicationWillUpdate:(NSNotification *)aNotification
{
	[[NSColorPanel sharedColorPanel] setLevel:[[[[CCDirector sharedDirector] openGLView] window] level]+1];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication
{
	return YES;
}

- (void)dealloc
{
	[[CCDirector sharedDirector] release];
    self.windowController = nil;
    
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
	
	[(CCNMacGLView *)[director openGLView] updateView];
}

@end

//
//  CCNWindow.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CoconadeAppDelegate.h"
#import "CCNController.h"
#import "DebugLog.h"
#import "CCNScene.h"
#import "NSObject+Blocks.h"
#import "CCNModel.h"
#import "CCNWindowController.h"
#import "CCNWindow.h"


@implementation CoconadeAppDelegate

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
                 [self.controller loadProject: self.filenameToOpen];             
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
    self.controller = [CCNController controllerWithGLView: self.windowController.glView];
    [director runWithScene: self.controller.scene];
	
	self.appIsRunning = YES;

    // Open file if needed ( self.filenameToOpen can be set in -application:openFile ).
	if (self.filenameToOpen)
	{
        [self performBlockOnCocosThread:^()
         {
             [self.controller loadProject: self.filenameToOpen];             
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
    self.controller = nil;
    self.filenameToOpen = nil;
    
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac *)[CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
	
	[(CCNMacGLView *)[director openGLView] updateView];
}

@end

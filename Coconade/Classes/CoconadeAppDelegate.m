//
//  CCNWindow.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CoconadeAppDelegate.h"
#import "CCNWorkspaceController.h"
#import "DebugLog.h"
#import "CCNScene.h"
#import "NSObject+Blocks.h"
#import "CCNModel.h"
#import "CCNWindowController.h"
#import "CCNWindow.h"

// TODO: rename to CCNAppDelegate to match naming style.
@implementation CoconadeAppDelegate

@synthesize windowController = _windowController;
@synthesize appIsRunning = _appIsRunning; 
@synthesize filenameToOpen = _filenameToOpen;

// Can be called before -applicationDidFinishLaunching: if app is open by double-clicking ccn file.
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if ([[filename pathExtension] isEqualToString: kCCNWindowControllerCoconadeProjectFileExtension])
	{
		DebugLog(@"Will Open File: %@", filename);
		self.filenameToOpen = filename;
		
		if (self.appIsRunning)
		{
			[self performBlockOnCocosThread:^()
             {
                 [self.windowController.workspaceController loadProject: self.filenameToOpen];             
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
    CCNMacGLView *glView = [[[CCNMacGLView alloc] init] autorelease];
    CCNWorkspaceController *workspaceController = [CCNWorkspaceController controllerWithGLView:glView];
    self.windowController = [CCNWindowController controllerWithWindow:window 
                                                  workspaceController:workspaceController];
    
    // Prepare CCDirector.
	CCDirectorMac *director = (CCDirectorMac *) [CCDirector sharedDirector];	
	[director setDisplayFPS:NO];	
	[director setOpenGLView:glView];
	[director setResizeMode:kCCDirectorResize_NoScale]; //< We use NoScale with own Projection for NSScrollView
	[director setProjection: kCCDirectorProjectionCustom];
	[director setProjectionDelegate: glView];
	CGSize s = [[CCDirector sharedDirector] winSize];
    [glView setWorkspaceSize: s];
    
    // Prepare controller & run scene.
    [director runWithScene: workspaceController.scene];
	
	self.appIsRunning = YES;

    // Open file if needed ( self.filenameToOpen can be set in -application:openFile ).
	if (self.filenameToOpen)
	{
        [self performBlockOnCocosThread:^()
         {
             [workspaceController loadProject: self.filenameToOpen];             
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
    self.filenameToOpen = nil;
    
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

// TODO: move to CCNWindowController? At least it shouldn't be IBAction anymore.
- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac *)[CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
	
	[(CCNMacGLView *)[director openGLView] updateView];
}

@end

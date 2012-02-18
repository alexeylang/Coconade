/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
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
<<<<<<< HEAD
#import "CCNScene.h"
#import "CSModel.h"
#import "NSObject+Blocks.h"
#import "CCNModel.h"
=======
#import "CCNWindowController.h"
#import "CCNWindow.h"

>>>>>>> rewrite-for-coconade

@implementation cocoshopAppDelegate

<<<<<<< HEAD
// Can be called before -applicationDidFinishLaunching: if app is open by double-clicking csd file.
=======
@synthesize windowController = _windowController;
@synthesize controller = _controller;
@synthesize appIsRunning = _appIsRunning; 
@synthesize filenameToOpen = _filenameToOpen;

>>>>>>> rewrite-for-coconade
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if ([[filename pathExtension] isEqualToString: @"csd"])
	{
		DebugLog(@"Will Open File: %@", filename);
		self.filenameToOpen = filename;
		
		if (self.appIsRunning)
		{
<<<<<<< HEAD
			[self performBlockOnCocosThread:^()
             {
                 CCNModel *newModel = [CCNModel modelFromFile: self.filenameToOpen ];
                 if (!newModel)
                 {
                     [self performBlockOnMainThread:^()
                      {
                          [[NSAlert alertWithMessageText: @"Can't open file." 
                                           defaultButton: @"OK"
                                         alternateButton: nil
                                             otherButton: nil 
                               informativeTextWithFormat: @"Can't create CCNModel from %@", self.filenameToOpen] runModal];
                      }];
                 }
                 else
                 {
                     controller_.ccnController.model = newModel;
                 }
                 
                 self.filenameToOpen = nil;
             }];       

=======
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: filename];
			[self.controller.mainLayer loadProjectFromDictionarySafely: dict];
			self.controller.projectFilename = self.filenameToOpen;
			self.filenameToOpen = nil;
>>>>>>> rewrite-for-coconade
		}
		return YES;
	}
	
	return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSRect frame = [[NSScreen mainScreen] visibleFrame];
    NSUInteger styleMask = NSResizableWindowMask | NSClosableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask;
    NSRect contentRect = [NSWindow contentRectForFrameRect:frame styleMask:styleMask];
    CCNWindow *window = [[[CCNWindow alloc] initWithContentRect: contentRect 
                                                      styleMask: styleMask
                                                        backing: NSBackingStoreBuffered 
                                                          defer: NO] autorelease];
    self.windowController = [[CCNWindowController alloc] initWithWindow:window];
    [self.windowController prepareWindow];
    
	CCDirectorMac *director = (CCDirectorMac *) [CCDirector sharedDirector];
	
	[director setDisplayFPS:NO];
	
	// register for receiving filenames
	[self.windowController.glView registerForDraggedTypes:[NSArray arrayWithObjects:  NSFilenamesPboardType, nil]];
	[director setOpenGLView:self.windowController.glView];
	
	// We use NoScale with own Projection for NSScrollView
	[director setResizeMode:kCCDirectorResize_NoScale];
	[director setProjection: kCCDirectorProjectionCustom];
	[director setProjectionDelegate: self.windowController.glView];
	
<<<<<<< HEAD
    // Prepare scene.
	CCNScene *scene = [CCNScene node];
    
    // Show Borders if needed (On first run)
    NSNumber *showBordersState = [[NSUserDefaults standardUserDefaults] valueForKey:@"CSMainLayerShowBorders"];
    if (!showBordersState)
        scene.showBorders = YES;
    else 
        scene.showBorders = [showBordersState intValue];
    
    CGSize s = [[CCDirector sharedDirector] winSize];
    [glView_ setWorkspaceSize: s];
    
	CCLayer *defaultRootNode = [CCLayer node];    
	scene.targetNode = defaultRootNode;
	[director runWithScene:scene];
	
	self.appIsRunning = YES;

    // Open file if needed ( self.filenameToOpen can be set in -application:openFile ).
	if (self.filenameToOpen)
	{
        [self performBlockOnCocosThread:^()
         {
             CCNModel *newModel = [CCNModel modelFromFile: self.filenameToOpen ];
             if (!newModel)
             {
                 [self performBlockOnMainThread:^()
                  {
                      [[NSAlert alertWithMessageText: @"Can't open file." 
                                       defaultButton: @"OK"
                                     alternateButton: nil
                                         otherButton: nil 
                           informativeTextWithFormat: @"Can't create CCNModel from %@", self.filenameToOpen] runModal];
                  }];
             }
             else
             {
                 controller_.ccnController.model = newModel;
             }
             
             self.filenameToOpen = nil;
         }];       
	}//< if self.filenameToOpen
=======
	CCScene *scene = [CCScene node];
	CSMainLayer *layer = [CSMainLayer nodeWithController:self.controller];
	[self.controller setMainLayer:layer];
	[scene addChild:layer];
	[director runWithScene:scene];
	
	self.appIsRunning = YES;
    
    [self.windowController.window makeKeyAndOrderFront: NSApp];
>>>>>>> rewrite-for-coconade
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
	
<<<<<<< HEAD
=======
	[self.controller.mainLayer updateForScreenReshapeSafely: nil ];
>>>>>>> rewrite-for-coconade
	[(CSMacGLView *)[director openGLView] updateWindow];
}

@end

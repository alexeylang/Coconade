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
#import "CSMainLayer.h"
#import "DebugLog.h"

@implementation cocoshopAppDelegate
@synthesize window=window_, glView=glView_, controller=controller_;
@synthesize appIsRunning = appIsRunning_, filenameToOpen = filenameToOpen_;


- (void) prepareWindow
{
    NSRect frame = NSMakeRect(200, 200, 500, 500);
    NSUInteger styleMask = NSResizableWindowMask | NSClosableWindowMask | NSTitledWindowMask | NSMiniaturizableWindowMask;
    NSRect contentRect = [NSWindow contentRectForFrameRect:frame styleMask:styleMask];
    
    self.window  = [[[NSWindow alloc] initWithContentRect: contentRect 
                                                styleMask: styleMask
                                                  backing: NSBackingStoreBuffered 
                                                    defer: NO] autorelease];
    self.window.level = NSNormalWindowLevel;
    self.window.backgroundColor = [NSColor whiteColor];
    self.window.hasShadow = YES;
    //self.window.contentView = [[[NSView alloc] initWithFrame:frame] autorelease];
    
    contentRect.origin = CGPointZero;
    self.glView = [[[CSMacGLView alloc] initWithFrame:contentRect] autorelease];
    self.window.contentView = self.glView;
    //[self.window.contentView addSubview:self.glView];
    
    [self.window makeKeyAndOrderFront: NSApp];
    
}

// called before applicationDidFinishLaunching: if app is open by double-clicking
// csd file
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	if ([[filename pathExtension] isEqualToString: @"csd"])
	{
		DebugLog(@"Will Open File: %@", filename);
		self.filenameToOpen = filename;
		
		if (self.appIsRunning)
		{
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: filename];
			[controller_.mainLayer loadProjectFromDictionarySafely: dict];
			controller_.projectFilename = self.filenameToOpen;
			self.filenameToOpen = nil;
		}
		return YES;
	}
	
	return NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self prepareWindow];
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	
	[director setDisplayFPS:NO];
	
	// register for receiving filenames
	[glView_ registerForDraggedTypes:[NSArray arrayWithObjects:  NSFilenamesPboardType, nil]];
	[director setOpenGLView:glView_];
	
	// We use NoScale with own Projection for NSScrollView
	[director setResizeMode:kCCDirectorResize_NoScale];
	[director setProjection: kCCDirectorProjectionCustom];
	[director setProjectionDelegate: glView_];
	
	// Enable "moving" mouse event. Default no.
	[window_ setAcceptsMouseMovedEvents:NO];
	
	CCScene *scene = [CCScene node];
	CSMainLayer *layer = [CSMainLayer nodeWithController:controller_];
	[controller_ setMainLayer:layer];
	[scene addChild:layer];
	[director runWithScene:scene];
	
	self.appIsRunning = YES;

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
	[window_ release];
	[super dealloc];
}

#pragma mark AppDelegate - IBActions

- (IBAction)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac*) [CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
	
	[ controller_.mainLayer updateForScreenReshapeSafely: nil ];
	[(CSMacGLView *)[director openGLView] updateWindow];
}

@end

//
//  CCNWindow.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "cocos2d.h"
#import "CCNMacGLView.h"


@class CCNWindowController;
@interface CoconadeAppDelegate : NSObject <NSApplicationDelegate>
{
    CCNWindowController *_windowController;
	
	BOOL _appIsRunning;
	NSString *_filenameToOpen;
}

@property (readwrite, retain) CCNWindowController *windowController;
@property (readwrite, copy) NSString *filenameToOpen;
@property (readwrite) BOOL appIsRunning;

- (IBAction)toggleFullScreen:(id)sender;

/** Called before applicationDidFinishLaunching: if app is open by double-clicking csd file */
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;

@end

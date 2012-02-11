/*
 * Coconade
 *
 * Copyright (c) 2012 Alexey Lang
 *
 */

#import "CCNWindowController.h"
#import "CSMacGLView.h"


@implementation CCNWindowController

@synthesize glView = _glView;

- (void) dealloc
{
    self.glView = nil;
    
    [super dealloc];
}

- (void) prepareWindow
{
    // setup window
    self.window.level = NSNormalWindowLevel;
    self.window.backgroundColor = [NSColor whiteColor];
    self.window.hasShadow = YES;
    self.window.acceptsMouseMovedEvents = NO;
    
    // Create and setup glView
    //contentRect.origin = CGPointZero;
    self.glView = [[[CSMacGLView alloc] init] autorelease];
    [self.window.contentView addSubview:self.glView];
    [self.glView awakeFromNib];
    
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:
                           kCCNWindowControllerToolbarIdentifier] autorelease];
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    toolbar.delegate = self;    
    self.window.toolbar = toolbar;
}

@end

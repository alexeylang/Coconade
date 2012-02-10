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
    
    NSToolbar *toolbar = [[NSToolbar new] autorelease];
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:10];
    NSToolbarItem *addSpriteItem = [[NSToolbarItem new] autorelease];
    addSpriteItem.label = @"Add sprite";
    addSpriteItem.paletteLabel = addSpriteItem.label;
    [items addObject: addSpriteItem];
}

@end

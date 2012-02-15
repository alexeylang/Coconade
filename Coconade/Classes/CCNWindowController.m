/*
 * Coconade
 *
 * Copyright (c) 2012 Alexey Lang
 *
 */

#import "CCNWindowController.h"
#import "CSMacGLView.h"

#define kCCNWindowControllerToolbarIdentifier                   @"toolbarIdentifier"

#define kCCNWindowControllerToolbarItemAddSpriteIdentifier      @"toolbarItemAddSpriteIdentifier"
#define kCCNWindowControllerToolbarItemAddSpriteName            @"Add Sprite"
#define kCCNWindowControllerToolbarItemAddSpriteImage           @"Add.tiff"

#define kCCNWindowControllerToolbarItemAddBigImageIdentifier    @"toolbarItemAddBigImageIdentifier"
#define kCCNWindowControllerToolbarItemAddBigImageName          @"Add Big Image"
#define kCCNWindowControllerToolbarItemAddBigImageImage         @"icon1.png"

#define kCCNWindowControllerToolbarItemAddLabelIdentifier       @"toolbarItemAddLabelIdentifier"
#define kCCNWindowControllerToolbarItemAddLabelName             @"Add Label"
#define kCCNWindowControllerToolbarItemAddLabelImage            @"icon3.png"

#define kCCNWindowControllerToolbarItemInfoIdentifier           @"toolbarItemInfoIdentifier"
#define kCCNWindowControllerToolbarItemInfoName                 @"Info"
#define kCCNWindowControllerToolbarItemInfoImage                @"icon4-b.png"

#define kCCNWindowControllerToolbarItemSpritesListIdentifier    @"toolbarItemSpritesListIdentifier"
#define kCCNWindowControllerToolbarItemSpritesListName          @"Sprites List"
#define kCCNWindowControllerToolbarItemSpritesListImage         @"icon7-c.png"

#define kCCNWindowControllerSplitViewLeftViewDefaultWidth       300.0f
#define kCCNWindowControllerSplitViewRightViewDefaultWidth      300.0f

@implementation CCNWindowController

@synthesize glView = _glView;

#pragma mark Init/DeInit

- (void) dealloc
{
    self.glView = nil;
    
    [super dealloc];
}

#pragma mark Prapare Window

- (void) prepareWindow
{
    // Setup window
    self.window.level = NSNormalWindowLevel;
    self.window.backgroundColor = [NSColor whiteColor];
    self.window.hasShadow = YES;
    self.window.acceptsMouseMovedEvents = NO;
    
    // Create and setup glView
    self.glView = [[[CSMacGLView alloc] init] autorelease];
    //[self.window.contentView addSubview:self.glView];
    [self.glView awakeFromNib];
    
    NSSplitView *splitView = [[[NSSplitView alloc] initWithFrame: self.window.frame] autorelease];
    splitView.autoresizesSubviews = YES;
    splitView.dividerStyle = NSSplitViewDividerStylePaneSplitter;
    splitView.delegate = self;
    
    NSTextView *textView1 = [[NSTextView new] autorelease];
    textView1.backgroundColor = [NSColor redColor];
    textView1.frame = CGRectMake(0.0f, 
                                 0.0f, 
                                 splitView.frame.size.width / 3.0f, 
                                 splitView.frame.size.height);
    [splitView addSubview:textView1];
    
    NSView *glViewContainer = [[NSView new] autorelease];
    glViewContainer.frame = CGRectMake(0.0f, 
                                       splitView.frame.size.width / 3.0f, 
                                       splitView.frame.size.width / 3.0f, 
                                       splitView.frame.size.height);
    [glViewContainer addSubview:self.glView];
    glViewContainer.autoresizesSubviews = NO;
    [splitView addSubview:glViewContainer];
    
    NSTextView *textView3 = [[NSTextView new] autorelease];
    textView3.backgroundColor = [NSColor greenColor];
    textView3.frame = CGRectMake(0.0f, 
                                 2.0 * splitView.frame.size.width / 3.0f, 
                                 splitView.frame.size.width / 3.0f, 
                                 splitView.frame.size.height);
    [splitView addSubview:textView3];
    
    [splitView setVertical:YES];
    [splitView adjustSubviews];
    [splitView setNeedsDisplay:YES];
    [self.window.contentView addSubview:splitView];
    
    // Create and setup toolbar
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:
                           kCCNWindowControllerToolbarIdentifier] autorelease];
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    toolbar.delegate = self;    
    self.window.toolbar = toolbar;
}

#pragma mark Toolbar Delegate

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects: 
            kCCNWindowControllerToolbarItemAddSpriteIdentifier,
            kCCNWindowControllerToolbarItemAddBigImageIdentifier,
            kCCNWindowControllerToolbarItemAddLabelIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            kCCNWindowControllerToolbarItemInfoIdentifier,
            kCCNWindowControllerToolbarItemSpritesListIdentifier,
            nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects: 
            kCCNWindowControllerToolbarItemAddSpriteIdentifier,
            kCCNWindowControllerToolbarItemAddBigImageIdentifier,
            kCCNWindowControllerToolbarItemAddLabelIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            kCCNWindowControllerToolbarItemInfoIdentifier,
            kCCNWindowControllerToolbarItemSpritesListIdentifier,
            nil];
}

- (NSToolbarItem *)     toolbar:(NSToolbar *)toolbar
          itemForItemIdentifier:(NSString *)itemIdentifier
      willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier] autorelease];
    
    if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemAddSpriteIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemAddSpriteName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemAddSpriteImage];
    }
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemAddBigImageIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemAddBigImageName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemAddBigImageImage];
    }
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemAddLabelIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemAddLabelName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemAddLabelImage];
    }
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemInfoIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemInfoName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemInfoImage];
    }
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemSpritesListIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemSpritesListName;
        toolbarItem.image = [NSImage imageNamed: kCCNWindowControllerToolbarItemSpritesListImage];
    }
    
    return toolbarItem;
}

#pragma mark SplitView Delegate

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    
}

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view
{
    return NO;
}

@end

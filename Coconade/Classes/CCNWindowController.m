//
//  CCNWindowController.m
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNWindowController.h"
#import "CCNMacGLView.h"
#import "CCNWindow.h"

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

#pragma mark Prepare Window & Subviews

- (void) prepareToolbar
{
    NSToolbar *toolbar = [[[NSToolbar alloc] initWithIdentifier:
                           kCCNWindowControllerToolbarIdentifier] autorelease];
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel;
    toolbar.delegate = self;    
    self.window.toolbar = toolbar;
}

- (void) prepareMainMenu
{
    // Create main menu
    NSMenu *mainMenu = [[[NSMenu alloc] initWithTitle:@"MainMenu"] autorelease];
    
    // Create application menu
    NSMenuItem *appMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: appMenuItem];
    NSMenu *appMenu = [[[NSMenu alloc] init] autorelease];
    [appMenuItem setSubmenu:appMenu];
    
    [appMenu addItemWithTitle: @"About Coconade" 
                       action: @selector(orderFrontStandardAboutPanel:) 
                keyEquivalent: @""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle: @"Preferences…" 
                       action: NULL
                keyEquivalent: @","];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [NSApp setServicesMenu: [[[NSMenu alloc] initWithTitle:@"Services"] autorelease]];
    [appMenu addItemWithTitle: @"Services" 
                       action: NULL
                keyEquivalent: @""].submenu = [NSApp servicesMenu];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle: @"Hide Coconade" 
                       action: @selector(hide:) 
                keyEquivalent: @"h"];
    [[appMenu addItemWithTitle: @"Hide Others" 
                        action: @selector(hideOtherApplications:) 
                 keyEquivalent: @"h"] setKeyEquivalentModifierMask: NSAlternateKeyMask|NSCommandKeyMask];
    [appMenu addItemWithTitle: @"Show All" 
                       action: @selector(unhideAllApplications:) 
                keyEquivalent: @""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle: @"Quit Coconade" 
                       action: @selector(terminate:) 
                keyEquivalent: @"q"];
    
    // Create file menu
    NSMenuItem *fileMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: fileMenuItem];
    NSMenu *fileMenu = [[[NSMenu alloc] initWithTitle:@"File"] autorelease];
    [fileMenuItem setSubmenu:fileMenu];
    
    [fileMenu addItemWithTitle: @"New" 
                        action: NULL 
                 keyEquivalent: @"n"];
    [fileMenu addItemWithTitle: @"Open..." 
                        action: NULL
                 keyEquivalent: @"o"];
    NSMenu *openRecentMenu = [[[NSMenu alloc] initWithTitle:@"Open Recent"] autorelease];
    [openRecentMenu addItemWithTitle: @"Clear Menu" 
                              action:@selector(clearRecentDocuments:) 
                       keyEquivalent:@""];
    [fileMenu addItemWithTitle: @"Open Recent" 
                        action: NULL
                 keyEquivalent: @""].submenu = openRecentMenu;
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle: @"Close" 
                        action: @selector(performClose:) 
                 keyEquivalent: @"w"];
    [fileMenu addItemWithTitle: @"Save" 
                        action: NULL
                 keyEquivalent: @"s"];
    [[fileMenu addItemWithTitle: @"Save As..." 
                         action: NULL
                  keyEquivalent: @"s"] setKeyEquivalentModifierMask: NSShiftKeyMask|NSCommandKeyMask];
    [fileMenu addItemWithTitle: @"Revert to Saved" 
                        action: NULL
                 keyEquivalent: @""];
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [[fileMenu addItemWithTitle: @"Page Setup..." 
                         action: @selector(runPageLayout:)
                  keyEquivalent: @"p"] setKeyEquivalentModifierMask: NSShiftKeyMask|NSCommandKeyMask];  
    [fileMenu addItemWithTitle: @"Print..." 
                        action: @selector(print:)
                 keyEquivalent: @"p"];
     
    // Create edit menu
    NSMenuItem *editMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: editMenuItem];
    NSMenu *editMenu = [[[NSMenu alloc] initWithTitle:@"Edit"] autorelease];
    [editMenuItem setSubmenu:editMenu];
    
    [editMenu addItemWithTitle: @"Cut" 
                        action: NULL 
                 keyEquivalent: @"x"];
    [editMenu addItemWithTitle: @"Copy" 
                        action: NULL 
                 keyEquivalent: @"c"];
    [editMenu addItemWithTitle: @"Paste" 
                        action: NULL 
                 keyEquivalent: @"v"];
    [editMenu addItemWithTitle: @"Delete" 
                        action: NULL 
                 keyEquivalent: [NSString stringWithFormat:@"%c", 0x08]];

    [NSApp setMainMenu:mainMenu];    
}

- (void) prepareWindow
{
    // Setup window
    self.window.level = NSNormalWindowLevel;
    self.window.backgroundColor = [NSColor whiteColor];
    self.window.hasShadow = YES;
    self.window.acceptsMouseMovedEvents = NO;
    
    // Create and setup toolbar
    [self prepareToolbar];
    
    // Create and setup main menu
    [self prepareMainMenu];
    
    // Create and setup splitView & subviews
    NSView *contentView = self.window.contentView;
    NSSplitView *splitView = [[[NSSplitView alloc] initWithFrame: contentView.frame] autorelease];
    splitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable; 
    splitView.dividerStyle = NSSplitViewDividerStyleThin;
    splitView.delegate = self;
    [splitView setVertical:YES];
    
    CGRect leftFrame = CGRectMake(0.0f, 
                                  0.0f, 
                                  kCCNWindowControllerSplitViewLeftViewDefaultWidth, 
                                  splitView.frame.size.height);
    NSView *leftView = [[[NSView alloc] initWithFrame:leftFrame] autorelease];
    [splitView addSubview:leftView];
    
    CGRect centerFrame = CGRectMake(0.0f, 
                                    0.0f, 
                                    splitView.frame.size.width - kCCNWindowControllerSplitViewLeftViewDefaultWidth - 
                                        kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                    splitView.frame.size.height);
    NSScrollView *centerScrollView = [[[NSScrollView alloc] initWithFrame:centerFrame] autorelease];
    centerScrollView.hasHorizontalScroller = YES;
    centerScrollView.hasVerticalScroller = YES;
    self.glView = [[[CCNMacGLView alloc] init] autorelease];
    centerScrollView.documentView = self.glView;
    [splitView addSubview:centerScrollView];
    
    CGRect rightFrame = CGRectMake(splitView.frame.size.width - kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                   0.0f, 
                                   kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                   splitView.frame.size.height);
    NSView *rightView = [[NSView alloc] initWithFrame:rightFrame];
    [splitView addSubview:rightView];
    
    [splitView adjustSubviews];
    [contentView addSubview:splitView];
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

- (void)splitViewWillResizeSubviews:(NSNotification *)notification
{
    CCNWindow *window = (CCNWindow *)self.window;
    [window disableUpdatesUntilFlush];
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    [self.glView updateFrameSize];
}

@end

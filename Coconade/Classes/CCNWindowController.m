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
#import "CCNWorkspaceController.h"
#import "NSObject+Blocks.h"
#import "CCNScene.h"

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

#define kCCNWindowControllerToolbarItemViewIdentifier           @"toolbarItemViewIdentifier"
#define kCCNWindowControllerToolbarItemViewName                 @"View"
#define kCCNWindowControllerToolbarItemViewLeftImage            @"left_panel_icon.png"
#define kCCNWindowControllerToolbarItemViewRightImage           @"right_panel_icon.png"
#define kCCNWindowControllerToolbarItemViewWidth                66.0f
#define kCCNWindowControllerToolbarItemViewHeight               25.0f
#define kCCNWindowControllerToolbarItemViewSegmentWidth         30.0f

#define kCCNWindowControllerMainMenuTitle                       @"MainMenu"
#define kCCNWindowControllerMainMenuAboutCoconadeItemTitle      @"About Coconade"
#define kCCNWindowControllerMainMenuPreferencesItemTitle        @"Preferences…"
#define kCCNWindowControllerMainMenuServicesItemTitle           @"Services"
#define kCCNWindowControllerMainMenuHideCoconadeItemTitle       @"Hide Coconade"
#define kCCNWindowControllerMainMenuHideOthersItemTitle         @"Hide Others"
#define kCCNWindowControllerMainMenuShowAllItemTitle            @"Show All"
#define kCCNWindowControllerMainMenuQuitCoconadeItemTitle       @"Quit Coconade"

#define kCCNWindowControllerFileMenuTitle                       @"File"
#define kCCNWindowControllerFileMenuNewItemTitle                @"New"
#define kCCNWindowControllerFileMenuOpenItemTitle               @"Open..."
#define kCCNWindowControllerFileMenuOpenRecentMenuTitle         @"Open Recent"
#define kCCNWindowControllerOpenRecentMenuClearItemTitle        @"Clear Menu"
#define kCCNWindowControllerFileMenuCloseItemTitle              @"Close"
#define kCCNWindowControllerFileMenuSaveItemTitle               @"Save"
#define kCCNWindowControllerFileMenuSaveAsItemTitle             @"Save As..."
#define kCCNWindowControllerFileMenuRevertSavedItemTitle        @"Revert to Saved"
#define kCCNWindowControllerFileMenuPageSetupItemTitle          @"Page Setup..." 
#define kCCNWindowControllerFileMenuPrintItemTitle              @"Print..."

#define kCCNWindowControllerEditMenuTitle                       @"Edit"
#define kCCNWindowControllerEditMenuCutItemTitle                @"Cut"
#define kCCNWindowControllerEditMenuCopyItemTitle               @"Copy"
#define kCCNWindowControllerEditMenuPasteItemTitle              @"Paste"
#define kCCNWindowControllerEditMenuDeleteItemTitle             @"Delete"

#define kCCNWindowControllerViewMenuTitle                       @"View"
#define kCCNWindowControllerViewMenuShowBordersItemTitle        @"Show Borders"
#define kCCNWindowControllerViewMenuToogleFullScreenItemTitle   @"Toogle Full Screen"
#define kCCNWindowControllerViewMenuResetZoomItemTitle          @"Reset Zoom"

#define kCCNWindowControllerWindowMenuTitle                     @"Window"
#define kCCNWindowControllerWindowMenuMinimizeItemTitle         @"Minimize"
#define kCCNWindowControllerWindowMenuZoomItemTitle             @"Zoom"
#define kCCNWindowControllerWindowMenuBringAllToFrontItemTitle  @"Bring All to Front"

#define kCCNWindowControllerHelpMenuTitle                       @"Help"
#define kCCNWindowControllerHelpMenuCoconadeHelpItemTitle       @"Coconade Help"

#define kCCNWindowControllerSplitViewLeftViewDefaultWidth       300.0f
#define kCCNWindowControllerSplitViewRightViewDefaultWidth      300.0f

#define kCCNWindowControllerSplitViewLeftViewMinWidth           200.0f
#define kCCNWindowControllerSplitViewRightViewMinWidth          200.0f
#define kCCNWindowControllerSplitViewCenterViewMinWidth         200.0f

#define kCCNWindowControllerSplitViewCollapseAnimationDelay     0.4f


@interface CCNWindowController ()

@property (readwrite, retain) NSView *leftView;
@property (readwrite, retain) NSScrollView *centerScrollView;
@property (readwrite, retain) NSView *rightView;

/** Prepare Coconade window - creates and sets up main menu, toolbar, glView, 
 * splitView, scrollView, etc.
 */
- (void) prepareWindow;

/** Animate changing frame for given NSView by using NSAnimationContext and animator object. */
- (void)animateView:(NSView *)view withTargetFrame:(CGRect)frame delay:(NSTimeInterval)delay;

@end


@implementation CCNWindowController

@synthesize workspaceController = _workspaceController;
@synthesize leftView = _leftView;
@synthesize centerScrollView = _centerScrollView;
@synthesize rightView = _rightView;

#pragma mark Init/DeInit

+ (id) controllerWithWindow: (CCNWindow *) window 
        workspaceController: (CCNWorkspaceController *) workspaceController
{
    return [[[self alloc] initWithWindow:window 
                     workspaceController:workspaceController] autorelease];
}

- (id)  initWithWindow: (CCNWindow *) window 
   workspaceController: (CCNWorkspaceController *) workspaceController
{
    if ( (self = [super init]) )
    {
        self.window = window;
        self.workspaceController = workspaceController;
        [self prepareWindow];
    }
    return self;
}

- (void) dealloc
{
    self.workspaceController = nil;
    self.leftView = nil;
    self.centerScrollView = nil;
    self.rightView = nil;
    
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
    NSMenu *mainMenu = [[[NSMenu alloc] initWithTitle:kCCNWindowControllerMainMenuTitle] autorelease];
    
    // Create application menu
    NSMenuItem *appMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: appMenuItem];
    NSMenu *appMenu = [[[NSMenu alloc] init] autorelease];
    [appMenuItem setSubmenu:appMenu];
    
    [appMenu addItemWithTitle: kCCNWindowControllerMainMenuAboutCoconadeItemTitle 
                       action: @selector(orderFrontStandardAboutPanel:) 
                keyEquivalent: @""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle: kCCNWindowControllerMainMenuPreferencesItemTitle 
                       action: NULL
                keyEquivalent: @","];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [NSApp setServicesMenu: [[[NSMenu alloc] initWithTitle:kCCNWindowControllerMainMenuServicesItemTitle] autorelease]];
    [appMenu addItemWithTitle: kCCNWindowControllerMainMenuServicesItemTitle 
                       action: NULL
                keyEquivalent: @""].submenu = [NSApp servicesMenu];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle: kCCNWindowControllerMainMenuHideCoconadeItemTitle 
                       action: @selector(hide:) 
                keyEquivalent: @"h"];
    [[appMenu addItemWithTitle: kCCNWindowControllerMainMenuHideOthersItemTitle 
                        action: @selector(hideOtherApplications:) 
                 keyEquivalent: @"h"] setKeyEquivalentModifierMask: NSAlternateKeyMask|NSCommandKeyMask];
    [appMenu addItemWithTitle: kCCNWindowControllerMainMenuShowAllItemTitle 
                       action: @selector(unhideAllApplications:) 
                keyEquivalent: @""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle: kCCNWindowControllerMainMenuQuitCoconadeItemTitle 
                       action: @selector(terminate:) 
                keyEquivalent: @"q"];
    
    // Create file menu
    NSMenuItem *fileMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: fileMenuItem];
    NSMenu *fileMenu = [[[NSMenu alloc] initWithTitle:kCCNWindowControllerFileMenuTitle] autorelease];
    [fileMenuItem setSubmenu:fileMenu];
    
    [fileMenu addItemWithTitle: kCCNWindowControllerFileMenuNewItemTitle 
                        action: @selector(newProject:) 
                 keyEquivalent: @"n"];
    [fileMenu addItemWithTitle: kCCNWindowControllerFileMenuOpenItemTitle 
                        action: @selector(openProject:)
                 keyEquivalent: @"o"];
    NSMenu *openRecentMenu = [[[NSMenu alloc] initWithTitle:kCCNWindowControllerFileMenuOpenRecentMenuTitle] autorelease];
    [openRecentMenu addItemWithTitle: kCCNWindowControllerOpenRecentMenuClearItemTitle 
                              action: @selector(clearRecentDocuments:) 
                       keyEquivalent: @""];
    [fileMenu addItemWithTitle: kCCNWindowControllerFileMenuOpenRecentMenuTitle 
                        action: NULL
                 keyEquivalent: @""].submenu = openRecentMenu;
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [fileMenu addItemWithTitle: kCCNWindowControllerFileMenuCloseItemTitle 
                        action: @selector(performClose:) 
                 keyEquivalent: @"w"];
    [fileMenu addItemWithTitle: kCCNWindowControllerFileMenuSaveItemTitle 
                        action: @selector(saveProject:)
                 keyEquivalent: @"s"];
    [[fileMenu addItemWithTitle: kCCNWindowControllerFileMenuSaveAsItemTitle 
                         action: @selector(saveProjectAs:)
                  keyEquivalent: @"s"] setKeyEquivalentModifierMask: NSShiftKeyMask|NSCommandKeyMask];
    [fileMenu addItemWithTitle: kCCNWindowControllerFileMenuRevertSavedItemTitle 
                        action: @selector(revertToSavedProject:)
                 keyEquivalent: @""];
    [fileMenu addItem:[NSMenuItem separatorItem]];
    [[fileMenu addItemWithTitle: kCCNWindowControllerFileMenuPageSetupItemTitle 
                         action: @selector(runPageLayout:)
                  keyEquivalent: @"p"] setKeyEquivalentModifierMask: NSShiftKeyMask|NSCommandKeyMask];  
    [fileMenu addItemWithTitle: kCCNWindowControllerFileMenuPrintItemTitle 
                        action: @selector(print:)
                 keyEquivalent: @"p"];
     
    // Create edit menu
    NSMenuItem *editMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: editMenuItem];
    NSMenu *editMenu = [[[NSMenu alloc] initWithTitle:kCCNWindowControllerEditMenuTitle] autorelease];
    [editMenuItem setSubmenu:editMenu];
    
    [editMenu addItemWithTitle: kCCNWindowControllerEditMenuCutItemTitle 
                        action: @selector(cutMenuItemPressed:) 
                 keyEquivalent: @"x"];
    [editMenu addItemWithTitle: kCCNWindowControllerEditMenuCopyItemTitle 
                        action: @selector(copyMenuItemPressed:) 
                 keyEquivalent: @"c"];
    [editMenu addItemWithTitle: kCCNWindowControllerEditMenuPasteItemTitle
                        action: @selector(pasteMenuItemPressed:) 
                 keyEquivalent: @"v"];
    [editMenu addItemWithTitle: kCCNWindowControllerEditMenuDeleteItemTitle 
                        action: @selector(deleteMenuItemPressed:) 
                 keyEquivalent: [NSString stringWithFormat:@"%c", 0x08]];

    // Create view menu
    NSMenuItem *viewMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: viewMenuItem];
    NSMenu *viewMenu = [[[NSMenu alloc] initWithTitle:kCCNWindowControllerViewMenuTitle] autorelease];
    [viewMenuItem setSubmenu:viewMenu];
    
    [viewMenu addItemWithTitle: kCCNWindowControllerViewMenuShowBordersItemTitle 
                        action: @selector(showBordersMenuItemPressed:) 
                 keyEquivalent: @"b"];
    [viewMenu addItem:[NSMenuItem separatorItem]];
    [viewMenu addItemWithTitle: kCCNWindowControllerViewMenuToogleFullScreenItemTitle 
                        action: @selector(toggleFullScreen:) 
                 keyEquivalent: @"f"];
    [viewMenu addItemWithTitle: kCCNWindowControllerViewMenuResetZoomItemTitle 
                        action: @selector(resetZoom:) 
                 keyEquivalent: @"0"];
    
    // Create window menu
    NSMenuItem *windowMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: windowMenuItem];
    NSMenu *windowMenu = [[[NSMenu alloc] initWithTitle:kCCNWindowControllerWindowMenuTitle] autorelease];
    [windowMenuItem setSubmenu:windowMenu];
    
    [windowMenu addItemWithTitle: kCCNWindowControllerWindowMenuMinimizeItemTitle 
                          action: @selector(performMiniaturize:) 
                   keyEquivalent: @"m"];
    [windowMenu addItemWithTitle: kCCNWindowControllerWindowMenuZoomItemTitle
                          action: @selector(performZoom:) 
                   keyEquivalent: @""];
    [windowMenu addItem:[NSMenuItem separatorItem]];
    [windowMenu addItemWithTitle: kCCNWindowControllerWindowMenuBringAllToFrontItemTitle 
                          action: @selector(arrangeInFront:) 
                   keyEquivalent: @""];
    
    // Create help menu
    NSMenuItem *helpMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: helpMenuItem];
    NSMenu *helpMenu = [[[NSMenu alloc] initWithTitle:kCCNWindowControllerHelpMenuTitle] autorelease];
    [helpMenuItem setSubmenu:helpMenu];
    
    [helpMenu addItemWithTitle: kCCNWindowControllerHelpMenuCoconadeHelpItemTitle 
                        action: @selector(showHelp:) 
                 keyEquivalent: @"?"];
    
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
    self.leftView = [[[NSView alloc] initWithFrame:leftFrame] autorelease];
    [splitView addSubview:self.leftView];
    
    CGRect centerFrame = CGRectMake(0.0f, 
                                    0.0f, 
                                    splitView.frame.size.width - kCCNWindowControllerSplitViewLeftViewDefaultWidth - 
                                        kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                    splitView.frame.size.height);
    self.centerScrollView = [[[NSScrollView alloc] initWithFrame:centerFrame] autorelease];
    self.centerScrollView.hasHorizontalScroller = YES;
    self.centerScrollView.hasVerticalScroller = YES;
    self.centerScrollView.documentView = self.workspaceController.glView;
    [splitView addSubview:self.centerScrollView];
    
    CGRect rightFrame = CGRectMake(splitView.frame.size.width - kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                   0.0f, 
                                   kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                   splitView.frame.size.height);
    self.rightView = [[[NSView alloc] initWithFrame:rightFrame] autorelease];
    [splitView addSubview:self.rightView];
    
    [splitView adjustSubviews];
    [contentView addSubview:splitView];
}

#pragma mark SplitView Delegate

- (void)splitViewWillResizeSubviews:(NSNotification *)notification
{
    CCNWindow *window = (CCNWindow *)self.window;
    [window disableUpdatesUntilFlush];
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    [self.workspaceController.glView updateFrameSize];
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    return (subview != self.centerScrollView);
}

- (BOOL)                splitView:(NSSplitView *)splitView 
            shouldCollapseSubview:(NSView *)subview 
   forDoubleClickOnDividerAtIndex:(NSInteger)dividerIndex
{
    return (subview != self.centerScrollView);
}

- (CGFloat)     splitView:(NSSplitView *)splitView 
   constrainMinCoordinate:(CGFloat)proposedMinimumPosition 
              ofSubviewAt:(NSInteger)dividerIndex
{
    if (dividerIndex == 0)
    {
        return kCCNWindowControllerSplitViewLeftViewMinWidth;    
    }
    else
    {
        return self.leftView.frame.size.width + kCCNWindowControllerSplitViewCenterViewMinWidth;
    }
}

- (CGFloat)     splitView:(NSSplitView *)splitView 
   constrainMaxCoordinate:(CGFloat)proposedMaximumPosition 
              ofSubviewAt:(NSInteger)dividerIndex
{
    if (dividerIndex == 0)
    {
        return splitView.frame.size.width - self.rightView.frame.size.width -   
                kCCNWindowControllerSplitViewCenterViewMinWidth;
    }
    else
    {
        return splitView.frame.size.width - kCCNWindowControllerSplitViewRightViewMinWidth;
    }
}

#pragma mark NSView Animation

- (void)animateView:(NSView *)view withTargetFrame:(CGRect)frame delay:(NSTimeInterval)delay
{    
	[NSAnimationContext beginGrouping];
	[[NSAnimationContext currentContext] setDuration:delay];
	[[view animator] setFrame: frame];
	[NSAnimationContext endGrouping];
}

#pragma mark Toolbar Delegate

- (NSArray *) toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [NSArray arrayWithObjects: 
            kCCNWindowControllerToolbarItemAddSpriteIdentifier,
            kCCNWindowControllerToolbarItemAddBigImageIdentifier,
            kCCNWindowControllerToolbarItemAddLabelIdentifier,
            NSToolbarFlexibleSpaceItemIdentifier,
            kCCNWindowControllerToolbarItemViewIdentifier,
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
            kCCNWindowControllerToolbarItemViewIdentifier,
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
        toolbarItem.action = @selector(addSprite:);
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
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemViewIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemViewName;
        CGRect segmentControlFrame = CGRectMake(0.0, 
                                                0.0, 
                                                kCCNWindowControllerToolbarItemViewWidth, 
                                                kCCNWindowControllerToolbarItemViewHeight);
        NSSegmentedControl *segmentControl = [[[NSSegmentedControl alloc] initWithFrame:segmentControlFrame] autorelease];
        
        NSSegmentedCell *segmentCell = [segmentControl cell];
        segmentCell.trackingMode = NSSegmentSwitchTrackingSelectAny;
        segmentCell.segmentCount = 2;
        segmentCell.alignment = NSCenterTextAlignment;
        segmentCell.segmentStyle = NSSegmentStyleSmallSquare;
        
        [segmentCell setImage: [NSImage imageNamed: kCCNWindowControllerToolbarItemViewLeftImage] 
                   forSegment: 0];
        [segmentCell setWidth: kCCNWindowControllerToolbarItemViewSegmentWidth 
                   forSegment: 0];
        
        [segmentCell setImage: [NSImage imageNamed: kCCNWindowControllerToolbarItemViewRightImage] 
                   forSegment: 1];
        [segmentCell setWidth: kCCNWindowControllerToolbarItemViewSegmentWidth 
                   forSegment: 1];
        
        segmentCell.target = self;
        segmentCell.action = @selector(segmentClicked:);
        
        [toolbarItem setView:segmentControl];
        
        //TODO: save and load selected segments from UserDefaults
        [segmentCell setSelected:YES forSegment:0];
        [segmentCell setSelected:YES forSegment:1];        
    }
    
    return toolbarItem;
}

#pragma mark Toolbar Callbacks

- (void)addSprite:(id)sender
{
    // allowed file types
    NSArray *allowedTypes = [self.workspaceController allowedImageFileTypes];
    
    // initialize panel + set flags
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowedFileTypes:allowedTypes];
    [openPanel setAllowsOtherFileTypes:NO];
    
    // handle the open panel
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) 
     {
         if (result == NSOKButton)
         {
             NSArray *files = [openPanel filenames];
             [self performBlockOnCocosThread:^()
              {
                  [self.workspaceController importSpritesWithFiles: files];
              }];
         }
     }];
}

- (void)segmentClicked:(id)sender
{
    if ( [sender isKindOfClass:[NSSegmentedControl class]] )
    {
        NSSegmentedControl *segmentedControl = sender;
        if (segmentedControl.selectedSegment == 0)
        {
            if ([segmentedControl isSelectedForSegment:0])
            {
                [self animateView: self.leftView 
                  withTargetFrame: CGRectMake(self.leftView.frame.origin.x, 
                                              self.leftView.frame.origin.y, 
                                              kCCNWindowControllerSplitViewLeftViewDefaultWidth, 
                                              self.leftView.frame.size.height)
                            delay: kCCNWindowControllerSplitViewCollapseAnimationDelay];
            }
            else
            {
                [self animateView: self.leftView 
                  withTargetFrame: CGRectMake(self.leftView.frame.origin.x, 
                                              self.leftView.frame.origin.y, 
                                              0.0f, 
                                              self.leftView.frame.size.height)
                            delay: kCCNWindowControllerSplitViewCollapseAnimationDelay];
            }
        }
        else
        {
            if ([segmentedControl isSelectedForSegment:1])
            {
                [self animateView: self.rightView 
                  withTargetFrame: CGRectMake(self.rightView.frame.origin.x - kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                              self.rightView.frame.origin.y, 
                                              kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                              self.rightView.frame.size.height)
                            delay: kCCNWindowControllerSplitViewCollapseAnimationDelay];
            }
            else
            {
                [self animateView: self.rightView 
                  withTargetFrame: CGRectMake(self.rightView.frame.origin.x + self.rightView.frame.size.width, 
                                              self.rightView.frame.origin.y, 
                                              0.0f, 
                                              self.rightView.frame.size.height)
                            delay: kCCNWindowControllerSplitViewCollapseAnimationDelay];
            }
        }
    }
}

#pragma mark MainMenu related

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem  	
{
    if ([menuItem.title isEqualToString:kCCNWindowControllerFileMenuRevertSavedItemTitle])
    {
        return [self.workspaceController canRevertToSavedProject];
    }
    else if ([menuItem.title isEqualToString:kCCNWindowControllerEditMenuCutItemTitle])
    {
        return [self.workspaceController canCutSelectedToPasteboard];
    }
    else if ([menuItem.title isEqualToString:kCCNWindowControllerEditMenuCopyItemTitle])
    {
        return [self.workspaceController canCopySelectedToPasteboard];
    }
    else if ([menuItem.title isEqualToString:kCCNWindowControllerEditMenuPasteItemTitle])
    {
        return [self.workspaceController canPasteFromPasteboard];
    }
    else if ([menuItem.title isEqualToString:kCCNWindowControllerEditMenuDeleteItemTitle])
    {
        return [self.workspaceController canDeleteSelected];
    }
    else if ([menuItem.title isEqualToString:kCCNWindowControllerViewMenuShowBordersItemTitle])
    {
        CCNScene *scene = (CCNScene *)[[CCDirector sharedDirector] runningScene];
        menuItem.state = scene.showBorders ? NSOnState : NSOffState;
    }
    return YES;
}

#pragma mark FileMenu Callbacks

- (void)newProject:(id)sender
{
    [self performBlockOnCocosThread:^() 
     {
         [self.workspaceController newProject];  
     }];
}

- (void)openProject:(id)sender
{
    // initialize panel + set flags
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowsMultipleSelection:YES];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:kCCNWindowControllerCoconadeProjectFileExtension]];
    [openPanel setAllowsOtherFileTypes:NO];  
    
    // handle the open panel
    [openPanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) 
     {
         if (result == NSOKButton)
         {
             NSArray *files = [openPanel filenames];
             NSString *file = [files objectAtIndex:0];
             if (file)
             {
                 [self performBlockOnCocosThread:^() 
                  {
                      [self.workspaceController loadProject: file];
                  }];
             }
         }
     }];
}

- (void)saveProjectAs:(id)sender
{   
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:kCCNWindowControllerCoconadeProjectFileExtension]];
    
    // handle the save panel
    [savePanel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) 
     {
         if (result == NSOKButton)
         {
             NSString *file = [savePanel filename];
             [self performBlockOnCocosThread: ^()
              {
                  [self.workspaceController saveProjectToFile: file];
              }];
         }
     }];
}

- (void)saveProject:(id)sender
{
    if ( ![self.workspaceController canSaveProject] ) 
    {
        [self saveProjectAs: sender];
        return;
    }
    
    [self performBlockOnCocosThread: ^()
     {
         [self.workspaceController saveProject];
     }];
}

- (void)revertToSavedProject:(id)sender
{
    [self performBlockOnCocosThread:^() 
     {
         [self.workspaceController revertToSavedProject];
     }];
}

#pragma mark EditMenu Callbacks

- (void) cutMenuItemPressed: (id) sender
{
    [self performBlockOnCocosThread:^()
     {
         [self.workspaceController cutSelectedToPasteboard];
     }];
}

- (void) copyMenuItemPressed: (id) sender
{
    [self performBlockOnCocosThread:^()
     {
         [self.workspaceController copySelectedToPasteboard];
     }];
}

- (void) pasteMenuItemPressed: (id) sender
{    
    [self performBlockOnCocosThread:^()
     {
         [self.workspaceController pasteFromPasteboard];
     }];
}

- (void) deleteMenuItemPressed: (id) sender
{
    [self performBlockOnCocosThread:^()
     {
         [self.workspaceController deleteSelected];
     }];
}

#pragma mark ViewMenu Callbacks

- (void) showBordersMenuItemPressed: (id) sender
{
    CCNScene *scene = (CCNScene *)[[CCDirector sharedDirector] runningScene];
    scene.showBorders = ([sender state] == NSOffState);
}

- (void)toggleFullScreen: (id)sender
{
	CCDirectorMac *director = (CCDirectorMac *)[CCDirector sharedDirector];
	[director setFullScreen: ! [director isFullScreen] ];
	[self.workspaceController.glView updateView];
}

- (void)resetZoom:(id)sender
{
    [self.workspaceController.glView resetZoom];
}

@end
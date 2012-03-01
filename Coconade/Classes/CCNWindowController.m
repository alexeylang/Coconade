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
#import "OSVersionHelper.h"

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

#define kCCNWindowControllerToolbarItemViewIdentifier           @"toolbarItemViewIdentifier"
#define kCCNWindowControllerToolbarItemViewName                 @"View"
#define kCCNWindowControllerToolbarItemViewLeftImage            @"left_panel_icon.png"
#define kCCNWindowControllerToolbarItemViewRightImage           @"right_panel_icon.png"
#define kCCNWindowControllerToolbarItemViewWidth                66.0f
#define kCCNWindowControllerToolbarItemViewHeight               25.0f
#define kCCNWindowControllerToolbarItemViewSegmentWidth         29.0f

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
#define kCCNWindowControllerViewMenuShowBordersItemTitle        @"Show Borders & Checkerboard"
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

#define kCCNWindowControllerWindowMinWidth                      800.0f
#define kCCNWindowControllerWindowMinHeight                     600.0f

#define kCCNWindowControllerSplitViewCollapseAnimationDelay     0.2f

#define kCCNWindowControllerRecentDocumentsMaxCount             8
#define kCCNWindowControllerUserDefaultsRecentDocumentsKey      @"CCNWindowControllerRecentDocuments"


@interface CCNWindowController ()

@property (readwrite, retain) NSSplitView *mainSplitView;
@property (readwrite, retain) NSView *leftView;
@property (readwrite, retain) NSScrollView *centerScrollView;
@property (readwrite, retain) NSView *rightView;
@property (readwrite, retain) NSSegmentedControl *viewSegmentedControl;
@property (readwrite, retain) NSMenu *openRecentMenu;

/** Prepare Coconade window - creates and sets up main menu, toolbar, glView, 
 * splitView, scrollView, etc.
 */
- (void)prepareWindow;

/** Animate changing frame for given NSView by using NSAnimationContext and animator object. */
- (void)animateView:(NSView *)view withTargetFrame:(CGRect)frame delay:(NSTimeInterval)delay;

/** Update recent menu to show actual recent documents */
- (void)updateRecentMenu;

@end


@implementation CCNWindowController

@synthesize workspaceController = _workspaceController;
@synthesize mainSplitView = _mainSplitView;
@synthesize leftView = _leftView;
@synthesize centerScrollView = _centerScrollView;
@synthesize rightView = _rightView;
@synthesize viewSegmentedControl = _viewSegmentedControl;
@synthesize openRecentMenu = _openRecentMenu;

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
    [self.leftView removeObserver:self forKeyPath: @"hidden"];
    [self.rightView removeObserver:self forKeyPath: @"hidden"];

    self.workspaceController = nil;
    self.mainSplitView = nil;
    self.leftView = nil;
    self.centerScrollView = nil;
    self.rightView = nil;
    self.viewSegmentedControl = nil;
    
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
    self.openRecentMenu = [[[NSMenu alloc] initWithTitle:kCCNWindowControllerFileMenuOpenRecentMenuTitle] autorelease];
    [self.openRecentMenu addItem:[NSMenuItem separatorItem]];
    [self.openRecentMenu addItemWithTitle: kCCNWindowControllerOpenRecentMenuClearItemTitle 
                                   action: @selector(clearRecentDocuments:) 
                            keyEquivalent: @""];
    [fileMenu addItemWithTitle: kCCNWindowControllerFileMenuOpenRecentMenuTitle 
                        action: NULL
                 keyEquivalent: @""].submenu = self.openRecentMenu;
    [self updateRecentMenu];
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
    self.window.backgroundColor = [NSColor colorWithDeviceRed:0.95f green:0.95f blue:0.95f alpha:1.0f];
    self.window.hasShadow = YES;
    self.window.acceptsMouseMovedEvents = NO;
    self.window.minSize = CGSizeMake(kCCNWindowControllerWindowMinWidth, kCCNWindowControllerWindowMinHeight);
    
    // Create and setup toolbar
    [self prepareToolbar];
    
    // Create and setup main menu
    [self prepareMainMenu];
    
    // Create and setup splitView & subviews
    NSView *contentView = self.window.contentView;
    self.mainSplitView = [[[NSSplitView alloc] initWithFrame: contentView.frame] autorelease];
    self.mainSplitView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable; 
    self.mainSplitView.dividerStyle = NSSplitViewDividerStyleThin;
    self.mainSplitView.delegate = self;
    [self.mainSplitView setVertical:YES];
    
    // Create and setup left view
    CGRect leftFrame = CGRectMake(0.0f, 
                                  0.0f, 
                                  kCCNWindowControllerSplitViewLeftViewDefaultWidth, 
                                  self.mainSplitView.frame.size.height);
    self.leftView = [[[NSView alloc] initWithFrame:leftFrame] autorelease];
    [self.leftView addObserver:self 
                    forKeyPath:@"hidden" 
                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                       context:NULL];
    [self.mainSplitView addSubview:self.leftView];
    
    // Create and setup center scroll view
    CGRect centerFrame = CGRectMake(0.0f, 
                                    0.0f, 
                                    self.mainSplitView.frame.size.width - kCCNWindowControllerSplitViewLeftViewDefaultWidth - 
                                        kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                    self.mainSplitView.frame.size.height);
    self.centerScrollView = [[[NSScrollView alloc] initWithFrame:centerFrame] autorelease];
    self.centerScrollView.hasHorizontalScroller = YES;
    self.centerScrollView.hasVerticalScroller = YES;
    self.centerScrollView.documentView = self.workspaceController.glView;
    [self.mainSplitView addSubview:self.centerScrollView];
    
    // Create and setup right view
    CGRect rightFrame = CGRectMake(self.mainSplitView.frame.size.width - kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                   0.0f, 
                                   kCCNWindowControllerSplitViewRightViewDefaultWidth, 
                                   self.mainSplitView.frame.size.height);
    self.rightView = [[[NSView alloc] initWithFrame:rightFrame] autorelease];
    [self.rightView addObserver:self 
                     forKeyPath:@"hidden" 
                        options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial
                        context:NULL];
    [self.mainSplitView addSubview:self.rightView];
    
    [self.mainSplitView adjustSubviews];
    [contentView addSubview:self.mainSplitView];
}

#pragma mark Recent Menu

- (void) addRecentDocumentPath:(NSString *)documentPath
{
    NSArray *curDocs = [[NSUserDefaults standardUserDefaults] objectForKey:kCCNWindowControllerUserDefaultsRecentDocumentsKey];
    if ( ![curDocs isKindOfClass:[NSArray class]] )
    {
        curDocs = nil;
    }
    NSMutableArray *newDocs = [NSMutableArray arrayWithArray:curDocs];
    [newDocs removeObjectIdenticalTo:documentPath];
    [newDocs addObject:documentPath];
    if ( [newDocs count] > kCCNWindowControllerRecentDocumentsMaxCount )
    {
        [newDocs removeObjectsInRange:NSMakeRange(0, [newDocs count] - kCCNWindowControllerRecentDocumentsMaxCount)];
    }
    [[NSUserDefaults standardUserDefaults] setObject:newDocs forKey:kCCNWindowControllerUserDefaultsRecentDocumentsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateRecentMenu];
}

- (void)updateRecentMenu
{
    while ([self.openRecentMenu.itemArray count] > 2) 
    {
        [self.openRecentMenu removeItemAtIndex:0];
    }
    
    NSArray *curDocs = [[NSUserDefaults standardUserDefaults] objectForKey:kCCNWindowControllerUserDefaultsRecentDocumentsKey];
    if ( [curDocs isKindOfClass:[NSArray class]] )
    {
        for (NSString *doc in curDocs)
        {
            [self.openRecentMenu insertItemWithTitle:doc 
                                              action:@selector(openRecentDocument:) 
                                       keyEquivalent:@"" 
                                             atIndex:0];
        }
    }
}

#pragma mark SplitView Delegate

- (void)splitViewWillResizeSubviews:(NSNotification *)notification
{
    CCNWindow *window = (CCNWindow *)self.window;
    [window disableUpdatesUntilFlush];
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    // Check left view for zero width and if this is true - recover width from _leftViewWidthBeforeAnimatedCollapse
    if ( !self.leftView.frame.size.width && _leftViewWidthBeforeAnimatedCollapse )
    {
        self.leftView.frame = CGRectMake(self.leftView.frame.origin.x, 
                                         self.leftView.frame.origin.y, 
                                         _leftViewWidthBeforeAnimatedCollapse, 
                                         self.leftView.frame.size.height);
        _leftViewWidthBeforeAnimatedCollapse = 0.0f;
        [self.mainSplitView setPosition:0.0f ofDividerAtIndex:0];
    }
    
    // Check right view for zero width and if this is true - recover width from _rightViewWidthBeforeAnimatedCollapse
    if ( !self.rightView.frame.size.width && _rightViewWidthBeforeAnimatedCollapse )
    {
        self.rightView.frame = CGRectMake(self.rightView.frame.origin.x - _rightViewWidthBeforeAnimatedCollapse, 
                                          self.rightView.frame.origin.y, 
                                          _rightViewWidthBeforeAnimatedCollapse, 
                                          self.rightView.frame.size.height);
        _rightViewWidthBeforeAnimatedCollapse = 0.0f;
        [self.mainSplitView setPosition:self.mainSplitView.frame.size.width ofDividerAtIndex:1];
    }
    
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
    switch (dividerIndex) 
    {
        case 0: //< Divider between left view and center scroll view
            return kCCNWindowControllerSplitViewLeftViewMinWidth;    
            
        case 1: //< Divider between center scroll view and right view
            return self.leftView.visibleRect.size.width + kCCNWindowControllerSplitViewCenterViewMinWidth;
            
        default:
            return 0.0f;
    }
}

- (CGFloat)     splitView:(NSSplitView *)splitView 
   constrainMaxCoordinate:(CGFloat)proposedMaximumPosition 
              ofSubviewAt:(NSInteger)dividerIndex
{
    switch (dividerIndex) 
    {
        case 0: //< Divider between left view and center scroll view
            return splitView.frame.size.width - self.rightView.visibleRect.size.width -   
                    kCCNWindowControllerSplitViewCenterViewMinWidth;
            
        case 1: //< Divider between center scroll view and right view
            return splitView.frame.size.width - kCCNWindowControllerSplitViewRightViewMinWidth;
            
        default:
            return 0.0f;
    }
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    if ( !_leftViewWidthBeforeAnimatedCollapse )
    {
        self.leftView.frame = CGRectMake(self.leftView.frame.origin.x, 
                                         self.leftView.frame.origin.y, 
                                         self.leftView.frame.size.width, 
                                         splitView.frame.size.height);
    }
    
    if ( !_rightViewWidthBeforeAnimatedCollapse )
    {
        self.rightView.frame = CGRectMake(splitView.frame.size.width - self.rightView.frame.size.width, 
                                         self.rightView.frame.origin.y, 
                                         self.rightView.frame.size.width, 
                                         splitView.frame.size.height);
    }
    
    self.centerScrollView.frame = CGRectMake(self.leftView.visibleRect.origin.x + self.leftView.visibleRect.size.width + 
                                                splitView.dividerThickness, 
                                             self.centerScrollView.frame.origin.y, 
                                             splitView.frame.size.width - self.leftView.visibleRect.size.width - 
                                                self.rightView.visibleRect.size.width - 2.0f * splitView.dividerThickness,
                                             splitView.frame.size.height);
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
    else if ([itemIdentifier isEqualTo:kCCNWindowControllerToolbarItemViewIdentifier]) 
    {
        toolbarItem.label = toolbarItem.paletteLabel = toolbarItem.toolTip = kCCNWindowControllerToolbarItemViewName;
        CGRect segmentControlFrame = CGRectMake(0.0, 
                                                0.0, 
                                                kCCNWindowControllerToolbarItemViewWidth, 
                                                kCCNWindowControllerToolbarItemViewHeight);
        self.viewSegmentedControl = [[[NSSegmentedControl alloc] initWithFrame:segmentControlFrame] autorelease];
        
        NSSegmentedCell *segmentCell = [self.viewSegmentedControl cell];
        segmentCell.trackingMode = NSSegmentSwitchTrackingSelectAny;
        segmentCell.segmentCount = 2;
        segmentCell.alignment = NSCenterTextAlignment;
        
        int segmentStyle = NSSegmentStyleSmallSquare;
        
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= __MAC_10_7
        if (lionFeaturesAvailable())
        {
            segmentStyle = NSSegmentStyleCapsule;
        }
#endif
        segmentCell.segmentStyle = segmentStyle;
        
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
        
        [toolbarItem setView:self.viewSegmentedControl];
    }
    
    return toolbarItem;
}

#pragma mark LeftView & RightView KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.leftView)
    {
        if ([keyPath isEqualToString:@"hidden"])
        {
            [self.viewSegmentedControl setSelected: !self.leftView.isHidden forSegment:0];
        }
    }
    else if (object == self.rightView)
    {
        if ([keyPath isEqualToString:@"hidden"])
        {
            [self.viewSegmentedControl setSelected: !self.rightView.isHidden forSegment:1];
        }
    }
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
             NSMutableArray *files = [NSMutableArray arrayWithCapacity:10];
             for (NSURL *fileURL in [openPanel URLs])
             {
                 [files addObject:fileURL.path];
             }
             [self performBlockOnCocosThread:^()
              {
                  [self.workspaceController importSpritesWithFiles: files withPositionInScene: CGPointZero];
              }];
         }
     }];
}

- (void)segmentClicked:(id)sender
{
    if ( [sender isKindOfClass:[NSSegmentedControl class]] )
    {
        NSSegmentedControl *segmentedControl = sender;
        int segment = segmentedControl.selectedSegment;
        BOOL selected = [segmentedControl isSelectedForSegment:segment];
        NSView *targetView = nil;
        CGRect targetFrame = CGRectZero;
        switch (segment) 
        {
            case 0: //< Show/hide left view
                {
                    targetView = self.leftView;
                    CGRect zeroWidthFrame = CGRectMake(self.leftView.frame.origin.x, 
                                                       self.leftView.frame.origin.y, 
                                                       0.0f, 
                                                       self.leftView.frame.size.height);
                    if (selected)
                    {
                        // Set width to zero and show left view with animation
                        targetFrame = self.leftView.frame;
                        self.leftView.frame = zeroWidthFrame;
                        [self.leftView setHidden:NO];
                        
                        // Check width of target frame, if zero  - set default width
                        if ( !targetFrame.size.width )
                        {
                            targetFrame.size.width = kCCNWindowControllerSplitViewLeftViewDefaultWidth;
                        }
                    }
                    else
                    {
                        // Save last width to _leftViewWidthBeforeAnimatedCollapse and hide left view
                        _leftViewWidthBeforeAnimatedCollapse = self.leftView.frame.size.width;
                        targetFrame = zeroWidthFrame;
                    }
                }                
                break;
                
            case 1: //< Show/hide right view
                {
                    targetView = self.rightView;
                    CGRect zeroWidthFrame = CGRectMake(self.rightView.frame.origin.x + self.rightView.frame.size.width, 
                                                       self.rightView.frame.origin.y, 
                                                       0.0f, 
                                                       self.rightView.frame.size.height);
                    if (selected)
                    {
                        // Set width to zero and show right view with animation
                        targetFrame = self.rightView.frame;
                        self.rightView.frame = zeroWidthFrame;
                        [self.rightView setHidden:NO];
                        
                        // Check width of target frame, if zero  - set default width
                        if ( !targetFrame.size.width )
                        {
                            targetFrame.origin.x -= kCCNWindowControllerSplitViewRightViewDefaultWidth;
                            targetFrame.size.width = kCCNWindowControllerSplitViewRightViewDefaultWidth;
                        }
                    }
                    else
                    {
                        // Save last width to _rightViewWidthBeforeAnimatedCollapse and hide right view
                        _rightViewWidthBeforeAnimatedCollapse = self.rightView.frame.size.width;
                        targetFrame = zeroWidthFrame;
                    }
                }
                break;
                
            default:
                break;
        }
        [self animateView: targetView 
          withTargetFrame: targetFrame
                    delay: kCCNWindowControllerSplitViewCollapseAnimationDelay];
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
        menuItem.state = scene.showBordersAndCheckerboard ? NSOnState : NSOffState;
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
             NSArray *fileURLs = [openPanel URLs];
             NSString *file = [[fileURLs objectAtIndex:0] path];
             if (file)
             {
                 [self addRecentDocumentPath:file];
                 [self performBlockOnCocosThread:^() 
                  {
                      [self.workspaceController loadProject: file];
                  }];
             }
         }
     }];
}

- (void)openRecentDocument:(id)sender
{
    if ( [sender isKindOfClass:[NSMenuItem class]] )
    {
        NSMenuItem *menuItem = sender;
        if (menuItem.title)
        {
            [self addRecentDocumentPath:menuItem.title];
            [self performBlockOnCocosThread:^() 
             {
                 [self.workspaceController loadProject: menuItem.title];
             }];
        }        
    }
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
             NSString *file = [[savePanel URL] path];
             [self performBlockOnCocosThread: ^()
              {
                  [self.workspaceController saveProjectToFile: file];
              }];
         }
     }];
}

- (void)clearRecentDocuments:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kCCNWindowControllerUserDefaultsRecentDocumentsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateRecentMenu];
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
    scene.showBordersAndCheckerboard = ([sender state] == NSOffState);
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
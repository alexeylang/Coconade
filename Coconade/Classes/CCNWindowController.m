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


@interface CCNWindowController ()

/** Prepare Coconade window - creates and sets up main menu, toolbar, glView, 
 * splitView, scrollView, etc.
 */
- (void) prepareWindow;

@end


@implementation CCNWindowController

@synthesize workspaceController = _workspaceController;

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
                        action: NULL 
                 keyEquivalent: @"x"];
    [editMenu addItemWithTitle: kCCNWindowControllerEditMenuCopyItemTitle 
                        action: NULL 
                 keyEquivalent: @"c"];
    [editMenu addItemWithTitle: kCCNWindowControllerEditMenuPasteItemTitle
                        action: NULL 
                 keyEquivalent: @"v"];
    [editMenu addItemWithTitle: kCCNWindowControllerEditMenuDeleteItemTitle 
                        action: NULL 
                 keyEquivalent: [NSString stringWithFormat:@"%c", 0x08]];

    // Create view menu
    NSMenuItem *viewMenuItem = [[[NSMenuItem alloc] init] autorelease];
    [mainMenu addItem: viewMenuItem];
    NSMenu *viewMenu = [[[NSMenu alloc] initWithTitle:kCCNWindowControllerViewMenuTitle] autorelease];
    [viewMenuItem setSubmenu:viewMenu];
    
    [viewMenu addItemWithTitle: kCCNWindowControllerViewMenuShowBordersItemTitle 
                        action: NULL 
                 keyEquivalent: @"b"];
    [viewMenu addItem:[NSMenuItem separatorItem]];
    [viewMenu addItemWithTitle: kCCNWindowControllerViewMenuToogleFullScreenItemTitle 
                        action: NULL 
                 keyEquivalent: @"f"];
    [viewMenu addItemWithTitle: kCCNWindowControllerViewMenuResetZoomItemTitle 
                        action: NULL 
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
    centerScrollView.documentView = self.workspaceController.glView;
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
    [self.workspaceController.glView updateFrameSize];
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

#pragma mark FileMenu related

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
    [openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"csd"]];
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
    [savePanel setAllowedFileTypes:[NSArray arrayWithObjects:@"csd", @"ccb", nil]];
    
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

@end
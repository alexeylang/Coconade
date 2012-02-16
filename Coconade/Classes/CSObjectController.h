/*
 * cocoshop
 *
 * Copyright (c) 2011 Andrew
 * Copyright (c) 2011 Stepan Generalov
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

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"
#import "CCEventDispatcher+Gestures.h"

@class CSModel;

@interface CSObjectController : NSObjectController  <CCMouseEventDelegate, CCKeyboardEventDelegate, CCGestureEventDelegate>
{
    // Events - already in CCNController
    BOOL shouldToggleVisibility_;
	BOOL shouldDragSprite_;
    CGPoint prevLocation_;
    //< Events
    
    CSModel *modelObject_;      //< model, already in CCNController
	NSString *projectFilename_; //< already in CCNModel
	
    
    
    
    
    
    
    
	// ====== Interface Builder Shit - to remove. ======
	IBOutlet NSPanel *infoPanel_;
	NSView *spriteInfoView_;
	NSView *backgroundInfoView_;
	IBOutlet NSTextField *nameField_;
	IBOutlet NSTextField *posXField_;
	IBOutlet NSStepper *posXStepper_;
	IBOutlet NSTextField *posYField_;
	IBOutlet NSStepper *posYStepper_;
	IBOutlet NSTextField *posZField_;
	IBOutlet NSStepper *posZStepper_;
	IBOutlet NSTextField *anchorXField_;
	IBOutlet NSStepper *anchorXStepper_;
	IBOutlet NSTextField *anchorYField_;
	IBOutlet NSStepper *anchorYStepper_;
	IBOutlet NSTextField *scaleField_;
	IBOutlet NSStepper *scaleStepper_;
	IBOutlet NSButton *flipXButton_;
	IBOutlet NSButton *flipYButton_;
	IBOutlet NSTextField *opacityField_;
	IBOutlet NSSlider *opacitySlider_;
	IBOutlet NSColorWell *colorWell_;
	IBOutlet NSButton *relativeAnchorButton_;
	IBOutlet NSTextField *rotationField_;
	IBOutlet NSSlider *rotationSlider_;
	IBOutlet NSPanel *spritesPanel_;
	IBOutlet NSTableView *spriteTableView_;
	IBOutlet NSMenuItem *showBordersMenuItem_;
}

@property(assign) IBOutlet CSModel *modelObject; //< OK
@property(assign) NSTableView *spriteTableView; //<SHIT
@property(retain) IBOutlet NSView *spriteInfoView; //< SHIT
@property(retain) IBOutlet NSView *backgroundInfoView; //< SHIT
@property(copy) NSString *projectFilename; //< OK

#pragma mark Sprites

/**
 * filters array of filenames, leaving only allowed
 * @returns The filtered files
 */
- (NSArray *)allowedFilesWithFiles:(NSArray *)files;

/**
 * adds sprites will filenames taken from array, doesn't do any filtering. executes safely on cocos2d thread
 * @param files Filenames of sprites to add
 */
- (void) addSpritesWithFilesSafely:(NSArray *)files;

- (void)deleteSprite:(CCNode *)sprite;
- (void)deleteAllSprites;

#pragma mark Save/Load
- (NSDictionary *)dictionaryFromLayerForBaseDirPath: (NSString *) baseDirPath;
- (void)saveProjectToFile:(NSString *)filename;

#pragma mark IBActions - Windows
- (IBAction)openInfoPanel:(id)sender;
- (IBAction)openSpritesPanel: (id) sender;
- (IBAction)openMainWindow:(id)sender;


#pragma mark Loading CSD Files 
/**
 * Call loadProjectFromDictionary: on cocos2d thread
 * @param dict Dictionary to load from
 */
- (void)loadProjectFromDictionarySafely:(NSDictionary *)dict;
/**
 * Load project to layer from dictionary
 * @param dict Dictionary to load from
 */
- (void)loadProjectFromDictionary:(NSDictionary *)dict;

#pragma mark IBActions - Save/Load
- (IBAction)saveProject:(id)sender;
- (IBAction)saveProjectAs:(id)sender;
- (IBAction)newProject:(id)sender;
- (IBAction)openProject:(id)sender;
- (IBAction)revertToSavedProject:(id)sender;

#pragma mark IBActions - Sprites
- (IBAction)addSprite:(id)sender;
- (IBAction)spriteAddButtonClicked:(id)sender;
- (IBAction)spriteDeleteButtonClicked:(id)sender;

#pragma mark IBActions - Zoom
- (IBAction)resetZoom:(id)sender;

#pragma mark IBAction - Menus
- (IBAction) showBordersMenuItemPressed: (id) sender;
- (IBAction) deleteMenuItemPressed: (id) sender;
- (IBAction) cutMenuItemPressed: (id) sender;
- (IBAction) copyMenuItemPressed: (id) sender;
- (IBAction) pasteMenuItemPressed: (id) sender;

@end

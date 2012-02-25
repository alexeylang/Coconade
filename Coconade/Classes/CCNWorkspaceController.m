//
//  CCNWorkspaceController.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import "cocos2d.h"
#import "CCNWorkspaceController.h"
#import "CCNModel.h"
#import "CCNScene.h"
#import "CCNode+Helpers.h"
#import "CCNMacGLView.h"
#import "NSObject+Blocks.h"

@interface CCNWorkspaceController ()

/** Adds self as observer to new model, updates everything related &
 * removes self as observer from old model
 */
- (void) modelUpdatedFromOldOne: (CCNModel *) oldModel;

#pragma mark Import

/** Returns array of file extensions (excludng dot), that are supported by Coconade
 * and can be used as images (textures).
 */
- (NSArray *) allowedImageFileTypes;

/** Filters array of filenames, returning only such of them, that have allowed type
 * (file extension is listed in allowedFileTypes).
 *
 * @param files Array of NSStrings with paths to files.
 *
 * @param allowedFileTypes Array of NSStrings with allowed file extensions (excluding dot sign).
 *
 * @return Array of NSStrings with paths to files, that are have allowed type.
 * If there's no files allowed - empty array is returned.
 */
- (NSArray *) filterFiles: (NSArray *) files withAllowedFileTypes: (NSArray *) allowedFileTypes;

/** Creates CCSprites from given filenames and adds it to current selected node
 * (curRootNode or selected node).
 * If sprite can't be added to that node - tries to add it to it's parent.
 * If it can't be added to anything - registers a problem in CCNProblemManager
 */
- (void)importSpritesWithFiles: (NSArray *) filenames;

#pragma mark Events Support

/** Adds CCNWorkspaceController to CCEventDispatcher keyboard, mouse & gesture delegates lists. */
- (void) registerWithEventDispatcher;

/** Removes CCNWorkspaceController from CCEventDispatcher delegates lists.
 * ATTENTION: shouldn't be used in CCNWorkspaceController#dealloc, cause CCEventDispatcher
 * retains delegates, and dealloc will never happen if controller will not be 
 * removed from delegates before.
 */
- (void) unregisterWithEventDispatcher;

@end

/** Virtual Key Codes for Keyboard Events.
 * Keycodes available here: http://forums.macrumors.com/showpost.php?p=8428116&postcount=2
 */
enum keyCodes 
{
    // Delete
    kCCNKeyCodeBackspace = 0x33,
    kCCNKeyCodeDelete = 0x75,
    
    // Arrows
    kCCNKeyCodeLeftArrow = 0x7B,
    kCCNKeyCodeRightArrow = 0x7C,
    kCCNKeyCodeDownArrow = 0x7D,
    kCCNKeyCodeUpArrow = 0x7E,
    
    // Page
    kCCNKeyCodePageUp = 0x74,
    kCCNKeyCodePageDown = 0x79,
};

// ====== Increments for node's properties for keyboard events. ======
static const float kCCNIncrementAnchorDefault = 0.01f;
static const float kCCNIncrementAnchorBig = 0.1f;
static const float kCCNIncrementRotationDefault = 1.0f;
static const float kCCNIncrementRotationBig = 10.0f;
static const float kCCNIncrementPositionDefault = 1.0f;
static const float kCCNIncrementPositionBig = 10.0f;    
static const float kCCNIncrementZOrderDefault = 1.0f;
static const float kCCNIncrementZOrderBig = 10.0f;

#pragma mark -

@implementation CCNWorkspaceController

@dynamic model;
- (CCNModel *) model
{
    return [[_model retain] autorelease];
}

- (void) setModel:(CCNModel *)model
{
    if (_model != model)
    {
        id oldValue = _model;
        _model = [model retain];
        
        [self modelUpdatedFromOldOne: oldValue];
        
        [oldValue release];   
        
        // Ensure to have appropriate workspace size for currentRootNode.
        self.glView.workspaceSize = _model.currentRootNode.contentSize;
        [self.scene updateForScreenReshape];
    }
}

@synthesize scene = _scene;
@synthesize glView = _glView;

#pragma mark Init/DeInit

+ (id) controllerWithGLView: (CCNMacGLView *) glView
{
    return [[[self alloc] initWithGLView: glView] autorelease];
}

- (id) initWithGLView: (CCNMacGLView *) glView
{
    self = [super init];
    if (self)
    {
        self.glView = glView;
        
        [self newProject];
        
        // Prepare scene.
        self.scene = [CCNScene node];   
        self.scene.targetNode = self.model.currentRootNode;
        
        [self registerWithEventDispatcher];
        
        // Prepare for pasteboard & drag & drop support.
        self.glView.dragAndDropDelegate = self;
    }
    return self;
}

- (void) halt
{
    [self unregisterWithEventDispatcher];
    self.glView.dragAndDropDelegate = nil;
    self.glView = nil;
}

- (void) dealloc
{
    self.scene = nil;
    self.model = nil;
    self.glView = nil;    
        
    [super dealloc];
}

#pragma mark Project

- (void) newProject
{
    self.model = [[CCNModel new] autorelease];    
    [self.glView setWorkspaceSize: self.model.currentRootNode.contentSize];
    
    [self.scene updateForScreenReshape];
}

- (void) loadProject: (NSString *) filepath
{
    CCNModel *newModel = [CCNModel modelFromFile: filepath ];
    if (!newModel)
    {
        [self performBlockOnMainThread:^()
         {
             [[NSAlert alertWithMessageText: @"Can't open file." 
                              defaultButton: @"OK"
                            alternateButton: nil
                                otherButton: nil 
                  informativeTextWithFormat: @"Can't create CCNModel from %@", filepath] runModal];
         }];
    }
    else
    {
        self.model = newModel;
    }
}

- (void) revertToSavedProject
{
    if (self.model.projectFilePath)
    {
        [self loadProject: self.model.projectFilePath];
    }
}

- (BOOL) canRevertToSavedProject
{
    if (self.model.projectFilePath)
    {
        // TODO: change to bundle.
        return [[NSFileManager defaultManager] fileExistsAtPath: self.model.projectFilePath];
    }
    
    return NO;
}

- (BOOL) canSaveProject
{
    if (self.model.projectFilePath)
    {
        return YES;
    }
    
    return NO;
}

- (void) saveProject
{
    if (self.model.projectFilePath)
    {
        [self.model saveToFile:self.model.projectFilePath];
    }
}

- (void) saveProjectToFile: (NSString *) filepath
{
    if (![filepath length])
    {
        return;
    }
    
    [self.model saveToFile: filepath];
}

#pragma mark Model KVO

- (void) modelUpdatedFromOldOne: (CCNModel *) oldModel
{
    // Register in new.
    [self.model addObserver:self forKeyPath:@"selectedNode" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context: NULL];
    [self.model addObserver:self forKeyPath:@"currentRootNode" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context: NULL];
    
    // Remove in old.
    [oldModel removeObserver: self forKeyPath: @"selectedNode"];
    [oldModel removeObserver: self forKeyPath: @"currentRootNode"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.model)
    {
        if ([keyPath isEqualToString:@"selectedNode"])
        {
            self.scene.selection.targetNode = self.model.selectedNode;
        }
        else if ([keyPath isEqualToString:@"currentRootNode"])
        {
            // Change currentRootNode.
            self.scene.targetNode = self.model.currentRootNode;
            
            // Ensure to have appropriate workspace size for currentRootNode.
            self.glView.workspaceSize = self.model.currentRootNode.contentSize;
            [self.scene updateForScreenReshape];
        }
    }
}

#pragma mark - Edit Menu

#pragma mark Menu Items Validators

// Currently supports only one node.
- (BOOL) canDeleteSelected
{
    return ( self.model.selectedNode != nil );
}

// Currently supports only one node.
- (BOOL) canCopySelectedToPasteboard
{
    return ( self.model.selectedNode != nil );
}

// Currently supports only one node.
- (BOOL) canCutSelectedToPasteboard;
{
    return [self canCopySelectedToPasteboard];
}

- (BOOL) canPasteFromPasteboard
{
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    NSDictionary *options = [NSDictionary dictionary];
    return [generalPasteboard canReadObjectForClasses:[NSArray arrayWithObject:[CCNode class]] options:options];
}

#pragma mark Menu Items Callbacks

- (void) deleteSelected
{
    [self.model removeNode: self.model.selectedNode];
}

// Currently supports only one node.
- (void)cutSelectedToPasteboard
{
    [self copySelectedToPasteboard];
    [self.model removeNode: self.model.selectedNode];
}

// Currently supports copying only one node.
- (void)copySelectedToPasteboard
{
    // write selected node to pasteboard.
	NSArray *objectsToCopy = [NSArray arrayWithObject: self.model.selectedNode];
	if (objectsToCopy)
	{
		NSPasteboard *pasteboard = [NSPasteboard generalPasteboard];
		[pasteboard clearContents];		
		
		if (![pasteboard writeObjects:objectsToCopy] )
		{
			DebugLog(@"Error writing to pasteboard, sprites = %@", objectsToCopy);
		}
	}
}

// Currently supports pasting only nodes.
- (void)pasteFromPasteboard
{
    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    NSDictionary *options = [NSDictionary dictionary];
    
    NSArray *newNodes = [generalPasteboard readObjectsForClasses:[NSArray arrayWithObject:[CCNode class]] options:options];
	
	for(CCNode *node in newNodes)
	{
        [self addNode:node withUniqueNameFromName: nil];
	}
}

#pragma mark - Import

- (NSArray *) allowedImageFileTypes
{
	return [NSArray arrayWithObjects:@"png", @"gif", @"jpg", @"jpeg", @"tif", @"tiff", @"bmp", @"ccz", @"pvr", nil];
}

- (NSArray *) filterFiles: (NSArray *) files withAllowedFileTypes: (NSArray *) allowedFileTypes
{
	NSMutableArray *filteredFiles = [NSMutableArray arrayWithCapacity:[files count]];
	
	for (NSString *file in files)
	{
		if ( ![file isKindOfClass:[NSString class]] )
			continue;
		
		NSString *curFileExtension = [file pathExtension];
		
		for (NSString *fileType in allowedFileTypes )
		{
			if ([fileType isEqualToString: curFileExtension])
			{
				[filteredFiles addObject:file];
				break;
			}
		}
	}
	
	return filteredFiles;
}

- (void) addNode: (CCNode *) aNode withUniqueNameFromName: (NSString *) name
{
    // Use name if it's given, or aNode.name, or aNode.className.
    if (!name)
    {
        name = aNode.name;
        if (!name)
        {
            name = [aNode className];
        }
    }
    // Make name unique.
    name = [CCNode uniqueNameWithName: name];
    aNode.name = name;
    
    // Choose parent.
    CCNode *newParent = self.model.selectedNode;
    if (!newParent)
    {
        newParent = self.model.currentRootNode;
    }
    
    if ([newParent canBecomeParentOf: aNode])
    {
        // Add on top of rootNode.
        CCNode *lastChild = [newParent.children lastObject];
        int lastChildZ = lastChild.zOrder;
        [newParent addChild:aNode z:lastChildZ];
    }
    else
    {
        // TODO: check if newParent is CCSPriteBAtchNode with another texture.
        // If that CCSPriteBAtchNode has parent - add sprite to batchNode's parent
        // and register warrning.
        
        // TODO: register problem.
    }

}

- (void)importSpritesWithFiles: (NSArray *) filenames
{
    NSArray *imageFilenames = [self filterFiles:filenames withAllowedFileTypes:[self allowedImageFileTypes]];
    
	for(NSString *filename in imageFilenames)
	{
        NSString *originalName = [filename lastPathComponent];
        
        @try 
        {
            // Create sprite with unique name.
            CCNode *sprite = [CCSprite spriteWithFile:filename];            
            [self addNode: sprite withUniqueNameFromName: originalName];
        }
        @catch (NSException *exception) 
        {
            // TODO: register problem instead of NSAlert.
            [NSAlert alertWithMessageText: @"Error adding sprite!" 
                            defaultButton: @"OK" 
                          alternateButton: nil 
                              otherButton: nil 
                informativeTextWithFormat: @"Can't add sprite with file: %@, got an exception: %@", originalName, exception];
        }        
	} //< for filename in files.
}

#pragma mark - Drag & Drop

- (NSArray *) ccnMacGLViewSupportedDraggedTypes: (CCNMacGLView *) glView
{
    return [NSArray arrayWithObjects:  NSFilenamesPboardType, nil];
}

- (NSDragOperation)ccnMacGLView: (CCNMacGLView *) glView draggingEntered:(id <NSDraggingInfo>)sender 
{	
	NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) 
	{
        if (sourceDragMask & NSDragOperationLink) 
		{
            return NSDragOperationLink;
		}
    }
    return NSDragOperationNone;
}

// XXX: support drag & drop of things inside Coconade.
// XXX: support .coconade bundle & AMC nodes files to be dropped in glView.
- (BOOL)ccnMacGLView: (CCNMacGLView *) glView performDragOperation:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    // Files.
    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		
        if (sourceDragMask & NSDragOperationLink) 
		{			
            // Import sprites safely on Cocos2D-iPhone thread.
            [self performBlockOnCocosThread: ^()
             {
                 [self importSpritesWithFiles: files];
             }];
        }
    }
    
    return YES;
}

#pragma mark - Events

/** Returns node in current hierarchy, that correpsonds to given event's location.
 * If there's no such node for given event - returns nil.
 */
- (CCNode *)nodeForEvent:(NSEvent *)event
{
    for (CCNode *node in self.model.currentNodes)
    {
        if ( [CCNode isEvent:event locatedInNode:node] )
            return node;
    }
    
    return nil;
}

- (void) registerWithEventDispatcher
{
    [[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority: NSIntegerMin];
	[[CCEventDispatcher sharedDispatcher] addKeyboardDelegate:self priority: NSIntegerMin];
    [[CCEventDispatcher sharedDispatcher] addGestureDelegate:self priority: NSIntegerMin];
}

- (void) unregisterWithEventDispatcher
{
    [[CCEventDispatcher sharedDispatcher] removeMouseDelegate:self];
    [[CCEventDispatcher sharedDispatcher] removeKeyboardDelegate:self];
    [[CCEventDispatcher sharedDispatcher] removeGestureDelegate:self];
}

#pragma mark Trackpad Gestures Events

/** Trackpad's PinchIn/PinchOut Gesture event handler
 * Scales selectedNode.
 */
- (BOOL)ccMagnifyWithEvent:(NSEvent *)event
{
	CCNode *node = self.model.selectedNode;
	if (node)
	{
        // Get new scale from current and diff.
		float newScaleX = node.scaleX + [event magnification];
		float newScaleY = node.scaleY + [event magnification];
		
		// Round to nearest hundredth.
		newScaleX = roundf(newScaleX * 100.0f)/100.0f;
		newScaleY = roundf(newScaleY * 100.0f)/100.0f;
		
        // Set new scale.
        node.scaleX = newScaleX;
        node.scaleY = newScaleY;
        
        return YES;
	}
    
    return NO;
}

/** Trackpad's TwoFingerRotate Gesture event handler.
 * Rotates selectedNode.
 */
- (BOOL)ccRotateWithEvent:(NSEvent *)event
{
	CCNode *node = self.model.selectedNode;
	if (node)
	{
        // Subtract event rotation, cause it's CCW (Node's rotation is CW).
		float newRotation = node.rotation - [event rotation];
		
		// Stay in [0; 360]  range.
        newRotation = fmodf(newRotation, 360.0f);
		if (newRotation < 0)
        {
			newRotation += 360;
        }        
		
		// Discard the frational part.
		newRotation = roundf(newRotation);
		
        // Set new rotation.
		node.rotation = newRotation;
        
        return YES;
	}
    
    return NO;
}

#pragma mark Mouse Events

-(BOOL) ccScrollWheel:(NSEvent *)theEvent 
{    
	// Zoom
	if ( [theEvent modifierFlags] & NSCommandKeyMask )
	{
        [self performBlockOnMainThread:^()
         {
             self.glView.zoomFactor += [theEvent deltaY] * self.glView.zoomSpeed;
         }];
		
		return YES;
	}
	
	// Or Scroll
    [ self performBlockOnMainThread:^()
     {
         [[self.glView enclosingScrollView] scrollWheel: theEvent];	
     }];
	
    return YES;
}

- (BOOL)ccMouseDown:(NSEvent *)event
{
	_deselectNodeOnMouseUp = NO;
	_moveNodeOnMouseDrag = NO;
	
	CCNode *node = [self nodeForEvent:event];
	if(node)
	{
		// If this isn't the selected sprite - select it.
		if(self.model.selectedNode != node)
        {
			self.model.selectedNode = node;
        }
		else 
        {
            // Prepare to deselect it.
			_deselectNodeOnMouseUp = YES;
        }
		
		_moveNodeOnMouseDrag = YES;
	}
	
	// If we touched outside of selected sprite, deselect it
	if(self.model.selectedNode != node)
	{
		self.model.selectedNode = nil;
	}
	
    // Remember previous mouse location to move node.
	_prevMouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	
	return YES;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{
	// Don't deselect nodes on mouse drag.
	_deselectNodeOnMouseUp = NO;
	
	CGPoint mouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	
	// Move the node if needed.
    CCNode *node = self.model.selectedNode;
	if(_moveNodeOnMouseDrag && node)
	{
        CGPoint diff = ccpSub(mouseLocation, _prevMouseLocation);
        
        // Calculate new position, considering that it can be located anywhere in the hierarchy.
        CGPoint newPosition = node.position;
        if (node.parent)
        {        
            CGPoint nodePositionInScene = CGPointApplyAffineTransform(node.position, [node.parent nodeToWorldTransform]);
            CGPoint newPositionInScene = ccpAdd(nodePositionInScene, diff);
            newPosition = CGPointApplyAffineTransform( newPositionInScene, [node.parent worldToNodeTransform]);
        }
        else
        {
            newPosition = ccpAdd(node.position, diff);
        }
        
        // Apply new position.
        node.position = newPosition;
	}
	
    // Remember previous mouse location to move node.
	_prevMouseLocation = mouseLocation;
	
	return YES;
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
	// Deselect node if planned.
	if(_deselectNodeOnMouseUp)
	{
		self.model.selectedNode = nil;
	}
	
    // Remember previous mouse location to move node.
	_prevMouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	
	return YES;
}

#pragma mark Keyboard Events

- (BOOL)ccKeyDown:(NSEvent *)event
{
	NSUInteger modifiers = [event modifierFlags];
	unsigned short keyCode = [event keyCode];
    
    CCNode *node = self.model.selectedNode;
	
	// Deleting nodes from hierarchy.
	switch(keyCode)
	{
		case kCCNKeyCodeBackspace:
		case kCCNKeyCodeDelete:
			[self.model removeNode: node];
			return YES;
		default:
			break;
	}
	
	// If option/alt key is pressed - move anchor point with arrow keys.
	if(modifiers & NSAlternateKeyMask)
	{
		CGFloat increment = (modifiers & NSShiftKeyMask) ? kCCNIncrementAnchorBig : kCCNIncrementAnchorDefault;
		
		switch(keyCode)
		{
			case kCCNKeyCodeLeftArrow:
                node.anchorPoint = ccp( node.anchorPoint.x - increment, node.anchorPoint.y );
				return YES;
			case kCCNKeyCodeRightArrow:
				node.anchorPoint = ccp( node.anchorPoint.x + increment, node.anchorPoint.y );
				return YES;
			case kCCNKeyCodeDownArrow:
				node.anchorPoint = ccp( node.anchorPoint.x, node.anchorPoint.y - increment );
				return YES;
			case kCCNKeyCodeUpArrow:
				node.anchorPoint = ccp( node.anchorPoint.x, node.anchorPoint.y + increment );
				return YES;
			default:
				return NO;
		}		
	}
	else if (modifiers & NSControlKeyMask) //< If ctrl key is pressed - rotate sprite.
	{
		CGFloat increment = (modifiers & NSShiftKeyMask) ? kCCNIncrementRotationBig : kCCNIncrementRotationDefault;
		
		switch(keyCode)
		{
			case kCCNKeyCodeLeftArrow:
				node.rotation -= increment;
				return YES;
			case kCCNKeyCodeRightArrow:
				node.rotation += increment;
				return YES;
			default:
				return NO;
		}
	}
	else //< No ALT/Option nor CTRL pressed - move node with arrows & change it's zOrder with PgUp/PgDown.
	{
		NSInteger positionIncrement = (modifiers & NSShiftKeyMask) ? kCCNIncrementPositionBig : kCCNIncrementPositionDefault;
	    NSInteger zOrderIncrement = (modifiers & NSShiftKeyMask) ? kCCNIncrementZOrderBig : kCCNIncrementZOrderDefault; 
        
		switch(keyCode)
		{
			case kCCNKeyCodeLeftArrow:
				node.position = ccp( node.position.x - positionIncrement, node.position.y );
				return YES;
			case kCCNKeyCodeRightArrow:
				node.position = ccp( node.position.x + positionIncrement, node.position.y );
				return YES;
			case kCCNKeyCodeDownArrow:
				node.position = ccp( node.position.x, node.position.y - positionIncrement );
				return YES;
			case kCCNKeyCodeUpArrow:
				node.position = ccp( node.position.x, node.position.y + positionIncrement );
				return YES;
			case kCCNKeyCodePageUp:
                if (node.parent)
                {
                    [node.parent reorderChild:node z:node.zOrder + zOrderIncrement];
                }
                else
                {
                    [node setValue:[NSNumber numberWithInteger: node.zOrder + zOrderIncrement] forKey:@"zOrder_"];
                }
				
				return YES;
			case kCCNKeyCodePageDown:
				if (node.parent)
                {
                    [node.parent reorderChild:node z:node.zOrder - zOrderIncrement];
                }
                else
                {
                    [node setValue:[NSNumber numberWithInteger: node.zOrder - zOrderIncrement] forKey:@"zOrder_"];
                }
				return YES;
			default:
				return NO;
		}
	}
	
	return NO;
}

@end

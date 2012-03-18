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
#import "NSCursor+CustomCursors.h"

/** Size for extending work area around scale elements of CCNSelection. */
#define kCCNWorkspaceControllerScaleElementExtension() CGSizeMake(6.0f, 6.0f)

/** Current state of selection that is being used by mouse events.
 * Describes what will be done on -ccMouseDrag: event. 
 */
enum workspaceMouseState 
{
    
    kCCNWorkspaceMouseStateIdle,
    
    // Moving with mouse.
    kCCNWorkspaceMouseStateMove,
    kCCNWorkspaceMouseStateDragAnchor,
    
    // Scaling with mouse
    kCCNWorkspaceMouseStateScaleTop,
    kCCNWorkspaceMouseStateScaleBottom,
    kCCNWorkspaceMouseStateScaleRight,
    kCCNWorkspaceMouseStateScaleLeft,
    kCCNWorkspaceMouseStateScaleTopRight,
    kCCNWorkspaceMouseStateScaleTopLeft,
    kCCNWorkspaceMouseStateScaleBottomRight,
    kCCNWorkspaceMouseStateScaleBottomLeft,
    
    // Rotating with mouse.
    kCCNWorkspaceMouseStateRotateTopRight,
    kCCNWorkspaceMouseStateRotateTopLeft,
    kCCNWorkspaceMouseStateRotateBottomRight,
    kCCNWorkspaceMouseStateRotateBottomLeft,
    
    // Skewing with mouse.
    kCCNWorkspaceMouseStateSkewTop,
    kCCNWorkspaceMouseStateSkewBottom,
    kCCNWorkspaceMouseStateSkewRight,
    kCCNWorkspaceMouseStateSkewLeft,
    
    // Ranges to detect groups of state.
    kCCNWorkspaceMouseStateScaleFirst = kCCNWorkspaceMouseStateScaleTop,
    kCCNWorkspaceMouseStateScaleLast = kCCNWorkspaceMouseStateScaleBottomLeft,
    
    kCCNWorkspaceMouseStateRotateFirst = kCCNWorkspaceMouseStateRotateTopRight,
    kCCNWorkspaceMouseStateRotateLast = kCCNWorkspaceMouseStateRotateBottomLeft,
    
    kCCNWorkspaceMouseStateSkewFirst = kCCNWorkspaceMouseStateSkewTop,
    kCCNWorkspaceMouseStateSkewLast = kCCNWorkspaceMouseStateSkewLeft,
};

@interface CCNWorkspaceController ()

#pragma mark Edit Nodes with Mouse

/** Holds node, on that we received -ccMouseDown: event last time.
 * Used to store that node between down, moved/dragged & up mouse events.
 */
@property(readwrite, retain) CCNode *nodeBeingEdited;

/** Updates cursor to the one that is corresponding to current mouse state
 * (Location & Pressed Buttons).
 * All info about mouse is get through NSEvent class methods (+mouseLocation, +pressedMouseButtons, etc).
 * So there's no arguments for this method.
 * 
 * Call this method anytime when cursor can be changed (i.e. adding node, rotating node, selecting node, etc).
 */
- (void) updateCursor;

/** Changes anchor point of given node with given mouse event, without changing 
 * absolute position (or boundingBox) of that node.
 *
 * Uses mouseLocation from event & _prevMouseLocation from self.
 *
 * @param targetNode Node in current hierarchy that's anchorPoint must be changed.
 *
 * @param event NSEvent from -mouseDragged: callback.
 */
- (void) dragAnchorOfTargetNode: (CCNode *) targetNode withMouseDraggedEvent:(NSEvent *)event;

/** Moves at leas one of the selected nodes with given mouse event.
 * If all selected nodes have the same parent - all selected nodes will be moved,
 * otherwise only _nodeBeingEdited will be moved (@see nodeBeingEdited property).
 *
 * Uses mouseLocation from event, _prevMouseLocation & _nodeBeingDragged from self.
 *
 * @param event NSEvent from -mouseDragged: callback.
 */
- (void) moveSelectedNodesWithMouseDraggedEvent: (NSEvent *) event;

#pragma mark Model

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

#pragma mark Events Support

/** Returns node in current hierarchy, that correpsonds to given location in screen coordinates.
 * If there's no such node for given screen point - returns nil.
 */
- (CCNode *) nodeForScreenPoint: (NSPoint) screenPoint;

/** Returns selected node in current hierarchy, that correpsonds to given location in screen coordinates.
 * If there's no such node for given screen point or it's not selected - returns nil.
 * This method looks up only in selectedNodes, so if you're looking for selectedNode -
 * use it instead of -nodeForScreenPoint.
 */
- (CCNode *) selectedNodeNearScreenPoint: (NSPoint) screenPoint;

/** Searches through selected nodes to fine the one, that have anchorPoint indicator
 * near given screenPoint.
 *
 * @return Finded selected node with such anchorPoint or nil otherwise.
 */
- (CCNode *) selectedNodeWithAnchorPointNearScreenPoint:(NSPoint) screenPoint;

/** Searches through selected nodes to find the one, that have given element located near given screenPoint.
 * @see -selectedNodeWithElement:nearScreenPoint:withAreaExtension:
 */
- (CCNode *) selectedNodeWithElement: (CCNSelectionElementType) elementType nearScreenPoint:(NSPoint) screenPoint;

/** Searches through selected nodes to find the one, that have given element
 * (one of the squares at sides center or corners) located near given screenPoint.
 *
 * @param areaExtension Size, that describes how much area around the element should be extendend.
 * Half of each component of that size is added to elements contentSize from each side.
 *
 * @return Finded selected node with such element or nil otherwise.
 */
- (CCNode *) selectedNodeWithElement: (CCNSelectionElementType) elementType nearScreenPoint:(NSPoint) screenPoint withAreaExtension: (CGSize) areaExtension;

/** Searches through current CCNSelection nodes to find the one, that have given element
 * (one of the squares at sides center or corners) located near given screenPoint.
 *
 * @param areaExtension Size, that describes how much area around the element should be extendend.
 * Half of each component of that size is added to elements contentSize from each side.
 *
 * @return Finded selection with such element or nil otherwise.
 * Can be used instead of -selectedNodeWithElement:nearScreenPoint:withAreaExtensions:
 * when you need both CCNSelection and it's targetNode.
 */
- (CCNSelection *) selectionNodeWithElement: (CCNSelectionElementType) elementType nearScreenPoint:(NSPoint) screenPoint withAreaExtension: (CGSize) areaExtension;

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
@synthesize nodeBeingEdited = _nodeBeingEdited;

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

- (void) registerWithEventDispatcher
{
    [[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority: NSIntegerMin+1];
	[[CCEventDispatcher sharedDispatcher] addKeyboardDelegate:self priority: NSIntegerMin+1];
    [[CCEventDispatcher sharedDispatcher] addGestureDelegate:self priority: NSIntegerMin+1];
}

- (void) unregisterWithEventDispatcher
{
    [[CCEventDispatcher sharedDispatcher] removeMouseDelegate:self];
    [[CCEventDispatcher sharedDispatcher] removeKeyboardDelegate:self];
    [[CCEventDispatcher sharedDispatcher] removeGestureDelegate:self];
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
    [self.model addObserver:self forKeyPath:@"selectedNodes" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context: NULL];
    [self.model addObserver:self forKeyPath:@"currentRootNode" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial context: NULL];
    
    // Remove in old.
    [oldModel removeObserver: self forKeyPath: @"selectedNodes"];
    [oldModel removeObserver: self forKeyPath: @"currentRootNode"];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.model)
    {
        if ([keyPath isEqualToString:@"selectedNodes"])
        {
            [self.scene removeAllNodesSelections];
            for (CCNode *node in self.model.selectedNodes)
            {
                [self.scene addNodeToSelection: node];
            }
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
    
    // Update cursor on any model update - new model, new added node, changed selection, etc...
    [self updateCursor];
}

#pragma mark - Edit Menu

#pragma mark Menu Items Validators

// Currently supports only one node.
- (BOOL) canDeleteSelected
{
    return ( [self.model.selectedNodes count] );
}

// Currently supports only one node.
- (BOOL) canCopySelectedToPasteboard
{
    return ( [self.model.selectedNodes count] );
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
    NSArray *selectedNodes = [self.model.selectedNodes copy];
    for (CCNode *node in selectedNodes )
    {
        [self.model removeNode: node];
    }
    [selectedNodes release];
}

// Currently supports only one node.
- (void)cutSelectedToPasteboard
{
    [self copySelectedToPasteboard];
    [self deleteSelected];
}

// Currently supports copying only one node.
- (void)copySelectedToPasteboard
{
    // write selected node to pasteboard.
	NSArray *objectsToCopy = [NSArray arrayWithArray: self.model.selectedNodes];
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
    
    // Select only newly added nodes.
    [self.model deselectAllNodes];
    for (CCNode *node in newNodes)
    {
        [self.model selectNode:node];
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
            name = [aNode defaultName];            
        }
    }
    // Make name unique.
    name = [aNode uniqueNameWithName: name];
    aNode.name = name;
    
    // Choose parent. Use only one selected node as parent.
    CCNode *newParent = nil;    
    if ([self.model.selectedNodes count] == 1)
    {
        newParent = [self.model.selectedNodes objectAtIndex: 0];
    }
    else
    {
        // Use currentRootNode as parrent.
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

    // Update cursors when adding nodes.
    // XXX: later when we will KVO currentNodes in model - this should be moved there.
    [self updateCursor];
}

- (void)importSpritesWithFiles: (NSArray *) filenames withPositionInScene: (CGPoint) positionInScene
{
    NSArray *imageFilenames = [self filterFiles:filenames withAllowedFileTypes:[self allowedImageFileTypes]];
    
    CGPoint newPositionInScene = positionInScene;
    CGPoint positionShift = ccp(10,10);
	for(NSString *filename in imageFilenames)
	{
        NSString *originalName = [filename lastPathComponent];
        
        @try 
        {
            // Create sprite with unique name.
            CCNode *sprite = [CCSprite spriteWithFile:filename];            
            [self addNode: sprite withUniqueNameFromName: originalName];
            
            // Reposition sprite where desired.
            if (sprite.parent)
            {        
                sprite.position = CGPointApplyAffineTransform( newPositionInScene, [sprite.parent worldToNodeTransform]);
            }
            
            // Increment position for next sprite.
            newPositionInScene = ccpAdd(newPositionInScene, positionShift);
            
            // TODO: select all imported files, deselect any previous.
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
            // Get position of drag operation in scene coordinates.
            CGPoint p = NSPointToCGPoint([self.glView convertPoint:[sender draggingLocation] fromView:nil]);
            p = [(CCDirectorMac *)[CCDirector sharedDirector] convertToLogicalCoordinates: p];
            
            
            // Import sprites safely on Cocos2D-iPhone thread.
            [self performBlockOnCocosThread: ^()
             {                 
                 [self importSpritesWithFiles: files withPositionInScene:p];
             }];
        }
    }
    
    return YES;
}

#pragma mark - Events

- (CCNode *) nodeForScreenPoint: (NSPoint) screenPoint
{
    for (CCNode *node in self.model.currentNodes)
    {
        if ( [CCNode isScreenPoint:screenPoint locatedInNode:node] )
            return node;
    }
    
    return nil;
}

#pragma mark - Trackpad Gestures Events

/** Trackpad's PinchIn/PinchOut Gesture event handler
 * Scales selectedNode.
 */
- (BOOL)ccMagnifyWithEvent:(NSEvent *)event
{
    BOOL result = NO;
    
	for (CCNode *node in self.model.selectedNodes)
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
        
        result = YES;
	}
    
    [self updateCursor];
    
    return result;
}

/** Trackpad's TwoFingerRotate Gesture event handler.
 * Rotates selectedNode.
 * On ALT - skews selectedNode in X dimension.
 * On ALT + CTRL - skews selectedNode in Y dimension.
 */
- (BOOL)ccRotateWithEvent:(NSEvent *)event
{
    BOOL result = NO;
    
	for (CCNode *node in self.model.selectedNodes)
	{
        CGFloat initialValue = node.rotation;
        NSString *propertyKey = @"rotation";
        
        // SkewX on ALT pressed.
        if ( [NSEvent modifierFlags] & NSAlternateKeyMask )
        {
            // SkewY
            if ([NSEvent modifierFlags] & NSControlKeyMask)
            {
                initialValue = node.skewY;
                propertyKey = @"skewY";
            }
            else 
            {
                initialValue = node.skewX;
                propertyKey = @"skewX";
            }
        }
        
        // Subtract event rotation, cause it's CCW (Node's rotation is CW).
		float newRotation = initialValue - [event rotation];
		
		// Stay in [0; 360]  range.
        newRotation = fmodf(newRotation, 360.0f);
		if (newRotation < 0)
        {
			newRotation += 360;
        }
		
        // Set new rotation/skew.
		NSNumber *newValueNumber = [NSNumber numberWithFloat: newRotation];
        [node setValue:newValueNumber forKey:propertyKey];
        
        result = YES;
	}
    
    [self updateCursor];
    
    return result;
}

#pragma mark - Mouse Events

- (CCNode *) selectedNodeNearScreenPoint: (NSPoint) screenPoint
{
    for ( CCNode *node in self.model.selectedNodes )
    {
        if ([CCNode isScreenPoint:screenPoint locatedInNode:node])
        {
            return node;
        }
    }
    
    return nil;
}

- (CCNode *) selectedNodeWithAnchorPointNearScreenPoint:(NSPoint) screenPoint 
{
    for ( CCNode *node in self.model.selectedNodes )
    {
        CCNSelection *selection = [self.scene selectionForNode: node];
        CCNode *anchorPointIndicator = selection.anchorPointIndicator;
        if ([CCNode isScreenPoint:screenPoint locatedInNode:anchorPointIndicator])
        {
            return node;
        }
    }
    
    return nil;
}

- (CCNode *) selectedNodeWithElement: (CCNSelectionElementType) elementType nearScreenPoint:(NSPoint) screenPoint
{
    return [self selectedNodeWithElement:elementType nearScreenPoint:screenPoint withAreaExtension: CGSizeZero];
}

- (CCNode *) selectedNodeWithElement: (CCNSelectionElementType) elementType nearScreenPoint:(NSPoint) screenPoint withAreaExtension: (CGSize) areaExtension
{
    for ( CCNode *node in self.model.selectedNodes )
    {
        CCNSelection *selection = [self.scene selectionForNode: node];
        CCNode *element = [selection elementNodeWithType: elementType];
        if ([CCNode isScreenPoint:screenPoint locatedInNode:element withAreaExtension:areaExtension])
        {
            return node;
        }
    }
    
    return nil;
}

- (CCNSelection *) selectionNodeWithElement: (CCNSelectionElementType) elementType nearScreenPoint:(NSPoint) screenPoint withAreaExtension: (CGSize) areaExtension
{
    for ( CCNode *node in self.model.selectedNodes )
    {
        CCNSelection *selection = [self.scene selectionForNode: node];
        CCNode *element = [selection elementNodeWithType: elementType];
        if ([CCNode isScreenPoint:screenPoint locatedInNode:element withAreaExtension:areaExtension])
        {
            return selection;
        }
    }
    
    return nil;
}

- (BOOL) isScreenPoint:(NSPoint) screenPoint locatedNearAnchorPointOfSelectedNode: (CCNode *) node 
{
    if (!node)
    {
        return NO;
    }
    
    CCNSelection *selection = [self.scene selectionForNode: node];
    CCNode *anchorPointIndicator = selection.anchorPointIndicator;
    if ([CCNode isScreenPoint:screenPoint locatedInNode:anchorPointIndicator])
    {
        return YES;
    }
    
    return NO;
}

- (void) updateCursor
{
    // Prepare variables.
    NSPoint mouseLocationInScreen = [NSEvent mouseLocation];
    NSUInteger mouseButtons = [NSEvent pressedMouseButtons];
    
    CGSize elementExtension = kCCNWorkspaceControllerScaleElementExtension();
    
    /** Chooses & sets cursor for scaling, depending on node rotation to fit better. */
    void(^setScaleCursor)(CCNode *, CGFloat) = ^(CCNode *nodeAtCursor, CGFloat originalCursorRotation)
    {
        // Prepare node rotation to use right scale cursors even when node is rotated.
        CGFloat nodeAtCursorRotation = 0;
        if (nodeAtCursor)
        {
            CGAffineTransform transform = [nodeAtCursor nodeToWorldTransform];
            nodeAtCursorRotation = CC_RADIANS_TO_DEGREES( -atanf(transform.b / transform.a) );
        }
        
        [[NSCursor resizeCursorWithAngle: originalCursorRotation - nodeAtCursorRotation] set];
    };
    
    /** Checks if there's any selectedNode with givenElement type near mouse
     * & sets nodeAtCursor to it & selectionForNodeAtCursor to it's selection if found.
     *
     * @param elementType CCNSelectionElementType that will be used to find 
     * selectedNode.
     *
     * @return CCNselection of selectedNode if it was found, NO otherwise.
     */
    __block CCNode *nodeAtCursor = nil;
    __block CCNSelection *selectionForNodeAtCursor = nil;
    CCNSelection *(^selection)(CCNSelectionElementType) = 
    ^(CCNSelectionElementType elementType)
    {
        selectionForNodeAtCursor = [self selectionNodeWithElement: elementType
                                                             nearScreenPoint: mouseLocationInScreen 
                                                           withAreaExtension: elementExtension];
        nodeAtCursor = selectionForNodeAtCursor.targetNode;
        return selectionForNodeAtCursor;
    };
       
    // Choose cursor setter block.
    void (^setCursorBlock)() = nil;
    if ( _mouseState == kCCNWorkspaceMouseStateDragAnchor || [self selectedNodeWithAnchorPointNearScreenPoint: mouseLocationInScreen])
    {
        // If we moving cursor near anchor indicator of selected node - change cursor for dragging it.
        setCursorBlock = ^ { [[NSCursor crosshairCursor] set]; };
    }
    else 
    {
        // If we're moving cursor near elements of selection - use corresponding scale cursor.        
        if ( selection(kCCNSelectionElementTypeTop) 
            || (selection(kCCNSelectionElementTypeBottom))
            || _mouseState == kCCNWorkspaceMouseStateScaleTop 
            || _mouseState == kCCNWorkspaceMouseStateScaleBottom
            || _mouseState == kCCNWorkspaceMouseStateSkewTop 
            || _mouseState == kCCNWorkspaceMouseStateSkewBottom)
        {        
            if (selectionForNodeAtCursor.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
                setCursorBlock = ^{ [[NSCursor skewCursorHorizontal] set]; };
            else
                setCursorBlock = ^{ setScaleCursor(nodeAtCursor, 90); };
        } 
        else if (selection(kCCNSelectionElementTypeLeft)
                 || selection(kCCNSelectionElementTypeRight)
                 || _mouseState == kCCNWorkspaceMouseStateScaleLeft
                 || _mouseState == kCCNWorkspaceMouseStateScaleRight
                 || _mouseState == kCCNWorkspaceMouseStateSkewLeft
                 || _mouseState == kCCNWorkspaceMouseStateSkewRight)
        {
            if (selectionForNodeAtCursor.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
                setCursorBlock = ^{ [[NSCursor skewCursorVertical] set]; };
            else
                setCursorBlock = ^ { setScaleCursor(nodeAtCursor, 0); };
        }
        else if ( selection(kCCNSelectionElementTypeTopLeft)
                 || selection(kCCNSelectionElementTypeBottomRight)
                 || _mouseState == kCCNWorkspaceMouseStateScaleTopLeft
                 || _mouseState == kCCNWorkspaceMouseStateScaleBottomRight
                 || _mouseState == kCCNWorkspaceMouseStateRotateTopLeft
                 || _mouseState == kCCNWorkspaceMouseStateRotateBottomRight)
        {
            if (selectionForNodeAtCursor.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
                setCursorBlock = ^{ [[NSCursor rotationCursor] set]; };
            else
                setCursorBlock = ^{ setScaleCursor(nodeAtCursor, 135); };
        }
        else if ( selection(kCCNSelectionElementTypeTopRight)
                 || selection(kCCNSelectionElementTypeBottomLeft)
                 || _mouseState == kCCNWorkspaceMouseStateScaleTopRight
                 || _mouseState == kCCNWorkspaceMouseStateScaleBottomLeft
                 || _mouseState == kCCNWorkspaceMouseStateRotateTopRight
                 || _mouseState == kCCNWorkspaceMouseStateRotateBottomLeft)
        {
            if (selectionForNodeAtCursor.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
                setCursorBlock = ^{ [[NSCursor rotationCursor] set]; };
            else
                setCursorBlock = ^{ setScaleCursor(nodeAtCursor, 45); };
        }
        else if ([self nodeForScreenPoint: mouseLocationInScreen])
        {
            // If we moving cursor on node, but not near selection element nor anchorPointIndicator.
            if ( mouseButtons & 1 && _mouseState == kCCNWorkspaceMouseStateMove )
            {
                setCursorBlock = ^{ [[NSCursor closedHandCursor] set]; };
            }
            else
            {
                setCursorBlock = ^{ [[NSCursor openHandCursor] set]; };
            }
        }    
        else
        {
            // Nothing interesting - use standard arrow.        
            setCursorBlock = ^{ [[NSCursor arrowCursor] set]; };
        }
    }
    
    // Set cursor with chosen seter block.
    [self performBlockOnMainThread: setCursorBlock ];
}

- (void)dragAnchorOfTargetNode: (CCNode *) targetNode withMouseDraggedEvent:(NSEvent *)event
{	    
    CGPoint mouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
    
    // Prepare affine transformations here once.
    CGAffineTransform targetParentToWorld = [targetNode.parent nodeToWorldTransform];
    CGAffineTransform worldToTargetParent = CGAffineTransformInvert(targetParentToWorld);
    CGAffineTransform targetToWorld = CGAffineTransformConcat([targetNode nodeToParentTransform], targetParentToWorld);
    CGAffineTransform worldToTarget = CGAffineTransformInvert(targetToWorld);
    
    // Get old anchor position in scene.
    CGSize targetSize = targetNode.contentSize;
    CGPoint oldAnchor = targetNode.anchorPoint;
    CGPoint oldAnchorInPoints = ccp(oldAnchor.x * targetSize.width, oldAnchor.y * targetSize.height);
    CGPoint oldAnchorInScene = CGPointApplyAffineTransform(oldAnchorInPoints, targetToWorld);
    
    // Get new position of anchor in scene coordinates.
    CGPoint diff = ccpSub(mouseLocation, _prevMouseLocation);
    CGPoint anchorPositionInScene = ccpAdd(oldAnchorInScene, diff);        
    
    // Set new anchor normalized.
    CGPoint newAnchorInPoints = CGPointApplyAffineTransform(anchorPositionInScene, worldToTarget);
    CGPoint newAnchor = ccp( newAnchorInPoints.x / targetSize.width, newAnchorInPoints.y / targetSize.height);
    targetNode.anchorPoint = newAnchor;
    
    // Compensate position change.       
    CGPoint positionCompensation = ccpSub(anchorPositionInScene, oldAnchorInScene);
    CGPoint targetPositionInScene =  CGPointApplyAffineTransform(targetNode.position, targetParentToWorld);
    targetPositionInScene = ccpAdd(targetPositionInScene, positionCompensation);
    targetNode.position = CGPointApplyAffineTransform(targetPositionInScene, worldToTargetParent);
    
}

- (void) moveSelectedNodesWithMouseDraggedEvent: (NSEvent *) event
{
    CGPoint mouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
    
    // Choose which nodes to drag - all selected nodes by default.
    NSArray *nodesToMove = self.model.selectedNodes;
    
    // But if they have different parents - choose only one that was under cursor, when dragging started.
    NSUInteger selectedNodesCount = [self.model.selectedNodes count];
    if (selectedNodesCount)
    {
        CCNode *firstNode = [self.model.selectedNodes objectAtIndex: 0];
        CCNode *parent = firstNode.parent;
        for (CCNode *node in self.model.selectedNodes)
        {
            if (parent != node.parent)
            {
                nodesToMove = [NSArray arrayWithObject: self.nodeBeingEdited];
                break;
            }
        }
    }
    
    // Actually drag chosen nodes.
    for (CCNode *node in nodesToMove)
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
}

- (void) scaleTargetNode: (CCNode *) targetNode withMouseDraggedEvent: (NSEvent *) event withState: (int) mouseState
{
    // Don't scale nodes with width = height = 0.
    CGSize targetNodeSize = targetNode.contentSize;
    if ( !targetNodeSize.width && !targetNodeSize.height )
    {
        return;
    }
    
    CGFloat xFactor = 1.0f;
    CGFloat yFactor = 1.0f;
    BOOL keepAspectRatio = NO;
    CGPoint scaleElementPositionInTargetNodeSpace = ccp(0,0);
    
    // Choose direction of scaling.
    switch (mouseState) {
        case kCCNWorkspaceMouseStateScaleTop:
            xFactor = 0;
            yFactor = 1.0f;
            scaleElementPositionInTargetNodeSpace = ccp(0.5f * targetNodeSize.width, 1.0f * targetNodeSize.height);
            break;
            
        case kCCNWorkspaceMouseStateScaleBottom:
            xFactor = 0;
            yFactor = -1.0f;
            scaleElementPositionInTargetNodeSpace = ccp(0.5f * targetNodeSize.width, 0.0f);
            break;
            
        case kCCNWorkspaceMouseStateScaleLeft:
            xFactor = -1.0f;
            yFactor = 0;
            scaleElementPositionInTargetNodeSpace = ccp(0.0f, 0.5f * targetNodeSize.height);
            break;
            
        case kCCNWorkspaceMouseStateScaleRight:
            xFactor = 1.0f;
            yFactor = 0;
            scaleElementPositionInTargetNodeSpace = ccp(1.0f * targetNodeSize.width, 0.5f * targetNodeSize.height);
            break;
            
        case kCCNWorkspaceMouseStateScaleTopLeft:
            xFactor = -1.0f;
            yFactor = 1.0f;
            keepAspectRatio = YES;
            scaleElementPositionInTargetNodeSpace = ccp(0.0f, 1.0f * targetNodeSize.height);
            break;
            
        case kCCNWorkspaceMouseStateScaleTopRight:
            xFactor = 1.0f;
            yFactor = 1.0f;
            keepAspectRatio = YES;
            scaleElementPositionInTargetNodeSpace = ccp(1.0f * targetNodeSize.width, 1.0f * targetNodeSize.height);
            break;
            
        case kCCNWorkspaceMouseStateScaleBottomLeft:
            xFactor = -1.0f;
            yFactor = -1.0f;
            keepAspectRatio = YES;
            scaleElementPositionInTargetNodeSpace = ccp(0.0f, 0.0f);
            break;
            
        case kCCNWorkspaceMouseStateScaleBottomRight:
            xFactor = 1.0f;
            yFactor = -1.0f;
            keepAspectRatio = YES;
            scaleElementPositionInTargetNodeSpace = ccp(1.0f * targetNodeSize.width, 0.0f);
            break;           
            
        default:
            break;
    }
    
    // Get mouse location diff.
    CGPoint mouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
    
    // Prepare affine transformations here once.
    CGAffineTransform worldToTarget = [targetNode worldToNodeTransform];
    
    // Prepare scale change for node.
    CGPoint mouseLocationInTargetNodeSpace = CGPointApplyAffineTransform(mouseLocation, worldToTarget);
    CGPoint mouseAndElementLocationDiffInTargetNodeSpace = ccpSub(mouseLocationInTargetNodeSpace, scaleElementPositionInTargetNodeSpace);
    CGPoint scale = ccp(0, 0);
    if ( targetNodeSize.width )
    {
        scale.x = ( targetNodeSize.width + xFactor * mouseAndElementLocationDiffInTargetNodeSpace.x) / targetNodeSize.width;
    }
    if ( targetNodeSize.height )
    {
        scale.y = ( targetNodeSize.height + yFactor * mouseAndElementLocationDiffInTargetNodeSpace.y) / targetNodeSize.height;
    }
    
    // Use the same (smallest) scale to keep aspect ratio if needed.
    if (keepAspectRatio)
    {
        CGFloat absoluteY = fabsf(scale.y);
        CGFloat absoluteX = fabsf(scale.x);
        
        // Keep sign of scale components, equalise only absolute values of them.
        if ( absoluteX < absoluteY )
        {
            scale.y /= absoluteY;
            scale.y *= absoluteX;
        }
        else
        {
            scale.x /= absoluteX;
            scale.x *= absoluteY;
        }
        
        scale.x = MIN(scale.x, scale.y);
        scale.y = MIN(scale.x, scale.y);
    }
    
    // Apply scale.
    targetNode.scaleX *= scale.x;
    targetNode.scaleY *= scale.y;
}

- (void) rotateTargetNode: (CCNode *) targetNode withMouseDraggedEvent: (NSEvent *) event withState: (int) mouseState
{
    // Don't rotate nodes with width = height = 0.
    // TODO: is it possible to rotate node with width != 0 && height == 0 ?
    CGSize targetNodeSize = targetNode.contentSize;
    if ( !targetNodeSize.width && !targetNodeSize.height )
    {
        return;
    }
    
    // Choose rotating element position based on mouseState.
    CGPoint rotateElementPositionInTargetNodeSpace = ccp(0.0f,0.0f);
    switch (mouseState) {
        case kCCNWorkspaceMouseStateRotateTopRight:
            rotateElementPositionInTargetNodeSpace = ccp(targetNodeSize.width, targetNodeSize.height);
            break;
            
        case kCCNWorkspaceMouseStateRotateTopLeft:
            rotateElementPositionInTargetNodeSpace = ccp(0.0f, targetNodeSize.height);
            break;
            
        case kCCNWorkspaceMouseStateRotateBottomRight:
            rotateElementPositionInTargetNodeSpace = ccp(targetNodeSize.width, 0.0f);
            break;
            
        case kCCNWorkspaceMouseStateRotateBottomLeft:
            rotateElementPositionInTargetNodeSpace = ccp(0.0f, 0.0f);
            break;
            
        default:
            break;
    }
    
    // Prepare affine transformations here once.
    CGAffineTransform worldToTarget = [targetNode worldToNodeTransform];
    
    // Get anchor location.
    CGPoint anchorPointInTargetNodeSpace = targetNode.anchorPoint;
    anchorPointInTargetNodeSpace.x *= targetNodeSize.width;
    anchorPointInTargetNodeSpace.y *= targetNodeSize.height;
    
    // Get mouse location.
    CGPoint mouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];    
    
    // Calculate & apply new rotation.
    CGPoint mouseLocationInTargetNodeSpace = CGPointApplyAffineTransform(mouseLocation, worldToTarget);
    CGPoint mouseAndAnchorPointDiffInTargetNodeSpace = ccpSub(mouseLocationInTargetNodeSpace, anchorPointInTargetNodeSpace);
    CGPoint elementAndAnchorPointDiffInTargetNodeSpace = ccpSub(rotateElementPositionInTargetNodeSpace, anchorPointInTargetNodeSpace);
    
    targetNode.rotation +=
        CC_RADIANS_TO_DEGREES( ccpAngleSigned(mouseAndAnchorPointDiffInTargetNodeSpace, elementAndAnchorPointDiffInTargetNodeSpace) );
}

- (void) skewTargetNode: (CCNode *) targetNode withMouseDraggedEvent: (NSEvent *) event withState: (int) mouseState
{    
    // Don't skew nodes with width = height = 0.
    // TODO: is it possible to skew node with width != 0 && height == 0 ?
    CGSize targetNodeSize = targetNode.contentSize;
    if ( !targetNodeSize.width && !targetNodeSize.height )
    {
        return;
    }
    
    CGFloat xFactor = 1.0f;
    CGFloat yFactor = 1.0f;
    CGPoint skewElementPositionInTargetNodeSpace = ccp(0,0);
    
    // Choose direction of skewing.
    switch (mouseState) {
        case kCCNWorkspaceMouseStateSkewTop:
            xFactor = 1.0f;
            yFactor = 0.0f;
            skewElementPositionInTargetNodeSpace = ccp(0.5f * targetNodeSize.width, 1.0f * targetNodeSize.height);
            break;
            
        case kCCNWorkspaceMouseStateSkewBottom:
            xFactor = -1.0f;
            yFactor = 0.0f;
            skewElementPositionInTargetNodeSpace = ccp(0.5f * targetNodeSize.width, 0.0f);
            break;
            
        case kCCNWorkspaceMouseStateSkewLeft:
            xFactor = 0.0f;
            yFactor = -1.0f;
            skewElementPositionInTargetNodeSpace = ccp(0.0f, 0.5f * targetNodeSize.height);
            break;
            
        case kCCNWorkspaceMouseStateSkewRight:
            xFactor = 0.0f;
            yFactor = 1.0f;
            skewElementPositionInTargetNodeSpace = ccp(1.0f * targetNodeSize.width, 0.5f * targetNodeSize.height);
            break;
            
        default:
            break;
    }
    
    // Get mouse location diff.
    CGPoint mouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
    
    // Prepare affine transformations here once.
    CGAffineTransform worldToTarget = [targetNode worldToNodeTransform];
    
    // Calculate new skew.
    CGPoint mouseLocationInTargetNodeSpace = CGPointApplyAffineTransform(mouseLocation, worldToTarget);
    CGPoint mouseAndElementLocationDiffInTargetNodeSpace = ccpSub(mouseLocationInTargetNodeSpace, skewElementPositionInTargetNodeSpace);
    CGPoint shift = ccp(0,0);
    CGPoint newSkew = ccp(0,0);
    if ( targetNodeSize.height )
    {
        shift.x = xFactor * mouseAndElementLocationDiffInTargetNodeSpace.x;
        CGFloat angle = atanf(shift.x / targetNodeSize.height );
        newSkew.x = targetNode.skewX + CC_RADIANS_TO_DEGREES( angle );
    }
    if ( targetNodeSize.width )
    {
        shift.y = yFactor * mouseAndElementLocationDiffInTargetNodeSpace.y;
        CGFloat angle = atanf(shift.y / targetNodeSize.width );
        newSkew.y = targetNode.skewY + CC_RADIANS_TO_DEGREES( angle );
    }
    
    // When skew is more than 60 degrees - transforming mouseLocation from world to node
    // gives very big fast changing values. This leads to very jumpy skew value, so
    // we will limit skew value to the range of (-58;58).
    // XXX: allow full-range skew with mouse without artifacts.
    if (fabsf(newSkew.x) <= 58)
    {
        targetNode.skewX = newSkew.x;
    }
    if (fabsf(newSkew.y) <= 58)
    {
        targetNode.skewY = newSkew.y;
    }
    
    //
    // Re: XXX: 
    //                                                            18.03.2012
    //   Dear maintainer!
    //
    //   Before trying to begin hacking full-range skew here, let me tell you something.
    //   I tried several aproaches:
    //     1. Same algorithm in targetNode & world coordinates - and i got jumping skew with skewX or
    //   skewY absolute value more than 58.
    //     2. Different algorithm, similiar to the one from -
    //   rotateTargetNode:withMouseDraggedEvent:withState: (using ccpAngleSigned) - 
    //   and you know what? ABSOLUTELY THE SAME JUMPY SKEW when it's more than 58 degrees!!!
    //
    //   The problem is that skew messes node's transformation matrix a lot, so
    //   finding mouse location in it, or transforming node's selection element to world
    //   coordinates becomes very inaccurate. 
    //
    //   Maybe it's possible to remove node's skew from transform matrix and calculate 
    //   skew angle diff by simulating rotation algorithm, but i think that it's
    //   not worth the trouble.
    //
    //   Sincerely yours,
    //   Stepan
    //
}

#pragma mark Mouse Event Delegate

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

/** Compares screenPoint against all selection elements & changes _mouseState to
 * corresponding if screenPoint is located near one of selection elements.
 * _nodeBeingEdited 
 * 
 * @return YES if _mouseState & nodeBeingEdited was changed, NO otherwise.
 */
- (BOOL) chooseMouseStateAndSetNodeBeingEditedForMouseDownAtScreenPoint: (NSPoint) screenPoint
{
    CGSize scaleElementExtension = kCCNWorkspaceControllerScaleElementExtension();
    
    CCNSelection *selection = nil;
    
    if ( (selection = [self selectionNodeWithElement:kCCNSelectionElementTypeTop nearScreenPoint:screenPoint withAreaExtension: scaleElementExtension]) )
    {        
        if (selection.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
        {
            _mouseState = kCCNWorkspaceMouseStateSkewTop;
        }
        else
        {
            _mouseState = kCCNWorkspaceMouseStateScaleTop;
        }
    }
    else if ( (selection = [self selectionNodeWithElement:kCCNSelectionElementTypeBottom nearScreenPoint:screenPoint withAreaExtension: scaleElementExtension]) )
    {
        if (selection.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
        {
            _mouseState = kCCNWorkspaceMouseStateSkewBottom;
        }
        else
        {
            _mouseState = kCCNWorkspaceMouseStateScaleBottom;
        }
    }
    else if ( (selection = [self selectionNodeWithElement:kCCNSelectionElementTypeLeft nearScreenPoint:screenPoint withAreaExtension: scaleElementExtension]) )
    {
        if (selection.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
        {
            _mouseState = kCCNWorkspaceMouseStateSkewLeft;
        }
        else
        {
            _mouseState = kCCNWorkspaceMouseStateScaleLeft;
        }
    }
    else if ( (selection = [self selectionNodeWithElement:kCCNSelectionElementTypeRight nearScreenPoint:screenPoint withAreaExtension: scaleElementExtension]) )
    {
        if (selection.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
        {
            _mouseState = kCCNWorkspaceMouseStateSkewRight;
        }
        else
        {
            _mouseState = kCCNWorkspaceMouseStateScaleRight;
        }
    }
    else if ( (selection = [self selectionNodeWithElement:kCCNSelectionElementTypeTopLeft nearScreenPoint:screenPoint withAreaExtension: scaleElementExtension]) )
    {
        if (selection.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
        {
            _mouseState = kCCNWorkspaceMouseStateRotateTopLeft;
        }
        else
        {
            _mouseState = kCCNWorkspaceMouseStateScaleTopLeft;
        }
    }
    else if ( (selection = [self selectionNodeWithElement:kCCNSelectionElementTypeTopRight nearScreenPoint:screenPoint withAreaExtension: scaleElementExtension]) )
    {
        if (selection.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
        {
            _mouseState = kCCNWorkspaceMouseStateRotateTopRight;
        }
        else
        {
            _mouseState = kCCNWorkspaceMouseStateScaleTopRight;
        }
    }
    else if ( (selection = [self selectionNodeWithElement:kCCNSelectionElementTypeBottomLeft nearScreenPoint:screenPoint withAreaExtension: scaleElementExtension]) )
    {
        if (selection.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
        {
            _mouseState = kCCNWorkspaceMouseStateRotateBottomLeft;
        }
        else
        {
            _mouseState = kCCNWorkspaceMouseStateScaleBottomLeft;
        }
    }
    else if ( (selection = [self selectionNodeWithElement:kCCNSelectionElementTypeBottomRight nearScreenPoint:screenPoint withAreaExtension: scaleElementExtension]) )
    {
        if (selection.elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms)
        {
            _mouseState = kCCNWorkspaceMouseStateRotateBottomRight;
        }
        else
        {
            _mouseState = kCCNWorkspaceMouseStateScaleBottomRight;
        }
    }
    
    if (selection)
    {
        self.nodeBeingEdited = selection.targetNode;
        return YES;
    }
    
    return NO;
}

- (BOOL)ccMouseDown:(NSEvent *)event
{	    
    // Default state is idle.
    _mouseState = kCCNWorkspaceMouseStateIdle;
    
    NSPoint screenPoint = [[event window] convertBaseToScreen:[event locationInWindow]];
    
    self.nodeBeingEdited = [self selectedNodeWithAnchorPointNearScreenPoint: screenPoint ];
    if (self.nodeBeingEdited)
    {
        _mouseState = kCCNWorkspaceMouseStateDragAnchor;
    }
    else if ( ![self chooseMouseStateAndSetNodeBeingEditedForMouseDownAtScreenPoint: screenPoint] )
    {
        
        CCNode *node = [self nodeForScreenPoint: screenPoint ];
        self.nodeBeingEdited = node;
        if(node)
        {
            // Add nodes to selection with holding Shift.
            if ( [event modifierFlags] & NSShiftKeyMask )
            {
                if (![self.model.selectedNodes containsObject: node])
                {
                    [self.model selectNode: node];
                }
                else // deselect selected nodes on second click when holding shift.
                {
                    [self.model deselectNode: node];
                }
            }
            else // No shift.
            {           
                // If this isn't the selected node - select only it.
                if(![self.model.selectedNodes containsObject: node])
                {
                    [self.model deselectAllNodes];
                    [self.model selectNode: node];
                    
                    // Allow to start dragging selected node immediately.
                    self.nodeBeingEdited = node;
                    _mouseState = kCCNWorkspaceMouseStateMove;
                }
                else // This is already selected node.                 
                {               
                    // Plan to toggle selection mode, if no dragging will occur.
                    _toggleSelectionModeOnMouseUp = YES;
                    
                    // Simply move - all transform checks are made above.
                    _mouseState = kCCNWorkspaceMouseStateMove;
                }                
            }//< No shift.
            
        } //< if (node)
        else
        {
            // Deselect all nodes when clicked in free space.
            [self.model deselectAllNodes];
        }
    }//< else (nodeBeingEdited)
    
    // Update cursor.
    [self updateCursor];
	
    // Remember previous mouse location to move node.
	_prevMouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	
	// Swallow on any action (move, scale, etc...).
    return (_mouseState != kCCNWorkspaceMouseStateIdle);
}

- (BOOL)ccMouseMoved:(NSEvent *)event
{
    // Mouse moved - this is not a click!
    _toggleSelectionModeOnMouseUp = NO;
    
    // Update cursor.
    [self updateCursor];

    return NO;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{	    
    // Mouse moved - this is not a click!
    _toggleSelectionModeOnMouseUp = NO;
    
    CGPoint mouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
    
    if (_mouseState == kCCNWorkspaceMouseStateDragAnchor)
    {
        [self dragAnchorOfTargetNode: self.nodeBeingEdited withMouseDraggedEvent:event];
    }
    else if (_mouseState == kCCNWorkspaceMouseStateMove)
    {
        [self moveSelectedNodesWithMouseDraggedEvent: event];
    }
    else if (_mouseState >= kCCNWorkspaceMouseStateScaleFirst && _mouseState <= kCCNWorkspaceMouseStateScaleLast)
    {
        [self scaleTargetNode: self.nodeBeingEdited withMouseDraggedEvent:event withState: _mouseState];
    }
    else if (_mouseState >= kCCNWorkspaceMouseStateRotateFirst && _mouseState <= kCCNWorkspaceMouseStateRotateLast)
    {
        [self rotateTargetNode: self.nodeBeingEdited withMouseDraggedEvent:event withState: _mouseState];
    }
    else if (_mouseState >= kCCNWorkspaceMouseStateSkewFirst && _mouseState <= kCCNWorkspaceMouseStateSkewLast)
    {
        [self skewTargetNode: self.nodeBeingEdited withMouseDraggedEvent:event withState: _mouseState];
    }
    
    // Don't update cursor on dragging - it should remain the same.
    
    // Remember previous mouse location to move node.
	_prevMouseLocation = mouseLocation;
    
	// Swallow on any action (move, scale, etc...).
    return (_mouseState != kCCNWorkspaceMouseStateIdle);
}

- (BOOL)ccMouseUp:(NSEvent *)event
{	
    // If just simply clicked on node, without dragging/scaleing/rotating/etc it 
    // - togle selectionMode.
    if (_toggleSelectionModeOnMouseUp)
    {
        NSPoint screenPoint = [[event window] convertBaseToScreen:[event locationInWindow]];
        CCNode *node = [self selectedNodeNearScreenPoint: screenPoint];
        
        if (node)
        {
            // Toggle selection elements mode.
            CCNSelection *selection = [self.scene selectionForNode: node];
            [selection toggleElementsMode];
        }
    }    
    
    // Stop anything.
    _mouseState = kCCNWorkspaceMouseStateIdle;
    self.nodeBeingEdited = nil;
    _toggleSelectionModeOnMouseUp = NO;
    
    // Remember previous mouse location to move node.
	_prevMouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	
    // Update cursor.
    [self updateCursor];
    
	return YES;
}

#pragma mark - Keyboard Events

- (BOOL)ccKeyDown:(NSEvent *)event
{
	NSUInteger modifiers = [event modifierFlags];
	unsigned short keyCode = [event keyCode];
	
    BOOL result = NO;
    
	// Deleting nodes from hierarchy.
	switch(keyCode)
	{
		case kCCNKeyCodeBackspace:
		case kCCNKeyCodeDelete:
			[self deleteSelected];
			result = YES;
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
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.anchorPoint = ccp( node.anchorPoint.x - increment, node.anchorPoint.y );
                }
				result = YES;
                break;
			case kCCNKeyCodeRightArrow:
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.anchorPoint = ccp( node.anchorPoint.x + increment, node.anchorPoint.y );
                }
				result = YES;
                break;
			case kCCNKeyCodeDownArrow:
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.anchorPoint = ccp( node.anchorPoint.x, node.anchorPoint.y - increment );
                }
				result = YES;
                break;
			case kCCNKeyCodeUpArrow:
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.anchorPoint = ccp( node.anchorPoint.x, node.anchorPoint.y + increment );
                }
				result = YES;
                break;
			default:
                break;
		}		
	}
	else if (modifiers & NSControlKeyMask) //< If ctrl key is pressed - rotate sprite.
	{
		CGFloat increment = (modifiers & NSShiftKeyMask) ? kCCNIncrementRotationBig : kCCNIncrementRotationDefault;
		
		switch(keyCode)
		{
			case kCCNKeyCodeLeftArrow:
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.rotation -= increment;
                }
				result = YES;
                break;
			case kCCNKeyCodeRightArrow:
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.rotation += increment;
                }
				result = YES;
                break;
			default:
				break;
		}
	}
	else //< No ALT/Option nor CTRL pressed - move node with arrows & change it's zOrder with PgUp/PgDown.
	{
		NSInteger positionIncrement = (modifiers & NSShiftKeyMask) ? kCCNIncrementPositionBig : kCCNIncrementPositionDefault;
	    NSInteger zOrderIncrement = (modifiers & NSShiftKeyMask) ? kCCNIncrementZOrderBig : kCCNIncrementZOrderDefault; 
        
		switch(keyCode)
		{
			case kCCNKeyCodeLeftArrow:
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.position = ccp( node.position.x - positionIncrement, node.position.y );
                }
				result = YES;
                break;
			case kCCNKeyCodeRightArrow:
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.position = ccp( node.position.x + positionIncrement, node.position.y );
                }
				result = YES;
                break;
			case kCCNKeyCodeDownArrow:
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.position = ccp( node.position.x, node.position.y - positionIncrement );
                }
				result = YES;
                break;
			case kCCNKeyCodeUpArrow:
                for (CCNode *node in self.model.selectedNodes)
                {
                    node.position = ccp( node.position.x, node.position.y + positionIncrement );
                }
				result = YES;
                break;
			case kCCNKeyCodePageUp:
                for (CCNode *node in self.model.selectedNodes)
                {
                    if (node.parent)
                    {
                        [node.parent reorderChild:node z:node.zOrder + zOrderIncrement];
                    }
                    else
                    {
                        [node setValue:[NSNumber numberWithInteger: node.zOrder + zOrderIncrement] forKey:@"zOrder_"];
                    }
                }
				
				result = YES;
                break;
			case kCCNKeyCodePageDown:
                for (CCNode *node in self.model.selectedNodes)
                {
                    if (node.parent)
                    {
                        [node.parent reorderChild:node z:node.zOrder - zOrderIncrement];
                    }
                    else
                    {
                        [node setValue:[NSNumber numberWithInteger: node.zOrder - zOrderIncrement] forKey:@"zOrder_"];
                    }
                }
				result = YES;
                break;
			default:
				break;
		}
	}
    
    // Update cursor.
    [self updateCursor];
	
	return result;
}

@end

//
//  CCNController.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import "cocos2d.h"
#import "CCNController.h"
#import "CCNModel.h"
#import "CCNode+Helpers.h"
#import "CSMacGLView.h"

@interface CCNController (Private)

/** Adds CCNController to CCEventDispatcher keyboard, mouse & gesture delegates lists. */
- (void) registerWithEventDispatcher;

/** Removes CCNController from CCEventDispatcher delegates lists.
 * ATTENTION: shouldn't be used in CCNController#dealloc, cause CCEventDispatcher
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

@implementation CCNController

@synthesize model = _model;

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
    CSMacGLView *glView = (CSMacGLView *)[[CCDirector sharedDirector] openGLView];
    
	// Zoom
	if ( [theEvent modifierFlags] & NSCommandKeyMask )
	{
		glView.zoomFactor += [theEvent deltaY] * glView.zoomSpeed;
		glView.zoomFactor = MAX(glView.zoomFactorMin, MIN(glView.zoomFactor, glView.zoomFactorMax));		
		[glView updateWindow];		
		
		return YES;
	}
	
	// Or Scroll
	[[glView enclosingScrollView] scrollWheel: theEvent];	
	
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
        CGPoint nodePositionInScene = CGPointApplyAffineTransform(node.position, [node nodeToWorldTransform]);
        CGPoint newPositionInScene = ccpAdd(nodePositionInScene, diff);
        CGPoint newPosition = CGPointApplyAffineTransform( newPositionInScene, [node worldToNodeTransform]);
        
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
			[self.model removeNodeFromCurrentHierarchy: node];
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

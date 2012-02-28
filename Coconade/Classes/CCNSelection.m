//
//  CCNSelection.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import "CCNSelection.h"
#import "TransformUtils.h"
#import "CCNode+Helpers.h"

@implementation CCNSelection

@synthesize targetNode = _targetNode;

#pragma mark Init/DeInit

// XXX: Optimization: update children properties only when needed 
// (changed targetNode to non-nil or targetNode's propertie changed. )

- (id)init
{
	if((self=[super init]))
	{
        // Prepare selection fill color.
		_fill = [[CCLayerColor layerWithColor:ccc4(30,144,255,75.5f)] retain];
		
        // Prepare targetNode's anchor point indicator.
		_anchor = [[CCSprite spriteWithFile:@"CCNSelectionAnchor.png"] retain];
		[_anchor setOpacity:200];
		[self addChild:_anchor];
		
        // Prepare label that shows current targetNode's position - add it as child to anchorPoint indicator.
		NSString *posText = [NSString stringWithFormat:@"%f, %f", [self position].x, [self position].y];
		_positionLabel = [[CCLabelBMFont labelWithString:posText fntFile:@"arial.fnt"] retain];
        CGSize s = [_anchor contentSize];
        _positionLabel.position = ccp(s.width/2, -10);
		[_anchor addChild:_positionLabel];
	}
	
	return self;
}

- (void)dealloc
{
	[_fill release]; _fill = nil;
	[_anchor release]; _anchor = nil;
	[_positionLabel release]; _positionLabel = nil;
    
	[super dealloc];
}

 #pragma mark Transform

- (void) transform
{
    // Don't apply any transform - work directly in parent's.
}

// Transform for "children".
- (void) updateElements
{
    CGSize size = [_targetNode contentSize];
    CGAffineTransform transform = [_targetNode nodeToWorldTransform];
    
    // Anchor point.
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
        _anchor.visible = NO;
    }
    else
    {
        _anchor.visible = YES;
        
        if( ![_targetNode isRelativeAnchorPoint] )
        {
            _anchor.position = CGPointZero;
        }
        else
        {
            _anchor.position = ccp(size.width*_targetNode.anchorPoint.x, size.height*_targetNode.anchorPoint.y);
        }
        
        _anchor.position = CGPointApplyAffineTransform(_anchor.position, transform );
    }
    
    // Fill Layer.
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
        _fill.visible = NO;
    }
    else
    {
        _fill.visible = YES;
        [_fill changeWidth:size.width height:size.height];
    }
    
    
    // Position Label.
    // TODO: optimize: update string only on targetNode's position change.
	NSString *posText = [NSString stringWithFormat:@"%g, %g", 
                         floorf( _targetNode.position.x ), 
                         floorf( _targetNode.position.y ) 
                         ];
	_positionLabel.string = posText;
}


#pragma mark Visit & Draw

-(void) visit
{
	// Quick return if targetNode not set.
	if (!_targetNode)
		return;
    
    // Update position label, anchor point position indicator, etc.
    [self updateElements];
    
    // Call CCNode#visit as usual.
    [super visit];
}

- (void)drawHighlight
{
    // We will use targetNode's transform to draw highlight, so we need independent matrix.
    glPushMatrix();
    
    // Apply _targetNode's transform.
    CGAffineTransform t = [_targetNode nodeToWorldTransform];
    CGAffineToGL(&t, transformGL_);
	glMultMatrixf(transformGL_);
	
	// Draw the outline.
    CGSize s = _targetNode.contentSize;	
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glLineWidth(1.0f);
    CGPoint vertices[] = {
        ccp(0, s.height),
        ccp(s.width, s.height),
        ccp(s.width, 0),
        ccp(0, 0)
    };
    ccDrawPoly(vertices, 4, YES);
    
    // Draw color layer.
    [_fill visit];
	
    
    // End of drawing highlight - use normal matrix.
    glPopMatrix();
}

/** Overriden CCNode's method. Adds custom highlight drawing. */
- (void) draw
{
    [super draw];
    
    [self drawHighlight];
}

#pragma mark Mouse Events

- (void) onEnter
{
    [super onEnter];
    
    [[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:NSIntegerMin];
}

- (void) onExit
{
    [[CCEventDispatcher sharedDispatcher] removeMouseDelegate:self];
    
    [super onExit];
}

- (BOOL)ccMouseUp:(NSEvent *)event
{
    // Stop dragging.
    _dragAnchor = NO;
    
    // Remember previous mouse location to move node.
	_prevMouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	
	return NO;
}

- (BOOL)ccMouseDown:(NSEvent *)event
{	
    _dragAnchor = NO;
    
    if ([CCNode isEvent:event locatedInNode:_anchor])
    {
        _dragAnchor = YES;
    }

    // Remember previous mouse location to move anchor.
	_prevMouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
	
	return _dragAnchor;
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{	    
    CGPoint mouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
    if (_dragAnchor)
    {
        // Get new position of anchor in scene coordinates.
        CGPoint diff = ccpSub(mouseLocation, _prevMouseLocation);
        CGPoint anchorPositionInScene = CGPointApplyAffineTransform(_anchor.position, [_anchor.parent nodeToWorldTransform]);
        anchorPositionInScene = ccpAdd(anchorPositionInScene, diff);
        
        // Get old anchor position in scene.
        CGSize targetSize = _targetNode.contentSize;
        CGPoint oldAnchor = _targetNode.anchorPoint;
        CGPoint oldAnchorInPoints = ccp(oldAnchor.x * targetSize.width, oldAnchor.y * targetSize.height);
        CGPoint oldAnchorInScene = CGPointApplyAffineTransform(oldAnchorInPoints, [_targetNode nodeToWorldTransform]);
        
        // Set new anchor normalized.
        CGPoint newAnchorInPoints = CGPointApplyAffineTransform(anchorPositionInScene, [_targetNode worldToNodeTransform]);
        CGPoint newAnchor = ccp( newAnchorInPoints.x / targetSize.width, newAnchorInPoints.y / targetSize.height);
        _targetNode.anchorPoint = newAnchor;
        
        // Compensate position change.       
        CGPoint positionCompensation = ccpSub(anchorPositionInScene, oldAnchorInScene);
        _targetNode.position = ccpAdd(_targetNode.position, positionCompensation);
        
        
    }
	
    // Remember previous mouse location to move node.
	_prevMouseLocation = mouseLocation;
	
    return _dragAnchor;
}

@end

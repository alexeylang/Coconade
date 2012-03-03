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

@interface CCNSelection (ModeElements)

/** Prepares 8 scale elements for all sides & corners of the selection & adds them as children. */
- (void) prepareScaleModeElements;

/** Prepares 4 rotate elements for corners, 4 skew elements for sides & adds them as children. */
- (void) prepareRotateModeElements;

/** Updates position of all 8 scale mode elements, to have them exactly at corners
 * and center of the sides for current targetNode transformation.
 */
- (void) positionScaleModeElements;

/** Updates position of all 4 rotation corner's & 4 skew side's elements to have 
 * them exactly at their place for current targetNode transformation.
 */
- (void) positionRotateModeElements;

@end

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
		_fill = [[CCLayerColor layerWithColor:ccc4(181,214,255,50.0f)] retain];
		
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
        
        [self prepareScaleModeElements];
        [self prepareRotateModeElements];
        
        // Select first mode to show only needed elements at start.
        _mode = kCCNSelectionModeLast;
        [self toggleMode];
	}
	
	return self;
}

- (void) prepareScaleModeElements
{
    // Prepare scale mode elements.
    _scaleRight = [CCSprite spriteWithFile:@"CCNSelectionScaleHorizontal.png"];
    _scaleRightTop = [CCSprite spriteWithFile:@"CCNSelectionScaleCorner.png"];
    _scaleTop = [CCSprite spriteWithFile:@"CCNSelectionScaleVertical.png"];
    _scaleLeftTop = [CCSprite spriteWithFile:@"CCNSelectionScaleCorner.png"];
    _scaleLeftTop.scaleX = -1.0f;
    _scaleLeft = [CCSprite spriteWithFile:@"CCNSelectionScaleHorizontal.png"];
    _scaleLeftBottom = [CCSprite spriteWithFile:@"CCNSelectionScaleCorner.png"];
    _scaleBottom = [CCSprite spriteWithFile:@"CCNSelectionScaleVertical.png"];
    _scaleRightBottom = [CCSprite spriteWithFile:@"CCNSelectionScaleCorner.png"];
    _scaleRightBottom.scaleX = -1.0f;
    
    // Add them as children.
    [self addChild:_scaleBottom];
    [self addChild:_scaleLeft];
    [self addChild:_scaleLeftBottom];
    [self addChild:_scaleLeftTop];
    [self addChild:_scaleRight];
    [self addChild:_scaleRightBottom];
    [self addChild:_scaleRightTop];
    [self addChild:_scaleTop];
    
    // Use additive blending.
    ccBlendFunc additiveInvertingBlend;
    additiveInvertingBlend.src = GL_ONE;
    additiveInvertingBlend.dst = GL_ONE_MINUS_DST_COLOR;    
    _scaleBottom.blendFunc = additiveInvertingBlend;
    _scaleLeft.blendFunc = additiveInvertingBlend;
    _scaleLeftBottom.blendFunc = additiveInvertingBlend;
    _scaleLeftTop.blendFunc = additiveInvertingBlend;
    _scaleRight.blendFunc = additiveInvertingBlend;
    _scaleRightBottom.blendFunc = additiveInvertingBlend;
    _scaleRightTop.blendFunc = additiveInvertingBlend;
    _scaleTop.blendFunc = additiveInvertingBlend;
    
}

- (void) positionScaleModeElements
{
    CGSize size = [_targetNode contentSize];
    CGAffineTransform transform = [_targetNode nodeToWorldTransform];
    
    // Position.
    _scaleRight.position = CGPointApplyAffineTransform( ccp(size.width, 0.5f * size.height), transform );
    _scaleRightTop.position = CGPointApplyAffineTransform( ccp(size.width, size.height), transform );
    _scaleTop.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, size.height), transform );
    _scaleLeftTop.position = CGPointApplyAffineTransform( ccp(0, size.height), transform );
    _scaleLeft.position = CGPointApplyAffineTransform( ccp(0, 0.5f* size.height), transform );
    _scaleLeftBottom.position = CGPointApplyAffineTransform( ccp(0, 0), transform );
    _scaleBottom.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, 0), transform );
    _scaleRightBottom.position = CGPointApplyAffineTransform( ccp(size.width, 0), transform );
    
    // Rotate.
    CGFloat rotation = CC_RADIANS_TO_DEGREES( -atanf(transform.b / transform.a) );    
    _scaleRight.rotation = rotation;
    _scaleRightTop.rotation = rotation;
    _scaleTop.rotation = rotation;
    _scaleLeftTop.rotation = rotation;
    _scaleLeft.rotation = rotation;
    _scaleLeftBottom.rotation = rotation;
    _scaleBottom.rotation = rotation;
    _scaleRightBottom.rotation = rotation;
}

- (void) prepareRotateModeElements
{
    // TODO: do
}

- (void) positionRotateModeElements
{
    // TODO: do
}

- (void)dealloc
{
	[_fill release]; _fill = nil;
	[_anchor release]; _anchor = nil;
	[_positionLabel release]; _positionLabel = nil;
    
	[super dealloc];
}

#pragma mark Mode Control

- (void) toggleMode
{
    _mode++;
    
    // Range sentinel.
    if (_mode > kCCNSelectionModeLast)
    {
        _mode = kCCNSelectionModeFirst;
    }
    else if (_mode < kCCNSelectionModeFirst)
    {
        _mode = kCCNSelectionModeLast;
    }
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
    
    // Mode elements.
    switch (_mode) {
        case kCCNSelectionModePositionAndScale:
            [self positionScaleModeElements];
            break;
            
        case kCCNSelectionModePositionAndRotate:
            [self positionRotateModeElements];
            break;
            
        default:
            break;
    }
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
	
    
    glLineStipple(3, 0xCCCC);
    glEnable(GL_LINE_STIPPLE);
    
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_DST_COLOR);
    
	// Draw the outline.
    CGSize s = _targetNode.contentSize;	
    glColor4f(0.29f, 0.62f, 1.0f, 1.0f);
    glLineWidth(2.0f);
    CGPoint vertices[] = {
        ccp(0, s.height),
        ccp(s.width, s.height),
        ccp(s.width, 0),
        ccp(0, 0)
    };
    ccDrawPoly(vertices, 4, YES);
    
    // Draw color layer.
    [_fill visit];
    
    glDisable(GL_LINE_STIPPLE);
    
    glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
    
    // End of drawing highlight - use normal matrix.
    glPopMatrix();
}

/** Overriden CCNode's method. Adds custom highlight drawing. */
- (void) draw
{
    [super draw];
    
    [self drawHighlight];
}

#pragma OnEnter/OnExit

- (void) onEnter
{
    [super onEnter];
    
    [[CCEventDispatcher sharedDispatcher] addMouseDelegate:self priority:NSIntegerMin];
}

- (void) onExit
{
    [[CCEventDispatcher sharedDispatcher] removeMouseDelegate:self];
    
    // Loose weak refs.
    _scaleRight = nil;
    _scaleRightTop = nil;
    _scaleTop = nil;
    _scaleLeftTop = nil;
    _scaleLeft = nil;
    _scaleLeftBottom = nil;
    _scaleBottom = nil;
    _scaleRightBottom = nil;
    _skewRight = nil;
    _rotateRightTop = nil;
    _skewTop = nil;
    _rotateLeftTop = nil;
    _skewLeft = nil;
    _rotateLeftBottom = nil;
    _skewBottom = nil;
    _rotateRightBottom = nil;
    
    [super onExit];
}

#pragma mark Mouse Events

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

- (BOOL)ccMouseMoved:(NSEvent *)event
{
}

- (BOOL)ccMouseDragged:(NSEvent *)event
{	    
    CGPoint mouseLocation = [[CCDirector sharedDirector] convertEventToGL:event];
    if (_dragAnchor)
    {
        // Prepare affine transformations here once.
        CGAffineTransform targetParentToWorld = [_targetNode.parent nodeToWorldTransform];
        CGAffineTransform worldToTargetParent = CGAffineTransformInvert(targetParentToWorld);
        CGAffineTransform targetToWorld = CGAffineTransformConcat([_targetNode nodeToParentTransform], targetParentToWorld);
        CGAffineTransform worldToTarget = CGAffineTransformInvert(targetToWorld);
        
        // Get old anchor position in scene.
        CGSize targetSize = _targetNode.contentSize;
        CGPoint oldAnchor = _targetNode.anchorPoint;
        CGPoint oldAnchorInPoints = ccp(oldAnchor.x * targetSize.width, oldAnchor.y * targetSize.height);
        CGPoint oldAnchorInScene = CGPointApplyAffineTransform(oldAnchorInPoints, targetToWorld);
        
        // Get new position of anchor in scene coordinates.
        CGPoint diff = ccpSub(mouseLocation, _prevMouseLocation);
        CGPoint anchorPositionInScene = ccpAdd(oldAnchorInScene, diff);        
        
        // Set new anchor normalized.
        CGPoint newAnchorInPoints = CGPointApplyAffineTransform(anchorPositionInScene, worldToTarget);
        CGPoint newAnchor = ccp( newAnchorInPoints.x / targetSize.width, newAnchorInPoints.y / targetSize.height);
        _targetNode.anchorPoint = newAnchor;
        
        // Compensate position change.       
        CGPoint positionCompensation = ccpSub(anchorPositionInScene, oldAnchorInScene);
        CGPoint targetPositionInScene =  CGPointApplyAffineTransform(_targetNode.position, targetParentToWorld);
        targetPositionInScene = ccpAdd(targetPositionInScene, positionCompensation);
        _targetNode.position = CGPointApplyAffineTransform(targetPositionInScene, worldToTargetParent);
    }
	
    // Remember previous mouse location to move node.
	_prevMouseLocation = mouseLocation;
	
    return _dragAnchor;
}

@end

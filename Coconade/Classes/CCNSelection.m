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

/** Prepares elements for all sides & corners of the selection & adds them as children. */
- (void) prepareElements;

/** Updates position of all elements, to have them exactly at corners
 * and center of the sides for current targetNode transformation.
 */
- (void) positionElements;

@end

@implementation CCNSelection

@synthesize targetNode = _targetNode;
@synthesize anchorPointIndicator = _anchor;

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
        
        [self prepareElements];
	}
	
	return self;
}

- (void) prepareElements
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

- (void) positionElements
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
    
    // Update elements.
    [self positionElements];

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

- (void) onExit
{    
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

@end

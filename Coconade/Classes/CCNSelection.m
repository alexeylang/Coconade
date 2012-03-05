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
    _elementRight = [CCSprite spriteWithFile:@"CCNSelectionElement.png"];
    _elementRightTop = [CCSprite spriteWithFile:@"CCNSelectionElement.png"];
    _elementTop = [CCSprite spriteWithFile:@"CCNSelectionElement.png"];
    _elementLeftTop = [CCSprite spriteWithFile:@"CCNSelectionElement.png"];
    _elementLeftTop.scaleX = -1.0f;
    _elementLeft = [CCSprite spriteWithFile:@"CCNSelectionElement.png"];
    _elementLeftBottom = [CCSprite spriteWithFile:@"CCNSelectionElement.png"];
    _elementBottom = [CCSprite spriteWithFile:@"CCNSelectionElement.png"];
    _elementRightBottom = [CCSprite spriteWithFile:@"CCNSelectionElement.png"];
    _elementRightBottom.scaleX = -1.0f;
    
    // Add them as children.
    [self addChild:_elementBottom];
    [self addChild:_elementLeft];
    [self addChild:_elementLeftBottom];
    [self addChild:_elementLeftTop];
    [self addChild:_elementRight];
    [self addChild:_elementRightBottom];
    [self addChild:_elementRightTop];
    [self addChild:_elementTop];
    
    // Use additive blending.
    ccBlendFunc additiveInvertingBlend;
    additiveInvertingBlend.src = GL_ONE;
    additiveInvertingBlend.dst = GL_ONE_MINUS_DST_COLOR;    
    _elementBottom.blendFunc = additiveInvertingBlend;
    _elementLeft.blendFunc = additiveInvertingBlend;
    _elementLeftBottom.blendFunc = additiveInvertingBlend;
    _elementLeftTop.blendFunc = additiveInvertingBlend;
    _elementRight.blendFunc = additiveInvertingBlend;
    _elementRightBottom.blendFunc = additiveInvertingBlend;
    _elementRightTop.blendFunc = additiveInvertingBlend;
    _elementTop.blendFunc = additiveInvertingBlend;
    
}

- (void) positionElements
{
    CGSize size = [_targetNode contentSize];
    CGAffineTransform transform = [_targetNode nodeToWorldTransform];
    
<<<<<<< HEAD
    // Position.    
    _scaleRight.position = CGPointApplyAffineTransform( ccp(size.width+0.5f * _scaleRight.contentSize.width, 0.5f * size.height), transform );
    _scaleRightTop.position = CGPointApplyAffineTransform( ccp(size.width+0.5f * _scaleRightTop.contentSize.width, size.height+0.5f * _scaleRightTop.contentSize.width), transform );
    _scaleTop.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, size.height+0.5f * _scaleTop.contentSize.height), transform );
    _scaleLeftTop.position = CGPointApplyAffineTransform( ccp(0-0.5f * _scaleLeftTop.contentSize.width, size.height+0.5f * _scaleLeftTop.contentSize.height), transform );
    _scaleLeft.position = CGPointApplyAffineTransform( ccp(-0.5f * _scaleLeft.contentSize.width, 0.5f* size.height), transform );
    _scaleLeftBottom.position = CGPointApplyAffineTransform( ccp(-0.5f * _scaleLeftBottom.contentSize.width, -0.5f * _scaleLeftBottom.contentSize.height), transform );
    _scaleBottom.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, -0.5f * _scaleBottom.contentSize.height), transform );
    _scaleRightBottom.position = CGPointApplyAffineTransform( ccp(size.width+0.5f * _scaleRightBottom.contentSize.width, -0.5f * _scaleRightBottom.contentSize.height), transform );
=======
    // Position.
    _elementRight.position = CGPointApplyAffineTransform( ccp(size.width, 0.5f * size.height), transform );
    _elementRightTop.position = CGPointApplyAffineTransform( ccp(size.width, size.height), transform );
    _elementTop.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, size.height), transform );
    _elementLeftTop.position = CGPointApplyAffineTransform( ccp(0, size.height), transform );
    _elementLeft.position = CGPointApplyAffineTransform( ccp(0, 0.5f* size.height), transform );
    _elementLeftBottom.position = CGPointApplyAffineTransform( ccp(0, 0), transform );
    _elementBottom.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, 0), transform );
    _elementRightBottom.position = CGPointApplyAffineTransform( ccp(size.width, 0), transform );
>>>>>>> experimental-CCNSelection-squaresInsteadOfArrows
    
    // Rotate.
    CGFloat rotation = CC_RADIANS_TO_DEGREES( -atanf(transform.b / transform.a) );    
    _elementRight.rotation = rotation;
    _elementRightTop.rotation = rotation;
    _elementTop.rotation = rotation;
    _elementLeftTop.rotation = rotation;
    _elementLeft.rotation = rotation;
    _elementLeftBottom.rotation = rotation;
    _elementBottom.rotation = rotation;
    _elementRightBottom.rotation = rotation;
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
    _elementRight = nil;
    _elementRightTop = nil;
    _elementTop = nil;
    _elementLeftTop = nil;
    _elementLeft = nil;
    _elementLeftBottom = nil;
    _elementBottom = nil;
    _elementRightBottom = nil;
    
    [super onExit];
}

@end

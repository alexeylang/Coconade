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
@synthesize elementsMode = _elementsMode;

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
    _elementRectangleRight = [CCSprite spriteWithFile:@"CCNSelectionElementRectangleVertical.png"];
    _elementSquareRightTop = [CCSprite spriteWithFile:@"CCNSelectionElementSquare.png"];
    _elementRectangleTop = [CCSprite spriteWithFile:@"CCNSelectionElementRectangleHorizontal.png"];
    _elementSquareLeftTop = [CCSprite spriteWithFile:@"CCNSelectionElementSquare.png"];
    _elementSquareLeftTop.scaleX = -1.0f;
    _elementRectangleLeft = [CCSprite spriteWithFile:@"CCNSelectionElementRectangleVertical.png"];
    _elementSquareLeftBottom = [CCSprite spriteWithFile:@"CCNSelectionElementSquare.png"];
    _elementRectangleBottom = [CCSprite spriteWithFile:@"CCNSelectionElementRectangleHorizontal.png"];
    _elementSquareRightBottom = [CCSprite spriteWithFile:@"CCNSelectionElementSquare.png"];
    _elementSquareRightBottom.scaleX = -1.0f;
    
    // Add them as children.
    [self addChild:_elementRectangleBottom];
    [self addChild:_elementRectangleLeft];
    [self addChild:_elementSquareLeftBottom];
    [self addChild:_elementSquareLeftTop];
    [self addChild:_elementRectangleRight];
    [self addChild:_elementSquareRightBottom];
    [self addChild:_elementSquareRightTop];
    [self addChild:_elementRectangleTop];
}

- (void) positionElements
{
    CGSize size = [_targetNode contentSize];
    CGAffineTransform transform = [_targetNode nodeToWorldTransform];
    
    // Position.
    _elementRectangleRight.position = CGPointApplyAffineTransform( ccp(size.width, 0.5f * size.height), transform );
    _elementSquareRightTop.position = CGPointApplyAffineTransform( ccp(size.width, size.height), transform );
    _elementRectangleTop.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, size.height), transform );
    _elementSquareLeftTop.position = CGPointApplyAffineTransform( ccp(0, size.height), transform );
    _elementRectangleLeft.position = CGPointApplyAffineTransform( ccp(0, 0.5f* size.height), transform );
    _elementSquareLeftBottom.position = CGPointApplyAffineTransform( ccp(0, 0), transform );
    _elementRectangleBottom.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, 0), transform );
    _elementSquareRightBottom.position = CGPointApplyAffineTransform( ccp(size.width, 0), transform );
    
    // Rotate.
    CGFloat rotation = CC_RADIANS_TO_DEGREES( -atanf(transform.b / transform.a) );    
    _elementRectangleRight.rotation = rotation;
    _elementSquareRightTop.rotation = rotation;
    _elementRectangleTop.rotation = rotation;
    _elementSquareLeftTop.rotation = rotation;
    _elementRectangleLeft.rotation = rotation;
    _elementSquareLeftBottom.rotation = rotation;
    _elementRectangleBottom.rotation = rotation;
    _elementSquareRightBottom.rotation = rotation;
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
    _elementRectangleRight = nil;
    _elementSquareRightTop = nil;
    _elementRectangleTop = nil;
    _elementSquareLeftTop = nil;
    _elementRectangleLeft = nil;
    _elementSquareLeftBottom = nil;
    _elementRectangleBottom = nil;
    _elementSquareRightBottom = nil;
    
    [super onExit];
}

#pragma mark Getting Elements

- (CCNode *) elementNodeWithType: (CCNSelectionElementType) type
{
    switch (type) 
    {
        case kCCNSelectionElementTypeTop:
            return _elementRectangleTop;
            
        case kCCNSelectionElementTypeBottom:
            return _elementRectangleBottom;
            
        case kCCNSelectionElementTypeLeft:
            return _elementRectangleLeft;
            
        case kCCNSelectionElementTypeRight:
            return _elementRectangleRight;
            
        case kCCNSelectionElementTypeTopLeft:
            return _elementSquareLeftTop;
            
        case kCCNSelectionElementTypeTopRight:
            return _elementSquareRightTop;
            
        case kCCNSelectionElementTypeBottomLeft:
            return _elementSquareLeftBottom;
            
        case kCCNSelectionElementTypeBottomRight:
            return _elementSquareRightBottom;  
            
        default:
            return nil;
    }

    return nil;
}

@end

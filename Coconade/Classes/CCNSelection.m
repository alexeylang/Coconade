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
@dynamic elementsMode;
- (CCNSelectionElementsMode) elementsMode
{
    return _elementsMode;
}

-(void) setElementsMode:(CCNSelectionElementsMode)elementsMode
{
    _elementsMode = elementsMode;
    
    switch (_elementsMode) {
        case kCCNSelectionElementsModeSquaresAndRectangles:
            
            // Make rectangles visible.
            _elementRectangleTop.visible = YES;
            _elementRectangleRight.visible = YES;
            _elementRectangleLeft.visible = YES;
            _elementRectangleBottom.visible = YES;
            
            // Make squares visible.
            _elementSquareRightTop.visible = YES;
            _elementSquareLeftTop.visible = YES;
            _elementSquareRightBottom.visible = YES;
            _elementSquareLeftBottom.visible = YES;
            
            // Make parallelograms invisible.
            _elementParallelogramTop.visible = NO;
            _elementParallelogramRight.visible = NO;
            _elementParallelogramLeft.visible = NO;
            _elementParallelogramBottom.visible = NO;
            
            // Make circles invisible.
            _elementCircleRightTop.visible = NO;
            _elementCircleLeftTop.visible = NO;
            _elementCircleRightBottom.visible = NO;
            _elementCircleLeftBottom.visible = NO;
            break;
            
        case kCCNSelectionElementsModeCirclesAndParallelograms:
            
            // Make rectangles invisible.
            _elementRectangleTop.visible = NO;
            _elementRectangleRight.visible = NO;
            _elementRectangleLeft.visible = NO;
            _elementRectangleBottom.visible = NO;
            
            // Make squares invisible.
            _elementSquareRightTop.visible = NO;
            _elementSquareLeftTop.visible = NO;
            _elementSquareRightBottom.visible = NO;
            _elementSquareLeftBottom.visible = NO;
            
            // Make parallelograms visible.
            _elementParallelogramTop.visible = YES;
            _elementParallelogramRight.visible = YES;
            _elementParallelogramLeft.visible = YES;
            _elementParallelogramBottom.visible = YES;
            
            // Make circles visible.
            _elementCircleRightTop.visible = YES;
            _elementCircleLeftTop.visible = YES;
            _elementCircleRightBottom.visible = YES;
            _elementCircleLeftBottom.visible = YES;
            break;
            
        default:
            NSLog(@"CCNSelection#setElementsMode: wrong mode!");
            break;
    }
}

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
        
        self.elementsMode = kCCNSelectionElementsModeSquaresAndRectangles;
	}
	
	return self;
}

- (void) prepareElements
{
    // Prepare rectangles.
    _elementRectangleTop = [CCSprite spriteWithFile:@"CCNSelectionElementRectangleHorizontal.png"];
    _elementRectangleRight = [CCSprite spriteWithFile:@"CCNSelectionElementRectangleVertical.png"];    
    _elementRectangleLeft = [CCSprite spriteWithFile:@"CCNSelectionElementRectangleVertical.png"];
    _elementRectangleBottom = [CCSprite spriteWithFile:@"CCNSelectionElementRectangleHorizontal.png"];
    
    // Prepare squares.
    _elementSquareRightTop = [CCSprite spriteWithFile:@"CCNSelectionElementSquare.png"];
    _elementSquareLeftTop = [CCSprite spriteWithFile:@"CCNSelectionElementSquare.png"];
    _elementSquareLeftTop.scaleX = -1.0f;
    _elementSquareRightBottom = [CCSprite spriteWithFile:@"CCNSelectionElementSquare.png"];
    _elementSquareRightBottom.scaleX = -1.0f;
    _elementSquareLeftBottom = [CCSprite spriteWithFile:@"CCNSelectionElementSquare.png"];
    
    // Prepare parallelograms.
    _elementParallelogramTop = [CCSprite spriteWithFile:@"CCNSelectionElementParallelogramHorizontal.png"];
    _elementParallelogramRight = [CCSprite spriteWithFile:@"CCNSelectionElementParallelogramVertical.png"];    
    _elementParallelogramLeft = [CCSprite spriteWithFile:@"CCNSelectionElementParallelogramVertical.png"];
    _elementParallelogramBottom = [CCSprite spriteWithFile:@"CCNSelectionElementParallelogramHorizontal.png"];
    
    // Prepare circles.
    _elementCircleRightTop = [CCSprite spriteWithFile:@"CCNSelectionElementCircle.png"];
    _elementCircleLeftTop = [CCSprite spriteWithFile:@"CCNSelectionElementCircle.png"];
    _elementCircleRightBottom = [CCSprite spriteWithFile:@"CCNSelectionElementCircle.png"];
    _elementCircleLeftBottom = [CCSprite spriteWithFile:@"CCNSelectionElementCircle.png"];
    
    // Add rectangles.
    [self addChild:_elementRectangleTop];
    [self addChild:_elementRectangleRight];
    [self addChild:_elementRectangleLeft];
    [self addChild:_elementRectangleBottom];    
    
    // Add squares.
    [self addChild:_elementSquareLeftBottom];
    [self addChild:_elementSquareLeftTop];
    [self addChild:_elementSquareRightBottom];
    [self addChild:_elementSquareRightTop];
    
    // Add parallelograms.
    [self addChild:_elementParallelogramTop];
    [self addChild:_elementParallelogramRight];
    [self addChild:_elementParallelogramLeft];
    [self addChild:_elementParallelogramBottom];
    
    // Add circles.
    [self addChild:_elementCircleLeftBottom];
    [self addChild:_elementCircleLeftTop];
    [self addChild:_elementCircleRightBottom];
    [self addChild:_elementCircleRightTop];
}

- (void) positionElements
{
    CGSize size = [_targetNode contentSize];
    CGAffineTransform transform = [_targetNode nodeToWorldTransform];
    CGFloat rotation = CC_RADIANS_TO_DEGREES( -atanf(transform.b / transform.a) );
    
    // Position rectangles.
    _elementRectangleTop.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, size.height), transform );
    _elementRectangleRight.position = CGPointApplyAffineTransform( ccp(size.width, 0.5f * size.height), transform );
    _elementRectangleLeft.position = CGPointApplyAffineTransform( ccp(0, 0.5f* size.height), transform );
    _elementRectangleBottom.position = CGPointApplyAffineTransform( ccp(0.5f * size.width, 0), transform );
    
    // Position squares.
    _elementSquareRightTop.position = CGPointApplyAffineTransform( ccp(size.width, size.height), transform );
    _elementSquareLeftTop.position = CGPointApplyAffineTransform( ccp(0, size.height), transform );
    _elementSquareRightBottom.position = CGPointApplyAffineTransform( ccp(size.width, 0), transform );
    _elementSquareLeftBottom.position = CGPointApplyAffineTransform( ccp(0, 0), transform );
    
    // Position parallelograms same as rectangles.
    _elementParallelogramTop.position = _elementRectangleTop.position ;
    _elementParallelogramRight.position = _elementRectangleRight.position;
    _elementParallelogramLeft.position = _elementRectangleLeft.position;
    _elementParallelogramBottom.position = _elementRectangleBottom.position;
    
    // Position circles same as squares.
    _elementCircleRightTop.position = _elementSquareRightTop.position;
    _elementCircleLeftTop.position = _elementSquareLeftTop.position;
    _elementCircleRightBottom.position = _elementSquareRightBottom.position;
    _elementCircleLeftBottom.position = _elementSquareLeftBottom.position;
    
    // Rotate rectangles.  
    _elementRectangleTop.rotation = rotation;
    _elementRectangleRight.rotation = rotation;
    _elementRectangleLeft.rotation = rotation;
    _elementRectangleBottom.rotation = rotation;
    
    // Rotate squares.
    _elementSquareRightTop.rotation = rotation;
    _elementSquareLeftTop.rotation = rotation;
    _elementSquareRightBottom.rotation = rotation;
    _elementSquareLeftBottom.rotation = rotation;
    
    // Rotate parallelograms.  
    _elementParallelogramTop.rotation = rotation;
    _elementParallelogramRight.rotation = rotation;
    _elementParallelogramLeft.rotation = rotation;
    _elementParallelogramBottom.rotation = rotation;
    
    // Rotate circles.
    _elementCircleRightTop.rotation = rotation;
    _elementCircleLeftTop.rotation = rotation;
    _elementCircleRightBottom.rotation = rotation;
    _elementCircleLeftBottom.rotation = rotation;
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
    // Loose weak refs to rectangles.
    _elementRectangleTop = nil;
    _elementRectangleRight = nil;
    _elementRectangleLeft = nil;
    _elementRectangleBottom = nil;
    
    // Loose weak refs to squares.
    _elementSquareRightTop = nil;
    _elementSquareLeftTop = nil;
    _elementSquareRightBottom = nil;
    _elementSquareLeftBottom = nil;    
    
    // Loose weak refs to parallelograms.
    _elementParallelogramTop = nil;
    _elementParallelogramRight = nil;
    _elementParallelogramLeft = nil;
    _elementParallelogramBottom = nil;
    
    // Loose weak refs to circles.
    _elementCircleRightTop = nil;
    _elementCircleLeftTop = nil;
    _elementCircleRightBottom = nil;
    _elementCircleLeftBottom = nil;  
    
    [super onExit];
}

#pragma mark Getting Elements

- (CCNode *) elementNodeWithType: (CCNSelectionElementType) type
{
    if ( _elementsMode == kCCNSelectionElementsModeSquaresAndRectangles )
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
    } else if ( _elementsMode == kCCNSelectionElementsModeCirclesAndParallelograms )
    {
        switch (type) 
        {
            case kCCNSelectionElementTypeTop:
                return _elementParallelogramTop;
                
            case kCCNSelectionElementTypeBottom:
                return _elementParallelogramBottom;
                
            case kCCNSelectionElementTypeLeft:
                return _elementParallelogramLeft;
                
            case kCCNSelectionElementTypeRight:
                return _elementParallelogramRight;
                
            case kCCNSelectionElementTypeTopLeft:
                return _elementCircleLeftTop;
                
            case kCCNSelectionElementTypeTopRight:
                return _elementCircleRightTop;
                
            case kCCNSelectionElementTypeBottomLeft:
                return _elementCircleLeftBottom;
                
            case kCCNSelectionElementTypeBottomRight:
                return _elementCircleRightBottom;  
                
            default:
                return nil;
        }
    }

    return nil;
}

#pragma mark Mode Control

- (void) toggleElementsMode
{
    if (self.elementsMode == kCCNSelectionElementsModeSquaresAndRectangles)
    {
        self.elementsMode = kCCNSelectionElementsModeCirclesAndParallelograms;
    }
    else 
    {
        self.elementsMode = kCCNSelectionElementsModeSquaresAndRectangles;
    }
}

@end

//
//  CCNSelection.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import "CCNSelection.h"
#import "TransformUtils.h"

@implementation CCNSelection

@synthesize targetNode = _targetNode;

#pragma mark Init/DeInit

- (id)init
{
	if((self=[super init]))
	{
		_fill = [[CCLayerColor layerWithColor:ccc4(30,144,255,25.5f)] retain];
		[self addChild:_fill]; //< TODO: remove
		
		_anchor = [[CCSprite spriteWithFile:@"anchor.png"] retain];
		[_anchor setOpacity:200];
		[self addChild:_anchor]; //< TODO: remove
		
		NSString *posText = [NSString stringWithFormat:@"%f, %f", [self position].x, [self position].y];
		_positionLabel = [[CCLabelBMFont labelWithString:posText fntFile:@"arial.fnt"] retain];
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

// Transform for "children".
- (void) updateElements
{
    // Anchor point.
    CGSize size = [_targetNode contentSize];
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
    CGSize s = [_anchor contentSize];
	NSString *posText = [NSString stringWithFormat:@"%g, %g", floorf( [_targetNode position].x ), floorf( [_targetNode position].y )];
	[_positionLabel setString:posText];
	[_positionLabel setPosition:ccp(s.width/2, -10)];
}

-(void) transform
{
    CGAffineTransform t = [_targetNode nodeToWorldTransform];
    CGAffineToGL(&t, transformGL_);
	
	glMultMatrixf(transformGL_);
}

#pragma mark Visit & Draw

-(void) visit
{
	// Quick return if targetNode not set.
	if (!_targetNode)
		return;
	
	glPushMatrix();
    
	[self transform];
	
    // Self draw.
	[self draw];
    
    
    // Children
    [self updateElements];
    
	[_fill visit];
    [_anchor visit];
	
	glPopMatrix();
}

- (void)draw
{
	[super draw];
	
	// Draw the outline.
    CGSize s = contentSize_;	
    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    glLineWidth(1.0f);
    
    CGPoint vertices[] = {
        ccp(0, s.height),
        ccp(s.width, s.height),
        ccp(s.width, 0),
        ccp(0, 0)
    };
    
    ccDrawPoly(vertices, 4, YES);
	
}

@end

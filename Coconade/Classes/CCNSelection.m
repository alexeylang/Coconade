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
		fill_ = [[CCLayerColor layerWithColor:ccc4(30,144,255,25.5f)] retain];
		[self addChild:fill_];
		
		anchor_ = [[CCSprite spriteWithFile:@"anchor.png"] retain];
		[anchor_ setOpacity:200];
		[self addChild:anchor_];
		
		NSString *posText = [NSString stringWithFormat:@"%f, %f", [self position].x, [self position].y];
		positionLabel_ = [[CCLabelBMFont labelWithString:posText fntFile:@"arial.fnt"] retain];
		[anchor_ addChild:positionLabel_];
	}
	
	return self;
}

- (void)dealloc
{
	[fill_ release]; fill_ = nil;
	[anchor_ release]; anchor_ = nil;
	[positionLabel_ release]; positionLabel_ = nil;
    
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
        anchor_.visible = NO;
    }
    else
    {
        anchor_.visible = YES;
        
        if( ![_targetNode isRelativeAnchorPoint] )
        {
            anchor_.position = CGPointZero;
        }
        else
        {
            anchor_.position = ccp(size.width*_targetNode.anchorPoint.x, size.height*_targetNode.anchorPoint.y);
        }
    }
    
    // Fill Layer.
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
        fill_.visible = NO;
    }
    else
    {
        fill_.visible = YES;
        [fill_ changeWidth:size.width height:size.height];
    }
    
    
    // Position Label.
    CGSize s = [anchor_ contentSize];
	NSString *posText = [NSString stringWithFormat:@"%g, %g", floorf( [_targetNode position].x ), floorf( [_targetNode position].y )];
	[positionLabel_ setString:posText];
	[positionLabel_ setPosition:ccp(s.width/2, -10)];
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
    
	[fill_ visit];
    [anchor_ visit];
    [positionLabel_ visit];
	
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

//
//  CCNScene.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import "CCNScene.h"

#define kCCNSceneUserDefaultsKeyShowBorders @"CSMainLayerShowBorders" //< TODO: change to @"CCNSceneShowBorders"


@implementation CCNScene

@synthesize showBorders = _showBorders;
@synthesize targetNode = _targetNode;
@synthesize selection = _selection;

@dynamic backgroundSprite;

- (CCSprite *) backgroundSprite
{
    return [[_backgroundSprite retain] autorelease];
}

- (void) setBackgroundSprite:(CCSprite *)backgroundSprite
{
    if (backgroundSprite != _backgroundSprite)
    {
        CCSprite *oldValue = _backgroundSprite;
        _backgroundSprite = [backgroundSprite retain];
        
        ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
		[_backgroundSprite.texture setTexParameters:&params];
		_backgroundSprite.position = ccp(0,0);
        _backgroundSprite.anchorPoint = ccp(0,0);
        
        [oldValue release];
    }
}

#pragma mark No AMC Support

+ (BOOL) AMCEnabled
{
    return NO;
}

- (NSDictionary *) dictionaryRepresentation
{
    return nil;
}

- (id) initWithDictionaryRepresentation:(NSDictionary *)aDict
{
    NSLog(@"CCNScene doesn't support AMC!");
    
    [self release];
    return nil;
}

#pragma mark Init / DeInit

- (id) init
{
    self = [super init];
    if (self)
    {
        _updateForScreenReshapeNextVisit = YES;
        
        // Prepare background - repeated sprite.
		self.backgroundSprite = [CCSprite spriteWithFile:@"checkerboard.png"];
        
        _selection = [[CCNSelection node] retain];
        
        NSNumber *showBordersState = [[NSUserDefaults standardUserDefaults] valueForKey: kCCNSceneUserDefaultsKeyShowBorders];
        if (!showBordersState)
            self.showBorders = YES;
        else 
            self.showBorders = [showBordersState intValue];
    }
    
    return self;
}

- (void) dealloc
{
    self.backgroundSprite = nil;
    self.targetNode = nil;
    
    [super dealloc];
}

#pragma mark Updates

- (void) updateForScreenReshapeSafely: (NSNotification *) aNotification
{	
	// Call updateForScreenReshape on next visit.
	_updateForScreenReshapeNextVisit = YES;
}

- (void) updateForScreenReshape
{
	CGSize s = [CCDirector sharedDirector].winSize;
	
	// Update checkerboard size to fit winSize.
    [self.backgroundSprite setTextureRect: CGRectMake(0, 0, s.width, s.height)];
	
    // Update self size.
	[self setContentSize: s];
}

#pragma mark CCNode Lifecycle

//-(void) onEnter
//{
//    [super onEnter];
//    
//	[self.targetNode onEnter];
//}
//
//-(void) onExit
//{	
//	[self.targetNode onExit];
//    
//    [super onExit];
//}

- (void) visit
{
    if (_updateForScreenReshapeNextVisit)
    {
        [self updateForScreenReshape];
        _updateForScreenReshapeNextVisit = NO;
    }
    
    if ([_targetNode isKindOfClass:[CCScene class]])
    {
        [_targetNode visit];
    }
    else
    {
        // Render background.
        [_backgroundSprite visit];
        
        // Render targetNode.
        [_targetNode visit];
        
        // Render borders if needed.        
        if (self.showBorders)
        {
            CGSize s = contentSize_;
            GLfloat lineWidth = 2.0f;
            GLfloat halfLineWidth = 0.5f * lineWidth; 
            
            // Use Inverted BG Color to Draw the Outline
            glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
            glLineWidth(lineWidth);
            
            CGPoint vertices[] = {
                ccp(halfLineWidth, s.height - halfLineWidth),
                ccp(s.width - halfLineWidth, s.height - halfLineWidth),
                ccp(s.width - halfLineWidth, halfLineWidth),
                ccp(halfLineWidth, halfLineWidth)
            };
            
            ccDrawPoly(vertices, 4, YES);
        }
        
    }
    
    // Always render selection - it will be invisible if no targetNode set for it.
    [_selection visit];
}

@end

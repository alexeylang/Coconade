//
//  CCNScene.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import "CCNScene.h"

@implementation CCNScene

@synthesize showBorders = _showBorders;
@synthesize showCheckerboard = _showCheckerboard;
@synthesize targetNode = _targetNode;
@synthesize selection = _selection;

@dynamic checkerboardSprite;

- (CCSprite *) checkerboardSprite
{
    return [[_checkerboardSprite retain] autorelease];
}

- (void) setCheckerboardSprite:(CCSprite *)checkerboardSprite
{
    if (checkerboardSprite != _checkerboardSprite)
    {
        CCSprite *oldValue = _checkerboardSprite;
        _checkerboardSprite = [checkerboardSprite retain];
        
        ccTexParams params = {GL_LINEAR,GL_LINEAR,GL_REPEAT,GL_REPEAT};
		[_checkerboardSprite.texture setTexParameters:&params];
		_checkerboardSprite.position = ccp(0,0);
        _checkerboardSprite.anchorPoint = ccp(0,0);
        
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
        
        // Prepare checkerboard - repeated sprite.
		self.checkerboardSprite = [CCSprite spriteWithFile:@"checkerboard.png"];
        
        _selection = [[CCNSelection node] retain];
        
        // Load showBorders from UserDefaults.
        NSNumber *showBordersState = [[NSUserDefaults standardUserDefaults] valueForKey: kCCNSceneUserDefaultsKeyShowBorders];
        if (!showBordersState)
            self.showBorders = YES;
        else 
            self.showBorders = [showBordersState intValue];
        
        // Load showCheckerboard from UserDefaults.
        NSNumber *showCheckerboardState = [[NSUserDefaults standardUserDefaults] valueForKey: kCCNSceneUserDefaultsKeyShowCheckerboard];
        if (!showCheckerboardState)
            self.showCheckerboard = YES;
        else 
            self.showCheckerboard = [showCheckerboardState intValue];
    }
    
    return self;
}

- (void) dealloc
{
    self.checkerboardSprite = nil;
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
    [self.checkerboardSprite setTextureRect: CGRectMake(0, 0, s.width, s.height)];
	
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
    
    // Render checkerboard if needed.
    if (self.showCheckerboard)
        [_checkerboardSprite visit];
    
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
    
    // Always render selection - it will be invisible if no targetNode set for it.
    [_selection visit];
}

@end
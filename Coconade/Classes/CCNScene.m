//
//  CCNScene.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import "CCNScene.h"

@interface CCNScene () 

/** Selections (Highlight & Tools) for Selected Node. */
@property(readwrite, retain) NSMutableArray *selections;

@end

@implementation CCNScene

@synthesize showBordersAndCheckerboard = _showBordersAndCheckerboard;
@synthesize targetNode = _targetNode;
@synthesize selections = _selections;

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
        
        self.selections = [NSMutableArray arrayWithCapacity: 5];
        
        // Load showBorders from UserDefaults.
        NSNumber *showBordersState = [[NSUserDefaults standardUserDefaults] valueForKey: kCCNSceneUserDefaultsKeyShowBorders];
        if (!showBordersState)
            self.showBordersAndCheckerboard = YES;
        else 
            self.showBordersAndCheckerboard = [showBordersState intValue];
    }
    
    return self;
}

- (void) dealloc
{
    self.selections = nil;
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
    
    // Update color of checkerboard.
    if (!self.showBordersAndCheckerboard)
    {
        _checkerboardSprite.color = ccBLACK;
    }
    else
    {
        _checkerboardSprite.color = ccWHITE;
    }
    
    // Render checkerboard.
    [_checkerboardSprite visit];
    
    // Render targetNode.
    [_targetNode visit];
    
    // Render borders if needed.        
    if (self.showBordersAndCheckerboard)
    {
        CGSize s = contentSize_;
        GLfloat lineWidth = 3.0f;
        GLfloat halfLineWidth = 0.5f * lineWidth; 
        
        // Use Inverted BG Color to Draw the Outline
        glColor4f(0.46f, 0.27f, 0.14f, 1.0f);
        glLineWidth(lineWidth);
        
        CGPoint vertices[] = {
            ccp(halfLineWidth - 1, s.height - halfLineWidth + 1),
            ccp(s.width - halfLineWidth + 1, s.height - halfLineWidth + 1),
            ccp(s.width - halfLineWidth + 1, halfLineWidth - 1),
            ccp(halfLineWidth - 1, halfLineWidth - 1)
        };
        
        ccDrawPoly(vertices, 4, YES);
    }
    
    // Always render selections - it will be invisible if no targetNode set for it.
    for (CCNSelection *selection in self.selections)
    {
        [selection visit];
    }
}

#pragma mark Selection Controls

- (void) removeAllNodesSelections
{
    for (CCNSelection *selection in self.selections)
    {
        [selection onExit];
    }
    
    [self.selections removeAllObjects];
}

/** Ensures that given node is highlighted with selection. */
- (void) addNodeToSelection: (CCNode *) aNode
{
    if(!aNode)
        return;
    
    // Ensure that node isn't selected already.
    for (CCNSelection *selection in self.selections)
    {
        if (selection.targetNode == aNode)
            return;
    }
    
    // Select new node.
    CCNSelection *selection = [[CCNSelection new] autorelease];
    selection.targetNode = aNode;
    [self.selections addObject:selection];
    [selection onEnter];
}

@end

//
//  CCNModel.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import "CCNModel.h"
#import "CCNode+Helpers.h"
#import "NSArray+Reverse.h"
#import "cocos2d.h"

@implementation CCNModel

@synthesize projectFilePath = _projectFilePath;
@synthesize rootNodes = _rootNodes;
@synthesize currentRootNode = _currentRootNode;
@synthesize selectedNodes = _selectedNodes;
@dynamic currentNodes;

- (NSArray *) descendantsOfNode: (CCNode *) aNode includingItself: (BOOL) includeNode
{
    NSMutableArray *array = [NSMutableArray arrayWithCapacity: [aNode.children count] + 1];
    
    BOOL parentCounted = !includeNode;
    
    for (CCNode *child in aNode.children)
    {
        if (!parentCounted && child.zOrder >= 0)
        {
            [array addObject: aNode];
            parentCounted = YES;
        }
        
        [array addObjectsFromArray: [self descendantsOfNode: child includingItself:YES]];
    }
    
    if (!parentCounted)
    {
        [array addObject: aNode];
    }
    
    return array;
}

- (NSArray *) currentNodes
{
    NSArray *descendants = [self descendantsOfNode: self.currentRootNode includingItself:NO];    
    return [descendants reversedArray];
}

#pragma mark Init/Loading

+ (id) modelFromFile: (NSString *) file
{
    return [[[self alloc] initWithFile:file] autorelease];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        _rootNodes = [[NSMutableArray arrayWithCapacity: 1] retain];
        _selectedNodes = [[NSMutableArray arrayWithCapacity: 5] retain];
        
        // Create new currentRootNode with default class & size.
        [_rootNodes addObject:[kCCNModelDefaultRootNodeClass node]];
        self.currentRootNode = [_rootNodes objectAtIndex:0];
        self.currentRootNode.name = [CCNode uniqueNameWithName: [self.currentRootNode className]];
        self.currentRootNode.contentSize = kCCNModelDefaultRootNodeContentSize();        
    }
    
    return self;
}

- (id) initWithFile: (NSString *) file
{
    self = [super init];
    if (self)
    {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: file];
        if (![dict count])
        {
            [self release];
            return nil;
        }
        
        _rootNodes = [[NSMutableArray arrayWithCapacity: [dict count]] retain];
        for (NSString *key in dict)
        {
            NSDictionary *rootNodeDictionaryRepresentation = [dict objectForKey: key];
            
            @try {
                CCNode *curRootNode = [NSObject objectWithDictionaryRepresentation:rootNodeDictionaryRepresentation];
                [_rootNodes addObject: curRootNode];
                
                // Ensure to have name for any rootNode.
                if (!curRootNode.name)
                {
                    curRootNode.name = [CCNode uniqueNameWithName: [curRootNode className]];
                }
                
                // Root nodes MUST have positive contentSize.
                if( curRootNode.contentSize.width <= 0 || curRootNode.contentSize.height <= 0)
                {
                    NSLog(@"CCNModel#initWithFile: Error! Non-positive contentSize in rootNode: %@ with dictionaryRepresentation: %@", curRootNode, rootNodeDictionaryRepresentation);
                    [self release];
                    return nil;
                }
            }
            @catch (NSException *exception) {
                [self release];
                return nil;
            } 
        }
        
        self.currentRootNode = [_rootNodes objectAtIndex:0];
        self.projectFilePath = file;
    }
    
    return self;
}

#pragma mark DeInit

- (void) dealloc
{
    self.projectFilePath = nil;
    
    [_selectedNodes release];
    _selectedNodes = nil;
    
    self.currentRootNode = nil;
    
    [_rootNodes release];
    _rootNodes = nil;   
    
    [super dealloc];
}

#pragma mark Multiple Selection

- (void) selectNode: (CCNode *) aNode
{
    if (!aNode)
        return;
    
    // Don't select node that is not in current hierarchy.
    if (![[self currentNodes] containsObject:aNode])
        return;
    
    // Don't select node twice.
    if ([_selectedNodes containsObject:aNode])
        return;
    
    [_selectedNodes addObject: aNode];
}

- (void) deselectNode: (CCNode *) aNode
{
    if (!aNode)
        return;
    
    [_selectedNodes removeObject: aNode];
}

- (void) deselectAllNodes
{
    
    [_selectedNodes removeAllObjects];
}

#pragma mark Saving

- (void)saveToFile:(NSString *)filename
{
    // XXX: Saving as a dict will reset rootNode order. Export & Bundle should help.
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[self.rootNodes count]];
	for (CCNode *node in self.rootNodes)
    {
        [dict setObject:[node dictionaryRepresentation] forKey:node.name];
    }
    [ dict writeToFile: filename atomically: YES];
	
	// Rembember filename for fast save next time.
	self.projectFilePath = filename;
}

#pragma mark Working with Nodes

- (void) removeNode: (CCNode *) aNode
{
    // Ensure to deselect first. 
    [self deselectNode: aNode];
    
    // Was it a root node?
    if ( [_rootNodes containsObject: aNode])
    {
        NSUInteger i = [_rootNodes indexOfObject:aNode];
        
        BOOL wasCurRootNode = self.currentRootNode == aNode;
        
        // Remove from rootNodes.
        [_rootNodes removeObject: aNode];
        
        // Ensure to always have at least one root node.
        if ( ![_rootNodes count] )
        {
            [_rootNodes addObject:[kCCNModelDefaultRootNodeClass node]];
        }
        
        // Select new currentRootNode if we deleted the one that was current.
        if (wasCurRootNode)
        {
            // Switch to closest hierarchy.
            NSUInteger newI = MIN (0, MAX(i, [_rootNodes count] - 1));
            
            self.currentRootNode = [_rootNodes objectAtIndex: newI];    
        }
    }
    else // Not a root node.
    {
        // Does it have parent? Remove from it.
        [aNode.parent removeChild:aNode cleanup:YES];
    }
}

@end

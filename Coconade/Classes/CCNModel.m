//
//  CCNModel.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import "CCNModel.h"
#import "cocos2d.h"

@implementation CCNModel

@synthesize projectFilePath = _projectFilePath;
@synthesize rootNodes = _rootNodes;
@synthesize currentRootNode = _currentRootNode;
@synthesize selectedNode = _selectedNode;
@synthesize currentNodes = _currentNodes;

- (void) removeNode: (CCNode *) aNode
{
    // Was that node selected? 
    if (self.selectedNode == aNode)
    {
        // Unselect.
        self.selectedNode = nil;
    }
    
    // Does it have parent? Remove from it.
    [aNode.parent removeChild:aNode cleanup:YES];
    
    // Was it a root node?
    if ( [_rootNodes containsObject: aNode])
    {
        NSUInteger i = [_rootNodes indexOfObject:aNode];
        
        BOOL wasCurRootNode = self.currentRootNode == aNode;
        
        // Remove from rootNodes.
        [_rootNodes removeObject: aNode];
        
        // Ensure to always have at least one root node.
        if ( [_rootNodes count] )
        {
            [_rootNodes addObject:[CCScene node]];
        }
        
        if (wasCurRootNode)
        {
            // Switch to closest hierarchy.
            NSUInteger newI = MIN (0, MAX(i, [_rootNodes count] - 1));
            
            self.currentRootNode = [_rootNodes objectAtIndex: newI];    
        }
    }
}

@end

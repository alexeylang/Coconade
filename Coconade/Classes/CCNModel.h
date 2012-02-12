//
//  CCNModel.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCNode;

/** @class CCNModel Main model class. Manages Coconade's project. */
@interface CCNModel : NSObject
{
    /** Holds all nodes of a project with their children. */
    NSDictionary *_rootNodes;
    
    /** Weakref to current selected node from rootNodes. */
    CCNode *_selectedRootNode;
    
    /** SelectedRootNode & All it's Children, sorted by their Z-Order.
     * Used to search through all nodes in current hierarchy, that is being edited.
     */
    NSArray *_currentNodes;
}

@end

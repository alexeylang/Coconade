//
//  CCNOutlineViewDelegate.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import <Foundation/Foundation.h>


@class CCNOutlineGroupItem;;
@class CCNModel;

/** @class CCNOutlineViewDelegate delegate for left outline view that shows project hierarchy. 
 * This class implements methods that describes in NSOutlineViewDelegate and NSOutlineViewDataSource.
 */
@interface CCNOutlineViewDelegate : NSObject <NSOutlineViewDelegate, NSOutlineViewDataSource>
{
    CCNOutlineGroupItem *_nodeGroupItem;
}

#pragma mark Init/Create

/** Returns new autoreleased delagate, inited with given model. 
 * @see -initWithModel:
 */
+ (id)delegateWithModel:(CCNModel *)model;

/** Designated init for CCNOutlineViewDelegate.
 *
 * @param model CCNModel of current project. Delegate returns information to outline view 
 * based on given model.
 */
- (id)initWithModel:(CCNModel *)model;

#pragma mark Update

/** Update delegate with given model.
 *
 * @param model CCNModel of current project. Delegate returns information to outline view 
 * based on given model.
 */
- (void)updateWithModel:(CCNModel *)model;

#pragma mark Group Items

/** Returns current node group item that holds all root CCNodes from model. */
- (CCNOutlineGroupItem *)nodeGroupItem;

@end

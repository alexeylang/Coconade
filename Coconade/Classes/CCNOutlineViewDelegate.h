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
@interface CCNOutlineViewDelegate : NSObject <NSOutlineViewDelegate, NSOutlineViewDataSource>
{
    CCNOutlineGroupItem *_nodeGroupItem;
}

#pragma mark Init/Create

+ (id)delegateWithModel:(CCNModel *)model;

- (id)initWithModel:(CCNModel *)model;

#pragma mark Update

- (void)updateWithModel:(CCNModel *)model;

@end

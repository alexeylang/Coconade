//
//  CCNOutlineViewDelegate.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import <Foundation/Foundation.h>


@class CCNModel;
@interface CCNOutlineViewDelegate : NSObject <NSOutlineViewDelegate, NSOutlineViewDataSource>
{
    CCNModel *_model;
}

@property (readwrite, retain) CCNModel *model;

#pragma mark Init/Create

+ (id)delegateWithModel:(CCNModel *)model;

- (id)initWithModel:(CCNModel *)model;

@end

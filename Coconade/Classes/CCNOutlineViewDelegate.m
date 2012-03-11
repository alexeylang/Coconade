//
//  CCNOutlineViewDelegate.m
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNOutlineViewDelegate.h"


@implementation CCNOutlineViewDelegate

@synthesize model = _model;

#pragma mark Init/Create

+ (id)delegateWithModel:(CCNModel *)model
{
    return [[[self alloc] initWithModel:model] autorelease];
}

- (id)initWithModel:(CCNModel *)model
{
    if ( (self = [super init]) )
    {
        self.model = model;
    }
    
    return self;
}

@end

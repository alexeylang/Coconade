//
//  CCNOutlineGroupItem.m
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNOutlineGroupItem.h"


@implementation CCNOutlineGroupItem

@synthesize name = _name;
@synthesize children = _children;

#pragma mark Init/Create

+ (id)itemWithName:(NSString *)name
{
    return [[[self alloc] initWithName:name] autorelease];
}

- (id)initWithName:(NSString *)name
{
    if ( (self = [super init]) )
    {
        self.name = name;
        self.children = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)dealloc
{
    self.name = nil;
    self.children = nil;
    
    [super dealloc];
}

@end

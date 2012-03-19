//
//  CCNOutlineGroupItem.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CCNOutlineGroupItem : NSObject
{
    NSMutableArray *_children;
    NSString *_name;
}

@property (readwrite, retain) NSMutableArray *children;

@property (readwrite, copy) NSString *name;

#pragma mark Init/Create

+ (id)itemWithName:(NSString *)name;

- (id)initWithName:(NSString *)name;

@end

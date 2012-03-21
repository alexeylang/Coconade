//
//  CCNOutlineGroupItem.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import <Foundation/Foundation.h>


/** @class CCNOutlineGroupItem item in left outline view that represents root group
 * like "Nodes", "Textures" etc.
 */
@interface CCNOutlineGroupItem : NSObject
{
    NSMutableArray *_children;
    NSString *_name;
}

/** Holds array with current child items. */
@property (readwrite, retain) NSMutableArray *children;

/** Holds current name string. */
@property (readwrite, copy) NSString *name;

#pragma mark Init/Create

/** Returns new autoreleased item, inited with given name. 
 * @see -initWithName:
 */
+ (id)itemWithName:(NSString *)name;

/** Designated init for CCNOutlineGroupItem.
 *
 * @param name NSString with name for item.
 */
- (id)initWithName:(NSString *)name;

@end

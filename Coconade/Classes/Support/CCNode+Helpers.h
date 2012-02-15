//
//  CCNode+Helpers.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import "CCNode.h"

@class NSEvent;
@interface CCNode (Helpers)

/** Checks is given event location is inside of given node.
 * Location gets transformed to node's coordinate system, so all node
 * transformations (including rotate, scale, skew, etc) are taken into account.
 *
 * @param event Mouse event from i.e. -ccMouseDown: method.
 *
 * @param node CCNode to compare against event location.
 *
 * @return YES if event is located inside of node, NO otherwise.
 */
+ (BOOL)isEvent: (NSEvent *)event locatedInNode: (CCNode *) node;

/** Returns unique name (name that isn't used currently by any other node
 * in CCNodeCache).
 * Returned string is created by concatanating (if needed) nonUniqueName
 * and a prefix, likelike "_17".
 */
+ (NSString *) uniqueNameWithName: (NSString *) nonUniqueName;

/** Sets nodes name, ensuring that it's unique by using
 * +uniqueNameWithName:
 * Returns uniqueName, that was set as node's name.
 */
- (NSString *) setUniqueName: (NSString *) nonUniqueName;

@end

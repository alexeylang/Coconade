//
//  CCNode+Helpers.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import "CCNode.h"

@class NSEvent;
@interface CCNode (Helpers)

/** Checks is given point in screen coordinates is inside of given node.
 * Location gets transformed to node's coordinate system, so all node
 * transformations (including rotate, scale, skew, etc) are taken into account.
 *
 * @param screenPoint Position of mouse in screen coordinates. Could be taken from 
 * [NSEvent mouseLocation] for example.
 *
 * @param node CCNode to compare against screenPoint.
 *
 * @return YES if point is located inside of node, NO otherwise.
 */
+ (BOOL) isScreenPoint: (NSPoint) screenPoint locatedInNode: (CCNode *) node;

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


@interface CCNode (PasteboardSupport) <NSPasteboardReading, NSPasteboardWriting> 

#pragma mark NSPasteboardWriting
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard;
- (id)pasteboardPropertyListForType:(NSString *)type;


#pragma mark NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard;
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard;

@end



@interface CCNode (Parenting)

/** Returns YES if aNode can be added as child to this node,
 * NO otherwise.
 *
 * I.e. only CCMenuItems can be added to CCMenu & only CCSprites with same texture
 * can be added as children to CCSpriteBatchNode.
 */
- (BOOL) canBecomeParentOf: (CCNode *) aNode;

@end
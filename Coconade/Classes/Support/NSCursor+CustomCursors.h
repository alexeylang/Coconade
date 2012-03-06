//
//  NSCursor+CustomCursors.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov 
//  All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSCursor (CustomCursors)

/** Creates new autoreleased resizing corner cursor for bottomRight/topLeft corner. */
+(NSCursor *) resizeCornerCursor;

/** Creates new autoreleased resizing corner cursor for topRight/bottomLeft corner. */
+(NSCursor *) resizeCornerCursorFlipped;

/** Creates new autoreleased cursor from cursorFile with given hotspot. 
 * @param cursorFile filename of file located in resources of app.
 */
+ (NSCursor *)cursor:(NSString *)cursorFile withHotSpot:(NSPoint)hotSpot;

@end

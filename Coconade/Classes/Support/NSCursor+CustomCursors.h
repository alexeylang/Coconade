//
//  NSCursor+CustomCursors.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov 
//  All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSCursor (CustomCursors)

/** Creates new autoreleased resizing corner cursor with given rotate. 
 * @param angle Rotation of wanted cursor in degrees, CCW, zero means right side.
 */
+ (NSCursor *) resizeCursorWithAngle: (float) angle;

/** Creates new autoreleased cursor from cursorFile with given hotspot. 
 * @param cursorFile filename of file located in resources of app.
 */
+ (NSCursor *)cursor:(NSString *)cursorFile withHotSpot:(NSPoint)hotSpot;

@end

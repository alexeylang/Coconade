//
//  NSCursor+CustomCursors.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import "NSCursor+CustomCursors.h"

@implementation NSCursor (CustomCursors)

+(NSCursor *) resizeCornerCursor
{
    return [self cursor: @"resizeCornerCursor.png"  withHotSpot:NSMakePoint(8, 8)];
}

+(NSCursor *) resizeCornerCursorFlipped
{
    return [self cursor: @"resizeCornerCursorFlipped.png"  withHotSpot:NSMakePoint(8, 8)];
}

+ (NSCursor *) resizeCursorWithAngle: (float) angle
{
    // Use [0;180] range.
    angle = fmodf(angle, 180.0f);
    if (angle < 0.0f)
    {
        angle += 180.0f;
    }
    
    // Select cursor that fits best.
    if (angle >= 0 && angle <= 22.5f)
    {
        // Horizontal.
        return [NSCursor resizeLeftRightCursor];
    }
    else if (angle > 22.5f && angle <= 67.5f)
    {
        // Corner.
        return [NSCursor resizeCornerCursorFlipped];
    }
    else if (angle > 67.5f && angle <= 112.5f)
    {
        // Vertical.
        return [NSCursor resizeUpDownCursor];
    }
    else if (angle > 112.5f && angle <= 157.5f)
    {
        // Corner flipped.
        return [NSCursor resizeCornerCursor];
    }
    else if (angle > 157.5f && angle <= 180)
    {
        // Horizontal.
        return [NSCursor resizeLeftRightCursor];
    }
    
    return [NSCursor currentCursor];
}

+ (NSCursor *)cursor:(NSString *)cursorFile withHotSpot:(NSPoint)hotSpot
{
    NSString *path = [[NSBundle mainBundle] pathForResource: cursorFile ofType: nil];
    NSImage *cursorImage = [[NSImage alloc] initWithContentsOfFile: path];
    NSCursor *cursor = [[NSCursor alloc] initWithImage: cursorImage
                                               hotSpot: hotSpot];
    
    [cursorImage release];
    return [cursor autorelease];
}

@end

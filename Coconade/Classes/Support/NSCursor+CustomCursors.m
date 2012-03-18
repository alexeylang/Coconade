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

+(NSCursor *) resizeCornerCursor68
{
    return [self cursor: @"resizeCornerCursor68.png"  withHotSpot:NSMakePoint(8, 11)];
}

+(NSCursor *) resizeCornerCursor112
{
    return [self cursor: @"resizeCornerCursor112.png"  withHotSpot:NSMakePoint(8, 11)];
}

+(NSCursor *) resizeCornerCursor157
{
    return [self cursor: @"resizeCornerCursor157.png"  withHotSpot:NSMakePoint(11, 8)];
}

+(NSCursor *) resizeCornerCursor202
{
    return [self cursor: @"resizeCornerCursor202.png"  withHotSpot:NSMakePoint(11, 8)];
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
    if (angle >= 0 && angle <= 11.25f)
    {
        // Horizontal.
        return [NSCursor resizeLeftRightCursor];
    }
    else if (angle > 11.25f && angle <= 33.75f)
    {
        // Between horizontal & corner.
        return [NSCursor resizeCornerCursor202];
    }
    else if (angle > 33.75f && angle <= 56.25f)
    {
        // Corner.
        return [NSCursor resizeCornerCursorFlipped];
    }
    else if (angle > 56.25 && angle <= 78.75f)
    {
        // Between Corner & Vertical.
        return [NSCursor resizeCornerCursor68];
    }
    else if (angle > 78.75f && angle <= 101.25f)
    {
        // Vertical.
        return [NSCursor resizeUpDownCursor];
    }
    else if (angle > 101.25f && angle <= 123.75f)
    {
        // Between Vertical & Corner.
        return [NSCursor resizeCornerCursor112];
    }
    else if (angle > 123.75f && angle <= 135.0f)
    {
        // Corner flipped.
        return [NSCursor resizeCornerCursor];
    }
    else if (angle > 135.5f && angle <= 157.5f)
    {
        // Between Corner & Horizontal.
        return [NSCursor resizeCornerCursor157];
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

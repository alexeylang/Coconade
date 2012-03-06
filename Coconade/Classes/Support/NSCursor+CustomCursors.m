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

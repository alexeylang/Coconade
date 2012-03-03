//
//  CCNSeparatorCell.m
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNSeparatorCell.h"

#define kCCNSeparatorCellLineHalfHeight     1.0f
#define kCCNSeparatorCellLineOffsetY        0.5f


@implementation CCNSeparatorCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
	CGFloat lineWidth = cellFrame.size.width;
	CGFloat lineX = 0.0f;
	CGFloat lineY = (cellFrame.size.height - 2.0f) / 2.0f;
	lineY += kCCNSeparatorCellLineOffsetY;
    
	[[NSColor colorWithDeviceRed: 0.349f 
                           green: 0.6f 
                            blue: 0.898f 
                           alpha: 0.6f] set];
	NSRectFill(NSMakeRect(cellFrame.origin.x + lineX, 
                          cellFrame.origin.y + lineY, 
                          lineWidth, 
                          kCCNSeparatorCellLineHalfHeight));
	
	[[NSColor colorWithDeviceRed: 0.976 
                           green: 1.0 
                            blue: 1.0 
                           alpha: 1.0] set];
	NSRectFill(NSMakeRect(cellFrame.origin.x + lineX, 
                          cellFrame.origin.y + lineY + kCCNSeparatorCellLineHalfHeight, 
                          lineWidth, 
                          kCCNSeparatorCellLineHalfHeight));
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject 
                  start:(NSInteger)selStart length:(NSInteger)selLength
{
}

@end

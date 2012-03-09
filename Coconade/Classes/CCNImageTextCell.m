//
//  CCNImageTextCell.m
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNImageTextCell.h"

#define kCCNImageTextCellIconImageSizeWidth     16.0f
#define kCCNImageTextCellIconImageSizeHeight    16.0f
#define kCCNImageTextCellImageOriginXOffset     3.0f
#define kCCNImageTextCellImageOriginYOffset     1.0f
#define kCCNImageTextCellTextOriginXOffset      2.0f
#define kCCNImageTextCellTextOriginYOffset      2.0f
#define kCCNImageTextCellTextHeightAdjust       4.0f

#define kCCNImageTextCellTextFontSize           12.0f


@interface CCNImageTextCell ()

- (BOOL)isGroupCell;

@end


@implementation CCNImageTextCell

#pragma mark Properties

@dynamic image;
- (void)setImage:(NSImage *)image
{
    [image retain];
    [_image release];
    _image = image;
    [_image setSize:NSMakeSize(kCCNImageTextCellIconImageSizeWidth, kCCNImageTextCellIconImageSizeHeight)];
}

- (NSImage *)image
{
    return _image;
}

#pragma mark Init/Create

- (id)init
{
	if ( (self = [super init]) )
    {
        self.font = [NSFont systemFontOfSize:kCCNImageTextCellTextFontSize];
    }
    
	return self;
}

- (void)dealloc
{
    self.image = nil;
    
    [super dealloc];
}

#pragma mark NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone
{
    CCNImageTextCell *cell = (CCNImageTextCell *)[super copyWithZone:zone];
    cell.image = self.image;
    return cell;
}

#pragma mark NSCell Related

//	Returns the proper bound for the cell's title while being edited
- (NSRect)titleRectForBounds:(NSRect)cellRect
{	
	NSRect imageFrame, newFrame;
	NSDivideRect(cellRect, &imageFrame, &newFrame, kCCNImageTextCellIconImageSizeWidth + kCCNImageTextCellImageOriginXOffset, NSMinXEdge);
	
	newFrame.origin.x += kCCNImageTextCellTextOriginXOffset;
	newFrame.origin.y += kCCNImageTextCellTextOriginYOffset;
	newFrame.size.height -= kCCNImageTextCellTextHeightAdjust;
    
	return newFrame;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView*)controlView editor:(NSText*)textObj delegate:(id)anObject event:(NSEvent*)theEvent
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super editWithFrame:textFrame inView:controlView editor:textObj delegate:anObject event:theEvent];
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject 
                  start:(NSInteger)selStart length:(NSInteger)selLength
{
	NSRect textFrame = [self titleRectForBounds:aRect];
	[super selectWithFrame:textFrame inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView
{
	if ( self.image )
	{
        NSRect imageFrame, newFrame;
        NSDivideRect(cellFrame, &imageFrame, &newFrame, self.image.size.width + kCCNImageTextCellImageOriginXOffset, NSMinXEdge);
        
        imageFrame.origin.x += kCCNImageTextCellImageOriginXOffset;
		imageFrame.origin.y -= kCCNImageTextCellImageOriginYOffset;
        imageFrame.size = self.image.size;
		
        if ( [controlView isFlipped] )
        {
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2.0f);
        }
        else
        {
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2.0f);
        }
		[self.image compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
        
		newFrame.origin.x += kCCNImageTextCellTextOriginXOffset;
		newFrame.origin.y += kCCNImageTextCellTextOriginYOffset;
		newFrame.size.height -= kCCNImageTextCellTextHeightAdjust;
		[super drawWithFrame:newFrame inView:controlView];
    }
	else
	{
		if ( [self isGroupCell] )
		{
			CGFloat yOffset = floor((cellFrame.size.height - self.attributedStringValue.size.height) / 2.0f);
			cellFrame.origin.y += yOffset;
			cellFrame.size.height -= (kCCNImageTextCellTextOriginYOffset * yOffset);
			[super drawWithFrame:cellFrame inView:controlView];
		}
        else
        {
			[super drawWithFrame:cellFrame inView:controlView];
        }
	}
}

- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (self.image ? self.image.size.width : 0) + kCCNImageTextCellImageOriginXOffset;
    return cellSize;
}

#pragma mark Helpers

- (BOOL)isGroupCell
{
    return (self.image &&  self.title.length);
}

@end
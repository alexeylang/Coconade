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

@end


@implementation CCNImageTextCell

@synthesize isGroup = _isGroup;

#pragma mark Properties

@dynamic iconImage;
- (void)setIconImage:(NSImage *)iconImage
{
    [iconImage retain];
    [_iconImage release];
    _iconImage = iconImage;
    [_iconImage setSize:NSMakeSize(kCCNImageTextCellIconImageSizeWidth, kCCNImageTextCellIconImageSizeHeight)];
}

- (NSImage *)iconImage
{
    return _iconImage;
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
    self.iconImage = nil;
    
    [super dealloc];
}

#pragma mark NSCopying Protocol

- (id)copyWithZone:(NSZone *)zone
{
    CCNImageTextCell *cell = (CCNImageTextCell *)[super copyWithZone:zone];
    cell.iconImage = self.iconImage;
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
	if ( self.iconImage )
	{
        NSRect imageFrame, newFrame;
        NSDivideRect(cellFrame, &imageFrame, &newFrame, self.iconImage.size.width + kCCNImageTextCellImageOriginXOffset, NSMinXEdge);
        
        imageFrame.origin.x += kCCNImageTextCellImageOriginXOffset;
		imageFrame.origin.y -= kCCNImageTextCellImageOriginYOffset;
        imageFrame.size = self.iconImage.size;
		
        if ( [controlView isFlipped] )
        {
            imageFrame.origin.y += ceil((cellFrame.size.height + imageFrame.size.height) / 2.0f);
        }
        else
        {
            imageFrame.origin.y += ceil((cellFrame.size.height - imageFrame.size.height) / 2.0f);
        }
		[self.iconImage compositeToPoint:imageFrame.origin operation:NSCompositeSourceOver];
        
		newFrame.origin.x += kCCNImageTextCellTextOriginXOffset;
		newFrame.origin.y += kCCNImageTextCellTextOriginYOffset;
		newFrame.size.height -= kCCNImageTextCellTextHeightAdjust;
		[super drawWithFrame:newFrame inView:controlView];
    }
	else
	{
		if ( self.isGroup )
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
    cellSize.width += (self.iconImage ? self.iconImage.size.width : 0) + kCCNImageTextCellImageOriginXOffset;
    return cellSize;
}

@end
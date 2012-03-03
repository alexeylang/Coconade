//
//  CCNImageTextCell.m
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNImageTextCell.h"

#define kIconImageSize		16.0f

#define kImageOriginXOffset 3.0f
#define kImageOriginYOffset 1.0f

#define kTextOriginXOffset	2.0f
#define kTextOriginYOffset	2.0f
#define kTextHeightAdjust	4.0f


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
    [_image setSize:NSMakeSize(kIconImageSize, kIconImageSize)];
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
        self.font = [NSFont systemFontOfSize:[NSFont smallSystemFontSize]];
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
	NSRect imageFrame;
	NSDivideRect(cellRect, &imageFrame, &cellRect, self.image.size.width + kImageOriginXOffset, NSMinXEdge);
	
	NSRect newFrame = cellRect;
	newFrame.origin.x += kTextOriginXOffset;
	newFrame.origin.y += kTextOriginYOffset;
	newFrame.size.height -= kTextHeightAdjust;
    
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
        NSRect imageFrame;        
        NSDivideRect(cellFrame, &imageFrame, &cellFrame, self.image.size.width + kImageOriginXOffset, NSMinXEdge);
        
        imageFrame.origin.x += kImageOriginXOffset;
		imageFrame.origin.y -= kImageOriginYOffset;
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
        
		NSRect newFrame = cellFrame;
		newFrame.origin.x += kTextOriginXOffset;
		newFrame.origin.y += kTextOriginYOffset;
		newFrame.size.height -= kTextHeightAdjust;
		[super drawWithFrame:newFrame inView:controlView];
    }
	else
	{
		if ( [self isGroupCell] )
		{
			CGFloat yOffset = floor((cellFrame.size.height - self.attributedStringValue.size.height) / 2.0f);
			cellFrame.origin.y += yOffset;
			cellFrame.size.height -= (kTextOriginYOffset * yOffset);
			[super drawWithFrame:cellFrame inView:controlView];
		}
	}
}

- (NSSize)cellSize
{
    NSSize cellSize = [super cellSize];
    cellSize.width += (self.image ? self.image.size.width : 0) + kImageOriginXOffset;
    return cellSize;
}

#pragma mark Helpers

- (BOOL)isGroupCell
{
    return (self.image &&  self.title.length);
}

@end
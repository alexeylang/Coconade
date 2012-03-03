//
//  CCNImageTextCell.h
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import <Foundation/Foundation.h>

/** @class CCNImageTextCell cell for left view like iTunes style. */
@interface CCNImageTextCell : NSTextFieldCell
{
	NSImage *_image;
}

/** Holds image icon for cell. */
@property (readwrite, retain) NSImage *image;

@end

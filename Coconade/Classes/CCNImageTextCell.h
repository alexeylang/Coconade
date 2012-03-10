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
	NSImage *_iconImage;
    BOOL _isGroup;
}

/** Holds icon image for cell. */
@property (readwrite, retain) NSImage *iconImage;

/** Returns YES if cell used for representation groups like "Nodes", "Spriteframes" etc.
 * Otherwise returns NO.
 */
@property (readwrite) BOOL isGroup;

@end

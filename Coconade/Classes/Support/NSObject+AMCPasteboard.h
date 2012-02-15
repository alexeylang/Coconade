//
//  NSObject+AMCPasteboard.h
//  Coconade
//
//  Created by Stepan Generalov on 15.02.12.
//  Copyright (c) 2012 sg@game-insight.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/** @category AMCPasteboard methods to support NSPasteboard write/read for
 * any AMCEnabled object.
 *
 * @todo comment methods
 */
@interface NSObject (AMCPasteboard)

#pragma mark NSPasteboardWriting
- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard;
- (id)pasteboardPropertyListForType:(NSString *)type;


#pragma mark NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard;
+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard;
- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)typ;

@end

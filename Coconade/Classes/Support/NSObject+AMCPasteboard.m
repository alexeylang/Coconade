//
//  NSObject+AMCPasteboard.m
//  Coconade
//
//  Created by Stepan Generalov on 15.02.12.
//  Copyright (c) 2012 sg@game-insight.com. All rights reserved.
//

#import "NSObject+AMCPasteboard.h"
#import "NSObject+AutoMagicCoding.h"

@implementation NSObject (AMCPasteboard)

#pragma mark NSPasteboardWriting

NSString *AMCEnabledObjectUTI = @"org.coconade.AMCEnabledObject";

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard 
{
    if ([[self class] AMCEnabled]) 
    {
        return [[NSArray alloc] initWithObjects:AMCEnabledObjectUTI, nil]; //< TODO: fix memleak
    }
    return [[NSArray array] retain]; //< TODO: fix memleak
}

- (id)pasteboardPropertyListForType:(NSString *)type 
{
    if ([type isEqualToString:AMCEnabledObjectUTI]) 
	{
        return [self dictionaryRepresentation];
    }
	
    return nil;
}

#pragma mark NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard 
{    
    if ([[self class] AMCEnabled]) 
	{
        return [[NSArray alloc] initWithObjects:AMCEnabledObjectUTI, nil];
    }
    return nil;
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard 
{
    if ([type isEqualToString:AMCEnabledObjectUTI] && [[self class] AMCEnabled]) 
	{
        // Use -initWithPasteboardPropertyList:ofType: to init object from pasteboard.
        return NSPasteboardReadingAsPropertyList;
    }
    return 0;
}

- (id)initWithPasteboardPropertyList:(id)propertyList ofType:(NSString *)type
{
    [self release];
    
    return [[NSObject objectWithDictionaryRepresentation: propertyList] retain];
}


@end

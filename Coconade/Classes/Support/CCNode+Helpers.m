//
//  CCNode+Helpers.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import "CCNode+Helpers.h"
#import "cocos2d.h"

@implementation CCNode (Helpers)

+ (BOOL)isEvent: (NSEvent *)event locatedInNode: (CCNode *) node
{
    CGPoint eventLocationInGL = [[CCDirector sharedDirector] convertEventToGL:event];
    CGPoint eventLocationInNode = [node convertToNodeSpace: eventLocationInGL];
    CGRect nodeRect = CGRectMake(0, 0, node.contentSize.width, node.contentSize.height);
    return CGRectContainsPoint(nodeRect, eventLocationInNode);
}


+ (NSString *) uniqueNameWithName: (NSString *) nonUniqueName
{
	NSString *name = [NSString stringWithString: nonUniqueName];
	
    NSUInteger i = 1;
	while( [[CCNodeRegistry sharedRegistry] nodeByName: name] )
	{
		NSAssert(i != NSUIntegerMax, @"CCNode::uniqueNameWithName: There's too many nodes with same name!");
		name = [nonUniqueName stringByAppendingFormat:@"_%u", i];
        i++;
	}
	
    return name;
}

- (NSString *) setUniqueName: (NSString *) nonUniqueName
{
    NSString *uniqueName = [[self class] uniqueNameWithName: nonUniqueName];
    self.name = uniqueName;
    
    return self.name;
}

@end

@implementation CCNode (PasteboardSupport)

NSString *CCNodeUTI = @"org.coconade.CCNode";
NSString *CCNodeDictionaryRepresentationKey = @"CCNodeAMC1.1DictionaryRepresentation";

- (id)initWithCoder:(NSCoder *)coder 
{
    [self release];
        
    NSDictionary *dict = [coder decodeObjectForKey:CCNodeDictionaryRepresentationKey]; 
        
    // Ensure name to be unique before creating instance of CCNode, cause setting
    // name property of CCNOde will instantly register it in CCNodeRegistry, overwrting
    // existing node with same name. 
    // But we want to save both nodes in CCNodeRegistry, so name must be changed in dictionary.
    NSMutableDictionary *dictWithUniqueName = [NSMutableDictionary dictionaryWithDictionary: dict];
    NSString *name = [dictWithUniqueName objectForKey:@"name"];
    NSString *uniqueName = [CCNode uniqueNameWithName: name];
    [dictWithUniqueName setObject:uniqueName forKey:@"name"];
    self = [[NSObject objectWithDictionaryRepresentation: dictWithUniqueName] retain];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder 
{
    [encoder encodeObject: [self dictionaryRepresentation] 
                   forKey: CCNodeDictionaryRepresentationKey];
}

#pragma mark NSPasteboardWriting

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard 
{
    return [[[NSArray alloc] initWithObjects:CCNodeUTI, nil] autorelease];
}

- (id)pasteboardPropertyListForType:(NSString *)type 
{
    if ([type isEqualToString:CCNodeUTI]) 
    {
        return [NSKeyedArchiver archivedDataWithRootObject:self];
    }
    
    return nil;
}

#pragma mark NSPasteboardReading
+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard 
{    
    return [[[NSArray alloc] initWithObjects:CCNodeUTI, nil] autorelease];
}

+ (NSPasteboardReadingOptions)readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard 
{
    if ([type isEqualToString:CCNodeUTI]) 
    {
        /*
         This means you don't need to implement code for this type in initWithPasteboardPropertyList:ofType: -- initWithCoder: is invoked instead.
         */
        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}


@end

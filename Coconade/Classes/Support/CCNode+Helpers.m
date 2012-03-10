//
//  CCNode+Helpers.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import "CCNode+Helpers.h"
#import "cocos2d.h"

@interface CCDirectorMac (ScreenPointExtension)

- (CGPoint) convertScreenPointToGL: (NSPoint) screenPoint;

@end

@implementation CCDirectorMac (ScreenPointExtension)

- (CGPoint) convertScreenPointToGL: (NSPoint) screenPoint
{
    CCDirectorMac *director = (CCDirectorMac *)[CCDirector sharedDirector];
    NSView *glView = [director openGLView];
    NSWindow *window = [glView window];
    NSPoint point =  [window convertScreenToBase: screenPoint];
    point = [glView convertPoint: point fromView:nil];
	CGPoint p = NSPointToCGPoint(point);
	
	return  [director convertToLogicalCoordinates:p];
}

@end

@implementation CCNode (Helpers)

+ (BOOL) isScreenPoint: (NSPoint) screenPoint locatedInNode: (CCNode *) node
{
    return [self isScreenPoint: screenPoint locatedInNode:node withAreaExtension: CGSizeZero];
}

+ (BOOL) isScreenPoint: (NSPoint) screenPoint locatedInNode: (CCNode *) node withAreaExtension: (CGSize) areaExtension
{
    CGPoint pointInGL = [(CCDirectorMac *)[CCDirector sharedDirector] convertScreenPointToGL: screenPoint];
    CGPoint pointInNode = [node convertToNodeSpace: pointInGL];
    CGRect nodeRect = CGRectMake(- 0.5f * areaExtension.width, - 0.5f * areaExtension.height, node.contentSize.width + areaExtension.width, node.contentSize.height + areaExtension.height);
    return CGRectContainsPoint(nodeRect, pointInNode);
}

- (NSString *) defaultName
{
    NSString *name = [self className];
    
    if ([name hasPrefix: @"CC"] && [name length] > 2)
    {
        name = [name substringFromIndex: 2];
    }
    
    return name;
}

// TODO: think, should we use that andrews shit here:
    // make the key alphanumerical + underscore
    // NSCharacterSet *charactersToKeep = [NSCharacterSet characterSetWithCharactersInString:@"1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"];
    // aName = [[aName componentsSeparatedByCharactersInSet:[charactersToKeep invertedSet]] componentsJoinedByString:@"_"];	
+ (NSString *) uniqueNameWithName: (NSString *) nonUniqueName
{
	NSString *name = [NSString stringWithString: nonUniqueName];
	
    NSUInteger i = 1;
	while( [[CCNodeRegistry sharedRegistry] nodeByName: name] )
	{
		NSAssert(i != NSUIntegerMax, @"CCNode::uniqueNameWithName: There's too many nodes with same name!");
		name = [nonUniqueName stringByAppendingFormat:@"%u", i];
        i++;
	}
	
    return name;
}

- (NSString *) uniqueNameWithName: (NSString *) nonUniqueName
{
    CCNode *nodeWithSameName = [[CCNodeRegistry sharedRegistry] nodeByName: nonUniqueName];
    if (nonUniqueName && nodeWithSameName && nodeWithSameName == self )
    {
        return  nonUniqueName;
    }
    
    return [[self class] uniqueNameWithName:nonUniqueName];
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


@implementation CCNode (Parenting)

// TODO: check if it really can become parent or not.
- (BOOL) canBecomeParentOf: (CCNode *) aNode
{
    return YES;
}

@end
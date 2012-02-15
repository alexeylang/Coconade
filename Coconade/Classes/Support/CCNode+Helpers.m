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
    CCNode *nodeForName = [[CCNodeRegistry sharedRegistry] nodeByName: name];
	while( nodeForName )
	{
		NSAssert(i != NSUIntegerMax, @"CCNode::uniqueNameWithName: There's too many nodes with same name!");
		name = [nonUniqueName stringByAppendingFormat:@"_%u", i++];
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

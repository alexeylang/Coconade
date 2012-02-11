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

@end

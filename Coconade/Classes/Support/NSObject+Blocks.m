//
//  NSObject+Blocks.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov 
//  All rights reserved.
//

#import "NSObject+Blocks.h"
#import "cocos2d.h"

@implementation NSObject(Blocks)

-(void) CCN_performBlock: (void(^)()) aBlock
{
    if (aBlock)
    {
        aBlock();
    }
}

- (void)performBlock:(void(^)()) aBlock onThread:(NSThread *)aThread waitUntilDone:(BOOL)wait
{
    if (!wait) 
    {
        aBlock = [aBlock copy];
    }
    
    [self performSelector: @selector(CCN_performBlock:) 
                 onThread: aThread 
               withObject: aBlock 
            waitUntilDone: wait ];
    
    if (!wait) 
    {
        [aBlock release];
    }
}

- (void) performBlockOnCocosThread:(void (^)())aBlock 
{
    NSThread *cocosThread = [[CCDirector sharedDirector] runningThread];
    
    BOOL wait = [NSThread currentThread] == cocosThread;
    [self performBlock: aBlock onThread: cocosThread waitUntilDone:wait ];
}

- (void) performBlockOnMainThread:(void (^)())aBlock
{
    [self performBlock: aBlock onThread:[NSThread mainThread] waitUntilDone: [NSThread isMainThread]];
}

@end
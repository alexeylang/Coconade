//
//  NSObject+Blocks.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov 
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Blocks)

/** Performs given block on given thread. */
- (void)performBlock:(void(^)()) aBlock onThread:(NSThread *)aThread waitUntilDone:(BOOL)wait;

/** Performs given block on CCDirector::runningThread without waiting. */
- (void) performBlockOnCocosThread:(void (^)())aBlock;

/** Performs given block on mainThread without waiting.  */
- (void) performBlockOnMainThread:(void (^)())aBlock;

@end
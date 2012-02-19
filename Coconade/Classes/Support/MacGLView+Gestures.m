//
//  MacGLView+Gestures.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import "MacGLView+Gestures.h"

#if CC_DIRECTOR_MAC_USE_DISPLAY_LINK_THREAD
#define DISPATCH_EVENT(__event__, __selector__) [eventDelegate_ queueEvent:__event__ selector:__selector__];
#else
#define DISPATCH_EVENT(__event__, __selector__)												\
    id obj = eventDelegate_;																\
    [obj performSelector:__selector__														\
                onThread:[(CCDirectorMac*)[CCDirector sharedDirector] runningThread]			\
              withObject:__event__																\
           waitUntilDone:NO];
#endif

@implementation MacGLView (Gestures)

- (void)magnifyWithEvent:(NSEvent *)event
{
    DISPATCH_EVENT(event, _cmd);
}

- (void)rotateWithEvent:(NSEvent *)event
{
	DISPATCH_EVENT(event, _cmd);
}

- (void)swipeWithEvent:(NSEvent *)event
{
	DISPATCH_EVENT(event, _cmd);
}

@end

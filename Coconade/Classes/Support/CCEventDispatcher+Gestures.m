//
//  CCEventDispatcher+Gestures.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import "CCEventDispatcher+Gestures.h"

enum 
{
    kCCImplementsMagnify = 1 << 17,
    kCCImplementsRotate  = 1 << 18,
};


@interface CCEventDispatcher (Private)

typedef struct _listEntry
{
	struct	_listEntry	*prev, *next;
	id					delegate;
	NSInteger			priority;
	NSUInteger			flags;
} tListEntry;

-(void) addDelegate:(id)delegate priority:(NSInteger)priority flags:(NSUInteger)flags list:(tListEntry**)list;
-(void) removeDelegate:(id)delegate fromList:(tListEntry**)list;

@end

@implementation CCEventDispatcher (Gestures)

#pragma mark Add / Remove Gesture Delegates

-(void) addGestureDelegate:(id<CCGestureEventDelegate>) delegate priority:(NSInteger)priority
{
	NSUInteger flags = 0;
	
	flags |= ( [delegate respondsToSelector:@selector(ccMagnifyWithEvent:)] ? kCCImplementsMagnify : 0 );
	flags |= ( [delegate respondsToSelector:@selector(ccRotateWithEvent:)] ? kCCImplementsRotate : 0 );
	
	[self addDelegate:delegate priority:priority flags:flags list:&touchDelegates_];
}

-(void) removeGestureDelegate:(id) delegate
{
	[self removeDelegate:delegate fromList:&touchDelegates_];
}

#pragma mark Trackpad Gesture Events

- (void)rotateWithEvent:(NSEvent *)event
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsRotate) {
				void *swallows = [entry->delegate performSelector:@selector(ccRotateWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}	
}

- (void)magnifyWithEvent:(NSEvent *)event;
{
	if( dispatchEvents_ ) {
		tListEntry *entry, *tmp;
		
		DL_FOREACH_SAFE( touchDelegates_, entry, tmp ) {
			if ( entry->flags & kCCImplementsMagnify) {
				void *swallows = [entry->delegate performSelector:@selector(ccMagnifyWithEvent:) withObject:event];
				if( swallows )
					break;
			}
		}
	}	
}

@end

//
//  CCEventDispatcher+Gestures.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import "CCEventDispatcher.h"

/** @protocol CCGesturesEventDelegate Extension to CCEventDispatcher
 * protocols, that adds gesture support on a Mac.
 * Implement it in your node to receive any of gesture events.
 */
@protocol CCGesturesEventDelegate <NSObject>

@optional

/** Informs the receiver that the user has begun a pinch gesture.
 * (magnidyWithEvent: event).
 *
 * @param event An event object representing the pinch gesture. 
 *
 * Return YES to avoid propagating the event to other delegates.
 */
- (BOOL)ccMagnifyWithEvent:(NSEvent *)event;

/** Informs the receiver that the user has begun a rotate gesture.
 * (rotateWithEvent: event).
 *
 * @param event An event object representing the rotate gesture. 
 *
 * Return YES to avoid propagating the event to other delegates.
 */
- (BOOL)ccRotateWithEvent:(NSEvent *)event;

@end

/** @category Gestures Additional methods for CCEventDispatcher
 * to support gesture events.
 */
@interface CCEventDispatcher (Gestures)

/** Adds a Gesture delegate to the dispatcher's list, using the same code, that
 * uses CCEventDispatcher:addTouchDelegate:priority:.
 *
 * Gestures delegates are stored in touchDelegates list, so -removeTouchDelegate:
 * and -removeAllTouchDelegates will remove gestures delegates too.
 *
 * Delegates with a lower priority value will be called before higher priority values.
 * All the events will be propagated to all the delegates, unless the one delegate returns YES.
 *
 * IMPORTANT: The delegate will be retained.
 */
-(void) addGestureDelegate:(id<CCGesturesEventDelegate>) delegate priority:(NSInteger)priority;

/** Removes a gesture delegate, releasing it. 
 * Gestures delegates are stored in touchDelegates list, so this method can
 * remove touch delegates too.
 */
-(void) removeGestureDelegate:(id) delegate;

@end

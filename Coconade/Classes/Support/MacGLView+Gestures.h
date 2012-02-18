//
//  MacGLView+Gestures.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov. 
//  All rights reserved.
//

#import "MacGLView.h"

/** @category Gestures Additional methods to MacGLView to
 * dispatch gesture events to CCEventDispatcher.
 *
 * @see CCEventDispatcher+Gestures.
 */
@interface MacGLView (Gestures)

/** Informs the receiver that the user has begun a pinch gesture.
 * (magnidyWithEvent: event).
 *
 * @param event An event object representing the pinch gesture.
 */
- (void)magnifyWithEvent:(NSEvent *)event;

/** Informs the receiver that the user has begun a rotate gesture.
 * (magnidyWithEvent: event).
 *
 * @param event An event object representing the rotate gesture.
 */
- (void)rotateWithEvent:(NSEvent *)event;

@end

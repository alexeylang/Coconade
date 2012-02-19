//
//  CSMacGLView.h
//  Coconade
//
//  Copyright (c) 2011-2012 Stepan Generalov
//  All rights reserved.
//

// TODO: rename to CCNMacGLView.

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"

/** Notification that is sent, when CCNMacGLView instance's workspaceSize is changed. */
FOUNDATION_EXPORT NSString *const CCNMacGLViewWorkspaceSizeDidChangeNotification;


@protocol CCNMacGLViewDragAndDropDelegate;
@interface CSMacGLView : MacGLView <CCProjectionProtocol>
{
	ccDirectorProjection _projection;
	
	CGSize _workspaceSize;
	CGFloat _zoomFactor;	
	CGFloat _zoomSpeed; 
	CGFloat _zoomFactorMax;
	CGFloat _zoomFactorMin;
    
    id <CCNMacGLViewDragAndDropDelegate> _dragAndDropDelegate;
}

/** Size of the viewport, this property sets CCDirector#winSize and
 * is used in Cocoshop for setting workspace size
 *
 * Due to NSGLView restrictions and zoom functionalty of the CSMacGLView
 * this value isn't always equal to view's frame size.
 * 
 * After each change of this value - updateView get's called automatically &
 * CCNMacGLViewWorkspaceSizeDidChangeNotification is sent.
 */
@property (readwrite) CGSize workspaceSize;

/** Since CSMacGLView uses custom projection
 * we need a method, that will allow us to choose between 2D/3D projections
 * without cancelling custom projection.
 * Use this property to set kCCDirectorProjection3D || kCCDirectorProjection2D
 * Do not set projection with CCDirector#setProjection: while using CSMacGLView !
 * Custom projection isn't supported, but you can easily add it by implementing
 * delegate property and copypasting some code from MacGLView
 */
@property (readwrite) ccDirectorProjection projection;

/** Zoom factor just like in GIMP or other graphics editors
 * Zooms the node with changing glViewport
 * 1.0f is for 100% Scale
 */
@property (readwrite) CGFloat zoomFactor;

/** How fast to zoom (default is 0.1f)
 */
@property (readwrite) CGFloat zoomSpeed;

/** Maximum zoom (default is 3.0f)
 */
@property (readwrite) CGFloat zoomFactorMax;

/** Minimum zoom (default is 0.1f)
 */
@property (readwrite) CGFloat zoomFactorMin;

@property (readwrite, assign) id <CCNMacGLViewDragAndDropDelegate> dragAndDropDelegate;

/** Updates view size, to show scrollers of NSScrollView
 */
- (void) updateView;

/* Resizes the View for Centering the Workspace in Window
 * This is needed cause it's impossible to set the position of contentNode of
 * NSScrollView */
- (void) updateFrameSize;

/** Reset the zoom to default
 */
- (void)resetZoom;

@end


@protocol CCNMacGLViewDragAndDropDelegate <NSObject>

@required

/** Called on delegate when glView receives -draggingEntered: message
 * Return value of this method will be returned in CCNMacGLView#draggingEntered:
 */

- (NSDragOperation)ccnMacGLView: (CSMacGLView *) glView draggingEntered:(id <NSDraggingInfo>)sender;
/** Called on delegate when glView receives -performDragOperation: message
 * Return value of this method will be returned in CCNMacGLView#performDragOperation:
 */
- (BOOL)ccnMacGLView: (CSMacGLView *) glView performDragOperation:(id <NSDraggingInfo>)sender; 

@end
//
//  CSMacGLView.m
//  Coconade
//
//  Copyright (c) 2011-2012 Stepan Generalov
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNMacGLView.h"
#import "DebugLog.h"

@interface CCNMacGLView ()

/* This methods calculates offset (rect.origin) and width & height aspect (rect.size) 
 * of the viewport. 
 * Normal center positioning doesnt work for CSMacGLView - we will simulate it with
 * projection offset change & view resize. 
 */
- (CGRect) viewportRect;

@end


@implementation CCNMacGLView

@synthesize zoomFactor = _zoomFactor; 
@synthesize zoomSpeed = _zoomSpeed;
@synthesize zoomFactorMax = _zoomFactorMax; 
@synthesize zoomFactorMin = _zoomFactorMin;
@dynamic dragAndDropDelegate;
- (id<CCNMacGLViewDragAndDropDelegate>) dragAndDropDelegate
{
    return _dragAndDropDelegate;
}

- (void) setDragAndDropDelegate:(id<CCNMacGLViewDragAndDropDelegate>)dragAndDropDelegate
{
    [self unregisterDraggedTypes];
    
    _dragAndDropDelegate = dragAndDropDelegate;
    
    [self registerForDraggedTypes: [_dragAndDropDelegate ccnMacGLViewSupportedDraggedTypes: self]];    
}

@dynamic workspaceSize;
- (CGSize) workspaceSize
{
    return _workspaceSize;
}

- (void) setWorkspaceSize:(CGSize)workspaceSize
{
    CGSize oldSize = _workspaceSize;
    _workspaceSize = workspaceSize;
    
    if (!CGSizeEqualToSize(oldSize, workspaceSize))
    {
        [self updateView];
    }
}

@dynamic projection;
- (void) setProjection:(ccDirectorProjection) newProjection
{
	_projection = newProjection;
	[self updateProjection];
}

- (ccDirectorProjection) projection
{
	return _projection;
}

#pragma mark Init / DeInit

- (id)init
{	
    if ( (self = [super init]) )
    {
        // Setup Zoom Settings
        self.zoomSpeed = 0.01f;
        self.zoomFactorMin = 0.1f;
        self.zoomFactorMax = 3.0f;	
        self.zoomFactor = 1.0f;
        self.frame = CGRectMake(0.0f, 0.0f, 480.0f, 320.0f);
        
        // Setup Projection
        _projection = kCCDirectorProjection2D;
    }
    return self;
}

- (void) dealloc
{
	[super dealloc];
}

#pragma mark Updates

- (void) updateFrameSize
{
	// Size is equal to self.workspaceSize
	CGSize size = [CCDirector sharedDirector].winSize;
	
	// Get the Real Size of Workspace in Pixels
	float widthAspect = size.width * self.zoomFactor;
	float heightAspect = size.height * self.zoomFactor;
	
	// Resize self frame if Real Size of Workspace is less than available space in the Window
	CGSize superViewFrameSize = self.superview.frame.size;
	CGSize frameSize = self.frame.size;

	frameSize.width = MAX(widthAspect, superViewFrameSize.width);
	frameSize.height = MAX(heightAspect, superViewFrameSize.height);
	[self setFrameSize: frameSize];
}

- (CGRect) viewportRect
{
	CGSize size = [CCDirector sharedDirector].winSize;
	CGRect rect = [self visibleRect];	
	CGSize superViewFrameSize = self.superview.frame.size;
    
	CGPoint offset = CGPointMake(- rect.origin.x, - rect.origin.y);
	float widthAspect = size.width * self.zoomFactor;
	float heightAspect = size.height * self.zoomFactor;
	
	if ( widthAspect < superViewFrameSize.width )
    {
		offset.x = ( superViewFrameSize.width - widthAspect ) / 2.0f;
    }
	
	if ( heightAspect < superViewFrameSize.height )
    {
		offset.y = ( superViewFrameSize.height - heightAspect ) / 2.0f;
    }
	
	return CGRectMake(offset.x , offset.y, widthAspect, heightAspect);
}

- (void) updateView
{
    [self updateFrameSize];
	[self reshape];
}

#pragma mark CCProjectionProtocol

/* Works just like kCCDirectorProjection2D, but uses visibleRect instead 
 * of only size of the window */
- (void) updateProjection
{	
	CGRect offsetAspectRect = [self viewportRect];
	CGPoint offset = offsetAspectRect.origin;
	CGSize aspect = offsetAspectRect.size;	
	
	switch (_projection) 
    {
		case kCCDirectorProjection2D:
			glViewport(offset.x, offset.y, aspect.width, aspect.height);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			ccglOrtho(0, self.workspaceSize.width, 0, self.workspaceSize.height, -1024, 1024);
			glMatrixMode(GL_MODELVIEW);
			glLoadIdentity();
			break;
			
		case kCCDirectorProjection3D:
			glViewport(offset.x, offset.y, aspect.width, aspect.height);
			glMatrixMode(GL_PROJECTION);
			glLoadIdentity();
			gluPerspective(60, (GLfloat)aspect.width/aspect.height, 0.1f, 1500.0f);
			
			glMatrixMode(GL_MODELVIEW);	
			glLoadIdentity();
			
			float eyeZ = [[CCDirector sharedDirector] getZEye];
			
			gluLookAt(self.workspaceSize.width / 2, self.workspaceSize.height / 2, eyeZ,
					  self.workspaceSize.width / 2, self.workspaceSize.height / 2, 0,
					  0.0f, 1.0f, 0.0f);			
			break;
			
		default:
			DebugLog(@"Unsupported Projection");
			break;
	}
}

#pragma mark MacGLView

/* Reshape that uses self.workspaceSize instead of self bounds */
- (void) reshape
{
	// We draw on a secondary thread through the display link
	// When resizing the view, -reshape is called automatically on the main thread
	// Add a mutex around to avoid the threads accessing the context simultaneously when resizing
	CGLLockContext([[self openGLContext] CGLContextObj]);
	
	CCDirector *director = [CCDirector sharedDirector];
	[director reshapeProjection: self.workspaceSize];
	
	// avoid flicker
	[director drawScene];
	
	CGLUnlockContext([[self openGLContext] CGLContextObj]);
}

#pragma mark NSView

/* Fixes cordinate conversion when zooming, or scrolling or centering is applied */
- (NSPoint)convertPoint:(NSPoint)aPoint fromView:(NSView *)aView
{
	NSPoint p = [super convertPoint: aPoint fromView: aView];
	
	// Apply offset only when Centered 
	CGPoint offset = [self viewportRect].origin;
	offset.x = MAX(offset.x, 0);
	offset.y = MAX(offset.y, 0);
	p.x -= offset.x;
	p.y -= offset.y;
	
	// Apply Zooming
	p.x /= self.zoomFactor;
	p.y /= self.zoomFactor;
	
	return p;
}

#pragma mark Drag & Drop Support

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender 
{	
	return [self.dragAndDropDelegate ccnMacGLView: self draggingEntered: sender];
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
    return [self.dragAndDropDelegate ccnMacGLView: self performDragOperation: sender];
}

#pragma mark Zoom

- (void) resetZoom
{
	self.zoomFactor = 1.0f;
	
	// Update Window
	[[NSNotificationCenter defaultCenter] postNotificationName: NSWindowDidResizeNotification object:[self window]];
	[self reshape]; //< without this line there will be no update with zoomFactor < 1
}

@end

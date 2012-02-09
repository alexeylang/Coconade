/*
 * Coconade
 *
 * Copyright (c) 2012 Alexey Lang
 *
 */

#import "CNWindowController.h"
#import "CSMacGLView.h"


@implementation CNWindowController

@synthesize glView = _glView;

- (void) dealloc
{
    self.glView = nil;
    
    [super dealloc];
}

@end

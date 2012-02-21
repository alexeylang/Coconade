//
//  main.m
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "cocos2d.h"
#import "CCNMacGLView.h"
#import "CoconadeAppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int result = 0;
    @try 
    {
        [CCNMacGLView load_];
        [NSApplication sharedApplication].delegate = [[[CoconadeAppDelegate alloc] init] autorelease];
        result = NSApplicationMain(argc,  (const char **) argv);
    }
    @catch (NSException *exception) 
    {
        NSLog(@"%@", exception);
    }
    [pool drain];
    
    return result;
}

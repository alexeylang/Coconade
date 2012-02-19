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

int main(int argc, char *argv[])
{
    int result = 0;
    @try 
    {
        [CCNMacGLView load_];
        result = NSApplicationMain(argc,  (const char **) argv);
    }
    @catch (NSException *exception) 
    {
        NSLog(@"%@", exception);
    }
    
    return result;
}

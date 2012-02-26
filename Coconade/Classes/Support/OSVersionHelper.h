//
//  OSVersionHelper.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov
//  All rights reserved.
//

#ifndef Coconade_OSVersionHelper_h
#define Coconade_OSVersionHelper_h

#import <CoreServices/CoreServices.h>

static inline BOOL lionFeaturesAvailable()
{
    SInt32 version = 0;
    Gestalt( gestaltSystemVersion, &version );
    
    return ( version >= 0x1070 );
}

#endif

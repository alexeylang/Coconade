//
//  OSVersionHelper.h
//  Coconade
//
//  Created by Stepan Generalov on 26.02.12.
//  Copyright (c) 2012 sg@game-insight.com. All rights reserved.
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

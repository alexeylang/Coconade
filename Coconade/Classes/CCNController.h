//
//  CCNController.h
//  Coconade
//
//  Copyright (c) 2012 Stepan Generalov.
//  All rights reserved.
//

#import <Foundation/Foundation.h>

@class CCNModel;

/** @class CCNController Main logic controller for Coconade. */
@interface CCNController : NSObject
{
    CCNModel *_model;
}

/** Model of current project. Changing model will lead to changing all
 * current open context.
 */
@property(readwrite, retain) CCNModel *model;

@end

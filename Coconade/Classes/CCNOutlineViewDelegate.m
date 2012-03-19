//
//  CCNOutlineViewDelegate.m
//  Coconade
//
//  Copyright (c) 2012 Alexey Lang
//  All rights reserved.
//

#import "CCNOutlineViewDelegate.h"
#import "CCNImageTextCell.h"
#import "cocos2d.h"
#import "CCNModel.h"
#import "CCNOutlineGroupItem.h"

#define kCCNWindowControllerModelOutlineRootItemsCount              1
#define kCCNWindowControllerModelOutlineRootItemNodesName           @"NODES"
#define kCCNWindowControllerModelOutlineRootItemNodesIndex          0
#define kCCNWindowControllerModelOutlineRootItemTexturesName        @"TEXTURES"
#define kCCNWindowControllerModelOutlineRootItemTexturesIndex       1
#define kCCNWindowControllerModelOutlineRootItemSpriteframesName    @"SPRITEFRAMES"
#define kCCNWindowControllerModelOutlineRootItemSpriteframesIndex   2
#define kCCNWindowControllerModelOutlineRootItemAnimationsName      @"ANIMATIONS"
#define kCCNWindowControllerModelOutlineRootItemAnimationsIndex     3
#define kCCNWindowControllerModelOutlineRootItemFontsName           @"FONTS"
#define kCCNWindowControllerModelOutlineRootItemFontsIndex          4


@interface CCNOutlineViewDelegate ()

@property (readwrite, retain) CCNOutlineGroupItem *nodeGroupItem;

@end


@implementation CCNOutlineViewDelegate

@synthesize nodeGroupItem = _nodeGroupItem;

#pragma mark Init/Create

+ (id)delegateWithModel:(CCNModel *)model
{
    return [[[self alloc] initWithModel:model] autorelease];
}

- (id)initWithModel:(CCNModel *)model
{
    if ( (self = [super init]) )
    {
        self.nodeGroupItem = [CCNOutlineGroupItem itemWithName:kCCNWindowControllerModelOutlineRootItemNodesName];
    }
    
    return self;
}

- (void)dealloc
{
    self.nodeGroupItem = nil;
    
    [super dealloc];
}

#pragma mark OutlineView Delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item;
{
    return YES;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSCell *returnCell = [tableColumn dataCell];
    return returnCell;
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    CCNImageTextCell *imageTextCell = cell;
    if ( [item isKindOfClass:[NSNumber class]] )
    {
        imageTextCell.isGroup = YES;
        imageTextCell.iconImage = nil;
    }  
    else if ( [item isKindOfClass:[CCNode class]] )
    {
        imageTextCell.isGroup = NO;
        imageTextCell.iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(kGenericFolderIcon)];
    }        
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    if ( [item isKindOfClass:[NSNumber class]] )
    {
        return YES;
    }
    
    return NO;
}

#pragma mark OutlineView DataSource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if ( item )
    {
        if ( [item isKindOfClass:[NSNumber class]] )
        {
            switch ( [item intValue] ) 
            {
                case kCCNWindowControllerModelOutlineRootItemNodesIndex:
                    return [self.model.rootNodes objectAtIndex:index];
            }
        }
        else if ( [item isKindOfClass:[CCNode class]] )
        {
            CCNode *itemNode = (CCNode *)item;
            return [itemNode.children objectAtIndex:index];
        }        
    }
    else
    {
        return [NSNumber numberWithInt:index];
    }
    
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ( item )
    {
        if ( [item isKindOfClass:[NSNumber class]] )
        {
            return YES;
        }
        else if ( [item isKindOfClass:[CCNode class]] )
        {
            CCNode *itemNode = (CCNode *)item;
            return (itemNode.children.count != 0);            
        }        
    }
    
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if ( item )
    {
        if ( [item isKindOfClass:[NSNumber class]] )
        {
            switch ( [item intValue] ) 
            {
                case kCCNWindowControllerModelOutlineRootItemNodesIndex:
                    return self.model.rootNodes.count;
            }
        }
        else if ( [item isKindOfClass:[CCNode class]] )
        {
            CCNode *itemNode = (CCNode *)item;
            return itemNode.children.count;
        }        
    }
    else
    {
        return kCCNWindowControllerModelOutlineRootItemsCount;
    }
    
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ( item )
    {
        if ( [item isKindOfClass:[NSNumber class]] )
        {
            switch ( [item intValue] ) 
            {
                case kCCNWindowControllerModelOutlineRootItemNodesIndex:
                    return kCCNWindowControllerModelOutlineRootItemNodesName;
            }
        }
        else if ( [item isKindOfClass:[CCNode class]] )
        {
            CCNode *itemNode = (CCNode *)item;
            return [NSString stringWithFormat:@"%@ : (%@)", itemNode.name, NSStringFromClass([itemNode class])];
        }        
    }
    
    return nil;
}

@end

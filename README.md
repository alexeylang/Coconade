Coconade - Professional Cocos2D-iPhone Editor
================================================

Coconade is GUI for Cocos2D-iPhone framework.   
It operates Cocos2D-iPhone entities, making them friendly & easy-to-use even for non-programmer.


Philosophy
---------------------

Coconade diverged from Cocoshop 0.1 and inherits best parts of it's philosophy. 

 1. Tiny, __easy to use__ visual editor for Cocos2D-iPhone Engine, that can be used for designing menus, game scenes and even levels.
 2. Idea is to have maybe less features, but only necessary, good polished, well designed and really easy and comfortable to use. 

Features
---------------------

__Cocoshop 0.1 features:__

In cocoshop you edit a node. Currently it supports background and sprites.  
You can change the size of the node, change it's background color & opacity.  
You can add sprites by drag&drop them to the main window, or by clicking 'Add Sprite' toolbar item.

Sprites have unique names, that you will use to distinguish individual sprites in your application code.  
Sprites can be positioned/scaled/rotated with mouse, keyboard shortcuts, trackpad gestures and the Sprite Info Window.


__Coconade Beta - Cocoshop 0.1 with following changes:__

 1. AMC for serialization.
 2. New UI - closable side views for navigator & properties (Xcode-style).
 3. Ability to have few Root CCNodes in Navigator (instead of using Chrome Tabs)
 4. Solid graphical editing mode for selected node (including Issue #6 ).
    * position, rotate & scale with TouchPad
    * position, rotate & scale with Mouse
    * ADDITIONALLY: skew & change anchorPoint with mouse
 5. More node classses - all that have AMC support.
 6. Library (Navigator - Left Pane), that includes (beta):
    * Textures (CCTextureCache) - read-only
    * Sprite Frames (CCSpriteFrameCache) - read-only
    * Nodes (dictionary _nodes in CCNModel) - full editing
 7. Coconade project bundle ( *.coconade ? ) that
    * includes AMC plist/json  - nodes dictionary (described above).
    * includes imported resurces, that Coconade supports (textures & spriteFrames plists for Beta)
    (when importing to coconade supported files are just copied to our bundle & loaded into cocos2d (ADDITIONALLY: ask user - copy or link file))
    * when starting new project - ask where to save it immediately - Xcode style
 8. AutoSave, Undo/Redo, Reload Resources / Reload Project button at the right of LeftPane/RightPange trigger in top bar.
 9. Export - 
    * All root nodes in one file - simply save _nodes dictionary OR every root node in independent file.
    * Only few of root nodes - ability to select all/few and if few - select which.
    * Format: json OR plist, 
    * Export with/without resources (just by copying them from bundle or from linked path for linked files)

Development Status
=====================

__ABANDONED__
Mouse & Trackpad controls can be useful in CocosBuilder
 
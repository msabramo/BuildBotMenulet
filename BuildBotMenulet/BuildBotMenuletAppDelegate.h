//
//  BuildBotMenuletAppDelegate.h
//  BuildBotMenulet
//
//  Created by Marc Abramowitz on 5/13/11.
//  Copyright 2011 BlueKai. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BuildBotMenuletAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSMutableArray *recentBuilds;
    NSWindow *window;
    NSStatusItem *statusItem;
    NSMenu *menu;
}

@property (assign) IBOutlet NSWindow *window;

@end

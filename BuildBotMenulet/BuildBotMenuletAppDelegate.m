//
//  BuildBotMenuletAppDelegate.m
//  BuildBotMenulet
//
//  Created by Marc Abramowitz on 5/13/11.
//  Copyright 2011 BlueKai. All rights reserved.
//

#import "BuildBotMenuletAppDelegate.h"
#import "RegexKitLite.h"

@implementation BuildBotMenuletAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *path = [bundle pathForImageResource:@"buildbot"];
    NSImage *menuIcon = [[NSImage alloc] initWithContentsOfFile:path];
    
    statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
    [statusItem setHighlightMode:YES];
    [statusItem setImage:menuIcon];
    [statusItem setTitle:@""]; 
    [statusItem setEnabled:YES];
    [statusItem setToolTip:@"Buildbot Monitor"];

    menu = [[NSMenu alloc] initWithTitle:@"Menu"];    
    [statusItem setMenu:menu];
    
    [statusItem setAction:@selector(onClick:)];
    [statusItem setTarget:self];
    
    recentBuilds = [[NSMutableArray alloc] init];
    
    [self update];
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(update) userInfo:nil repeats:YES];
}

- (void)update
{
    NSLog(@"update called.\n");
    
    NSError *err = nil;
    NSURL *furl = [NSURL URLWithString:@"http://ec2-50-17-192-5.compute-1.amazonaws.com:8081/rss/"];
    
    NSXMLDocument *xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:furl options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA) error:&err];
    
    if (!xmlDoc)
    {
        
    }
    
    NSArray *result = [xmlDoc nodesForXPath:@"//item" error:&err];
    
    if (!result)
    {
        
    }
    
    [menu removeAllItems];
    
    for (int i = 0; i < MIN(5, [result count]); i++)
    {
        NSXMLNode *itemNode = [result objectAtIndex:i];
        NSXMLNode *titleNode = [[itemNode nodesForXPath:@"title" error:&err] objectAtIndex:0];
        NSString *title = [titleNode stringValue];
        NSXMLNode *linkNode = [[itemNode nodesForXPath:@"link" error:&err] objectAtIndex:0];
        NSString *link = [linkNode stringValue];
        
        NSString *buildNumber = [link stringByMatching:@"(\\d+)$"];
        
        NSString *menuText = [NSString stringWithFormat:@"[%@] %@", buildNumber, title];
        
        [recentBuilds insertObject:link atIndex:i];
        
        // NSLog(@"result [%d] = %@\n", i, [result objectAtIndex:i]);
        /*
        if (i == 0)
        {
            [statusItem setTitle:title];
        }
         */
        
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:menuText action:@selector(onClickItem:) keyEquivalent:@""];

        if ([menuText rangeOfString:@"succeeded"].location != NSNotFound)
        {
            // menuText = [NSString stringWithFormat:@"[PASS] %@", menuText];
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *path = [bundle pathForImageResource:@"GreenDotIcon"];
            NSImage *greenDotIcon = [[NSImage alloc] initWithContentsOfFile:path];
            [menuItem setImage:greenDotIcon];
        }
        if ([menuText rangeOfString:@"failed"].location != NSNotFound)
        {
            // menuText = [NSString stringWithFormat:@"[FAIL] %@", menuText];
            NSBundle *bundle = [NSBundle bundleForClass:[self class]];
            NSString *path = [bundle pathForImageResource:@"RedDotIcon"];
            NSImage *redDotIcon = [[NSImage alloc] initWithContentsOfFile:path];
            [menuItem setImage:redDotIcon];
        }
        
        // [menuItem setValue:link forKey:@"link"];
        [menuItem setTag:i];
        [menu addItem:menuItem];
        
        // [menu addItemWithTitle:title action:@selector(onClickItem:) keyEquivalent:@""];
    }    
}

- (IBAction)onClickItem:(id)menuItem
{
    NSString *link = [recentBuilds objectAtIndex:[menuItem tag]];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:link]];
}

@end
//
//  MarvinSettingsWindowController.m
//  MarvinPlugin
//
//  Created by David Peak on 6/3/15.
//  Copyright (c) 2015 Octalord Information Inc. All rights reserved.
//

#import "MarvinSettingsWindowController.h"

@interface MarvinSettingsWindowController ()
{
    NSDictionary   *_defaults;
    NSUserDefaults *_userDefaults;
}

@end

@implementation MarvinSettingsWindowController

- (id)initWithBundle:(NSBundle *)bundle
{
    NSString *nibPath = [bundle pathForResource:@"Settings" ofType:@"nib"];
    self = [super initWithWindowNibPath:nibPath owner:self];
    if (self)
    {
        NSString *defaultsFilePath = [bundle pathForResource:@"Defaults" ofType:@"plist"];
        _defaults = [NSDictionary dictionaryWithContentsOfFile:defaultsFilePath];
        _userDefaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end

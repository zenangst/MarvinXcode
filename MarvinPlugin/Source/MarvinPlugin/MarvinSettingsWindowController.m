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

@end

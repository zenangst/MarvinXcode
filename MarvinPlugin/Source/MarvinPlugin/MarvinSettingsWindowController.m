//
//  MarvinSettingsWindowController.m
//  MarvinPlugin
//
//  Created by David Peak on 6/3/15.
//  Copyright (c) 2015 Octalord Information Inc. All rights reserved.
//

#import "MarvinSettingsWindowController.h"

@interface MarvinSettingsWindowController () {}

@end

@implementation MarvinSettingsWindowController

- (id)initWithBundle:(NSBundle *)bundle
{
    NSString *nibPath = [bundle pathForResource:@"Settings" ofType:@"nib"];
    self = [super initWithWindowNibPath:nibPath owner:self];
    return self;
}

@end

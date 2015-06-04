//
//  MarvinSettingsWindowController.h
//  MarvinPlugin
//
//  Created by David Peak on 6/3/15.
//  Copyright (c) 2015 Octalord Information Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MarvinSettingsWindowController : NSWindowController

@property (weak) IBOutlet NSButton *shouldRemoveWhitespace;

- (instancetype)initWithBundle:(NSBundle *)bundle;

@end

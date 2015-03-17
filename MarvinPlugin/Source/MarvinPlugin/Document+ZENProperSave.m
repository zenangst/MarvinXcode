//
//  NSDocument+ZENProperSave.m
//  MarvinPlugin
//
//  Created by Christoffer Winterkvist on 3/17/15.
//  Copyright (c) 2015 Octalord Information Inc. All rights reserved.
//

#import "Document+ZENProperSave.h"
#import <objc/runtime.h>

@implementation NSDocument (ZENProperSave)

- (void)zen_saveDocumentWithDelegate:(id)delegate
                      didSaveSelector:(SEL)didSaveSelector
                          contextInfo:(void *)contextInfo {

    if ([self zen_shouldFormat]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Save properly" object:nil];
    }

    [self zen_saveDocumentWithDelegate:delegate
                        didSaveSelector:didSaveSelector
                            contextInfo:contextInfo];
}

+ (void)load {
    Method original, swizzle;

    original = class_getInstanceMethod(self, NSSelectorFromString(@"saveDocumentWithDelegate:didSaveSelector:contextInfo:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString( @"zen_saveDocumentWithDelegate:didSaveSelector:contextInfo:"));

    method_exchangeImplementations(original, swizzle);
}

- (BOOL)zen_shouldFormat {
    return [[NSSet setWithObjects:@"c", @"h", @"cpp", @"cc", @"hpp", @"ipp", @"m", @"mm", @"swift", nil] containsObject:[[[self fileURL] pathExtension] lowercaseString]];
}

@end

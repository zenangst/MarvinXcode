//
//  NSTextView+ChangeMarks.m
//  ChangeMarks
//
//  Created by Christoffer Winterkvist on 27/03/15.
//  Copyright (c) 2015 zenangst. All rights reserved.
//

#import "NSTextView+ChangeMarks.h"
#import <objc/runtime.h>

@implementation NSTextView (ChangeMarks)

- (BOOL)zen_readSelectionFromPasteboard:(NSPasteboard *)pboard
{
    NSPasteboard *generalPasteboard  = [NSPasteboard generalPasteboard];
    NSString *pastedString = [generalPasteboard  stringForType:NSPasteboardTypeString];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Paste change mark" object:pastedString];
    });


    return [self zen_readSelectionFromPasteboard:pboard];
}

- (void)zen_insertText:(id)insertString
{
    [self zen_insertText:insertString];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"Add change mark" object:insertString];
}

+ (void)load
{

    Method original, swizzle;

    original = class_getInstanceMethod(self, NSSelectorFromString(@"didChangeText"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_didChangeText"));

    method_exchangeImplementations(original, swizzle);

    original = class_getInstanceMethod(self, NSSelectorFromString(@"readSelectionFromPasteboard:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_readSelectionFromPasteboard:"));

    method_exchangeImplementations(original, swizzle);

    original = class_getInstanceMethod(self, NSSelectorFromString(@"insertText:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_insertText:"));

    method_exchangeImplementations(original, swizzle);
}

@end

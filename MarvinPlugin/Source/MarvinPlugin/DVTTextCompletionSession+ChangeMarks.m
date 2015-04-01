//
//  DVTTextCompletionSession+ChangeMarks.m
//  MarvinPlugin
//
//  Created by Christoffer Winterkvist on 30/03/15.
//  Copyright (c) 2015 Octalord Information Inc. All rights reserved.
//

#import "DVTTextCompletionSession+ChangeMarks.h"
#import "IDEIndexCompletionItem.h"
#import <objc/runtime.h>

@implementation DVTTextCompletionSession (ChangeMarks)

- (BOOL)zen_handleTextViewShouldChangeTextInRange:(struct _NSRange)arg1 replacementString:(id)arg2
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Add change mark" object:@{@"location":@(arg1.location), @"length":@(arg1.length)}];
    });

    return [self zen_handleTextViewShouldChangeTextInRange:arg1 replacementString:arg2];
}

- (BOOL)zen_insertCurrentCompletion
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Insert change mark" object:nil];
    });

    return [self zen_insertCurrentCompletion];
}

+ (void)load
{
    Method original, swizzle;

    original = class_getInstanceMethod(self, NSSelectorFromString(@"handleTextViewShouldChangeTextInRange:replacementString:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_handleTextViewShouldChangeTextInRange:replacementString:"));
    method_exchangeImplementations(original, swizzle);

    original = class_getInstanceMethod(self, NSSelectorFromString(@"insertCurrentCompletion"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_insertCurrentCompletion"));
    method_exchangeImplementations(original, swizzle);

}

@end

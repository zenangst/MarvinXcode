//
//  DVTTextCompletionSession+ChangeMarks.m
//  MarvinPlugin
//
//  Created by Christoffer Winterkvist on 30/03/15.
//  Copyright (c) 2015 Octalord Information Inc. All rights reserved.
//

#import "DVTTextCompletionSession+ChangeMarks.h"
#import <objc/runtime.h>

@implementation DVTTextCompletionSession (ChangeMarks)

- (struct _NSRange)zen_replacementRangeForSuggestedRange:(struct _NSRange)arg1
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Add change mark" object:@{@"location" : @(arg1.location), @"length" : @(arg1.length)}];

    return [self zen_replacementRangeForSuggestedRange:arg1];
}

- (BOOL)zen_handleTextViewShouldChangeTextInRange:(struct _NSRange)arg1 replacementString:(id)arg2
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Add change mark" object:@{@"location" : @(arg1.location), @"length" : @(arg1.length)}];
    });

    return [self zen_handleTextViewShouldChangeTextInRange:arg1 replacementString:arg2];
}

+ (void)load
{
    Method original, swizzle;

    original = class_getInstanceMethod(self, NSSelectorFromString(@"handleTextViewShouldChangeTextInRange:replacementString:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_handleTextViewShouldChangeTextInRange:replacementString:"));

    method_exchangeImplementations(original, swizzle);
}

@end

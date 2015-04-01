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
    NSLog(@"%s -> range(%ld,%ld) -> %@", __FUNCTION__, arg1.location, arg1.length, arg2);

    return [self zen_handleTextViewShouldChangeTextInRange:arg1 replacementString:arg2];
}

- (BOOL)zen_insertCurrentCompletion
{
    NSLog(@"%s : %d", __FUNCTION__, __LINE__);

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

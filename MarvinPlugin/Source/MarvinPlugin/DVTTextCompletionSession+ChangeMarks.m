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
    long long selectedCompletionIndex = [self selectedCompletionIndex];
    NSArray *filteredCompletions = [self filteredCompletionsAlpha];
    
    if (filteredCompletions.count > selectedCompletionIndex) {
    
        IDEIndexCompletionItem *completion = filteredCompletions[selectedCompletionIndex];
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Add change mark" object:[completion completionText]];
        });
    
    }

    return [self zen_handleTextViewShouldChangeTextInRange:arg1 replacementString:arg2];
}

- (BOOL)zen_insertCurrentCompletion
{
    long long selectedCompletionIndex = [self selectedCompletionIndex];
    NSArray *filteredCompletions = [self filteredCompletionsAlpha];

    if (filteredCompletions.count > selectedCompletionIndex) {
    
        IDEIndexCompletionItem *completion = filteredCompletions[selectedCompletionIndex];
    
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Add change mark" object:[completion completionText]];
        });
    
    }

    return [self zen_insertCurrentCompletion];
}

- (BOOL)zen_handleInsertText:(id)arg1
{
    return [self zen_handleInsertText:arg1];
}

+ (void)load
{
    Method original, swizzle;

    original = class_getInstanceMethod(self, NSSelectorFromString(@"handleTextViewShouldChangeTextInRange:replacementString:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_handleTextViewShouldChangeTextInRange:replacementString:"));
    method_exchangeImplementations(original, swizzle);

    original = class_getInstanceMethod(self, NSSelectorFromString(@"handleInsertText:"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_handleInsertText:"));
    method_exchangeImplementations(original, swizzle);

    original = class_getInstanceMethod(self, NSSelectorFromString(@"insertCurrentCompletion"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_insertCurrentCompletion"));
    method_exchangeImplementations(original, swizzle);

}

@end

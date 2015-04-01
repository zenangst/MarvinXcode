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

- (BOOL)zen_insertCurrentCompletion
{
    long long selectedCompletionIndex = [self selectedCompletionIndex];
    NSArray *allCompletions = [self filteredCompletionsAlpha];
    IDEIndexCompletionItem *completion = allCompletions[selectedCompletionIndex];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Add change mark" object:[completion completionText]];
    });

    return [self zen_insertCurrentCompletion];
}

+ (void)load
{
    Method original, swizzle;

    original = class_getInstanceMethod(self, NSSelectorFromString(@"insertCurrentCompletion"));
    swizzle = class_getInstanceMethod(self, NSSelectorFromString(@"zen_insertCurrentCompletion"));
    method_exchangeImplementations(original, swizzle);

}

@end

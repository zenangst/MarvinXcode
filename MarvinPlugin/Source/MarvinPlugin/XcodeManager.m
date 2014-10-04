//
//  XcodeManager.m
//  MarvinPlugin
//
//  Created by Christoffer Winterkvist on 17/09/14.
//  Based on implementations by Benoît Bourdon
//  Copyright (c) 2014 zenangst. All rights reserved.
//

#import "XcodeManager.h"

@interface XcodeManager ()

@property (nonatomic, strong) NSTextView *textView;

@end

@implementation XcodeManager

#pragma mark - Getters

- (id)currentEditor
{
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];

    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        IDEEditorArea *editorArea = [workspaceController editorArea];
        IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }

    return nil;
}

- (NSTextView *)textView
{
    if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        IDESourceCodeEditor *editor = [self currentEditor];
        return editor.textView;
    }

    if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        IDESourceCodeComparisonEditor *editor = [self currentEditor];
        return editor.keyTextView;
    }

    return nil;
}

- (IDESourceCodeDocument *)currentSourceCodeDocument
{
    if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        IDESourceCodeEditor *editor = [self currentEditor];
        return editor.sourceCodeDocument;
    }

    if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        IDESourceCodeComparisonEditor *editor = [self currentEditor];
        if ([[editor primaryDocument] isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
            IDESourceCodeDocument *document = (IDESourceCodeDocument *)editor.primaryDocument;
            return document;
        }
    }

    return nil;
}

- (IDEEditorDocument *)currentDocument
{
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];

    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        IDEEditorArea *editorArea = [workspaceController editorArea];
        return editorArea.primaryEditorDocument;
    }

    return nil;
}

- (void)save
{
    if ([self currentDocument]) {
        [[self currentDocument] saveDocument:nil];
    }
}

- (NSString *)contents
{
    return [self.textView string];
}

- (NSUInteger)documentLength
{
    return [[self contents] length];
}

- (NSRange)selectedRange
{
    return self.textView.selectedRange;
}

- (NSRange)currentWordRange
{
    NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_"];
    NSCharacterSet *spaceSet = [NSCharacterSet characterSetWithCharactersInString:@"#-<>/(){}[],;:. \n`*\"'"];
    NSRange selectedRange = [self selectedRange];

    if (selectedRange.location >= self.contents.length) return selectedRange;

    char character;
    if ([self hasSelection]) {
        character = [[self contents] characterAtIndex:selectedRange.location+selectedRange.length];
    } else {
        character = [[self contents] characterAtIndex:selectedRange.location];
    }

    if (![validSet characterIsMember:character]) {
        selectedRange = (NSRange) { .location = selectedRange.location + selectedRange.length };
    }

    NSScanner *scanner = [NSScanner scannerWithString:[self contents]];
    [scanner setScanLocation:selectedRange.location];

    NSUInteger length = selectedRange.location;

    while (!scanner.isAtEnd) {
        if ([scanner scanCharactersFromSet:validSet intoString:nil]) {
            length = [scanner scanLocation];
            break;
        }
        [scanner setScanLocation:[scanner scanLocation] + 1];
    }

    NSUInteger location = ([[self contents] rangeOfCharacterFromSet:spaceSet options:NSBackwardsSearch range:NSMakeRange(0,length)].location +1);

    return NSMakeRange(location,length-location);
}

- (NSRange)previousWordRange
{
    NSRange selectedRange = [self selectedRange];

    NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_"];

    NSUInteger location = ([[self contents] rangeOfCharacterFromSet:validSet options:NSBackwardsSearch range:NSMakeRange(0,selectedRange.location)].location);

    return NSMakeRange(location,0);
}

- (NSRange)lineContentsRange
{
    NSRange selectedRange = [self selectedRange];

    NSCharacterSet *newlineSet = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
    NSUInteger startOfLine = ([[self contents] rangeOfCharacterFromSet:newlineSet options:NSBackwardsSearch range:NSMakeRange(0,selectedRange.location)].location);

    NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_!\"#€%&/()=?`<>@£$∞§|[]≈±´¡”¥¢‰¶\{}≠¿`~^*+-;"];

    if (startOfLine == NSNotFound) startOfLine = 0;

    NSUInteger location = ([[self contents] rangeOfCharacterFromSet:validSet options:NSCaseInsensitiveSearch range:NSMakeRange(startOfLine,[self documentLength]-startOfLine)].location);

    NSUInteger length = ([[self contents] rangeOfCharacterFromSet:newlineSet options:NSCaseInsensitiveSearch range:NSMakeRange(selectedRange.location+selectedRange.length,[self contents].length-(selectedRange.location+selectedRange.length))].location);

    if (length-location < [self documentLength]) {
        return NSMakeRange(location, length-location);
    } else {
        return NSMakeRange(selectedRange.location, 0);
    }
}

- (NSRange)lineRange
{
    NSRange selectedRange = [self selectedRange];
    NSCharacterSet *newlineSet = [NSCharacterSet characterSetWithCharactersInString:@"\n"];
    NSUInteger location = ([[self contents] rangeOfCharacterFromSet:newlineSet options:NSBackwardsSearch range:NSMakeRange(0,selectedRange.location)].location);

    NSUInteger length = ([[self contents] rangeOfCharacterFromSet:newlineSet options:NSCaseInsensitiveSearch range:NSMakeRange(selectedRange.location+selectedRange.length,[self contents].length-(selectedRange.location+selectedRange.length))].location);

    return NSMakeRange(location+1, length-location);
}

- (NSString *)contentsOfRange:(NSRange)range
{
    return [[self contents] substringWithRange:range];
}

- (NSRange)joinRange
{
    NSRange lineRange = [self lineRange];
    NSRange joinRange = (NSRange) { .location = lineRange.location + lineRange.length - 1 };

    NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_!\"#€%&/()=?`<>@£$∞§|[]≈±´¡”¥¢‰¶\{}≠¿`~^*+-;"];

    NSUInteger length = ([[self contents] rangeOfCharacterFromSet:validSet options:NSCaseInsensitiveSearch range:NSMakeRange(joinRange.location,[self contents].length-joinRange.location)].location);

    return NSMakeRange(joinRange.location, length - joinRange.location);
}

- (NSString *)selectedText
{
    NSString *text = [[self.textView string] substringWithRange:self.textView.selectedRange];
    return text;
}

- (BOOL)hasSelection
{
    return (self.textView.selectedRange.length) ? YES : NO;
}

- (BOOL)emptySelection
{
    return (self.textView.selectedRange.length) ? NO : YES;
}

#pragma mark - Setters

- (void)insertText:(NSString *)string
{
    [self.textView insertText:string];
}

- (void)setSelectedRange:(NSRange)range
{
    if (range.location == NSNotFound) return;

    if ((range.location + range.length) > self.contents.length) {
        range.length = self.contents.length - range.location;
    }
    self.textView.selectedRange = range;
}

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string
{
    if ((range.location + range.length) > self.contents.length) {
        range.length = self.contents.length - range.location;
    }

    IDESourceCodeDocument *document = [self currentSourceCodeDocument];
    DVTSourceTextStorage *textStorage = [document textStorage];

    [textStorage replaceCharactersInRange:range withString:string withUndoManager:[document undoManager]];
}

@end

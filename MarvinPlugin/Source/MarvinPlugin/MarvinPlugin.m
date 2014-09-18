//
// MarvinPlugin.m
// Marvin for Xcode
//
// Created by Christoffer Winterkvist on 17/10/14.
// Copyright (c) 2014 zenangst The MIT License.
//

#import "MarvinPlugin.h"
#import "XcodeManager.h"

@interface MarvinPlugin ()

@property (nonatomic, strong) XcodeManager *xcodeManager;

@end

#import <AppKit/AppKit.h>

@implementation MarvinPlugin

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static id shared = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{ shared = [[self alloc] init]; });
}

- (id)init {
    self = [super init];
    
    if (self) {
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(applicationDidFinishLaunching:)
         name:NSApplicationDidFinishLaunchingNotification
         object:nil];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    
    if (editMenuItem) {
        NSMenu *marvinMenu = [[NSMenu alloc] initWithTitle:@"Marvin"];
        
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Line Contents"
                                                              action:@selector(selectLineContents)
                                                       keyEquivalent:@"l"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSCommandKeyMask | NSShiftKeyMask;
            menuItem;
        })];
        
        [marvinMenu addItem:({
             NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Current Word"
                                                               action:@selector(selectWord)
                                                        keyEquivalent:@""];
             menuItem.target = self;
             menuItem.keyEquivalentModifierMask = NSControlKeyMask;
             menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Word Above"
                                                              action:@selector(selectWordAbove)
                                                       keyEquivalent:@"w"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Word Below"
                                                              action:@selector(selectWordBelow)
                                                       keyEquivalent:@"s"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Previous Word"
                                                              action:@selector(selectPreviousWord)
                                                       keyEquivalent:@"a"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Next Word"
                                                              action:@selector(selectNextWord)
                                                       keyEquivalent:@"d"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Delete Line"
                                                              action:@selector(deleteLine)
                                                       keyEquivalent:@"k"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask | NSShiftKeyMask;
            menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Duplicate Line"
                                                              action:@selector(duplicateLine)
                                                       keyEquivalent:@"d"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask | NSShiftKeyMask;
            menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Join Line"
                                                              action:@selector(joinLine)
                                                       keyEquivalent:@"j"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask | NSShiftKeyMask;
            menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Move To EOL and Insert Terminator"
                                                              action:@selector(moveToEOLAndInsertTerminator)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Move To EOL and Insert Terminator + LF"
                                                              action:@selector(moveToEOLAndInsertTerminatorPlusLF)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];
        
        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Move To EOL and Insert LF"
                                                              action:@selector(moveToEOLAndInsertLF)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];
        
        NSMenuItem *marvinMenuItem = [[NSMenuItem alloc] initWithTitle:@"Marvin"
                                                                action:nil
                                                         keyEquivalent:@""];
        marvinMenuItem.submenu = marvinMenu;
        
        [[editMenuItem submenu] addItem:marvinMenuItem];
    }
}

#pragma mark - Getters

- (XcodeManager *)xcodeManager
{
    if (_xcodeManager) return _xcodeManager;
    
    _xcodeManager = [[XcodeManager alloc] init];
    
    return _xcodeManager;
}

- (BOOL)validResponder
{
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    NSString *responderClass = NSStringFromClass(firstResponder.class);
    return ([responderClass isEqualToString:@"DVTSourceTextView"]);
}

#pragma mark - Setters

- (void)selectLineContents
{
    if (![self validResponder]) return;
    
    self.xcodeManager.selectedRange = self.xcodeManager.lineContentsRange;
}

- (void)selectWord {
    if (![self validResponder]) return;
    
    NSRange range = self.xcodeManager.currentWordRange;
    self.xcodeManager.selectedRange = range;
}

- (void)selectWordAbove
{
    if (![self validResponder]) return;
    
    NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_"];
    NSRange currentRange = [self.xcodeManager selectedRange];
    unichar characterAtCursorStart = [[self.xcodeManager contents] characterAtIndex:currentRange.location];
    unichar characterAtCursorEnd = [[self.xcodeManager contents] characterAtIndex:currentRange.location-1];
    
    if (![self.xcodeManager selectedRange].length && [validSet characterIsMember:characterAtCursorStart]) {
        [self selectWord];
    } else if (![self.xcodeManager selectedRange].length && [validSet characterIsMember:characterAtCursorEnd]) {
        [self selectPreviousWord];
    } else {
        CGEventRef event = CGEventCreateKeyboardEvent(NULL, 126, true);
        CGEventSetFlags(event, 0);
        CGEventPost(kCGHIDEventTap, event);
        CFRelease(event);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSRange currentRange = [self.xcodeManager selectedRange];
            unichar characterAtCursorStart = [[self.xcodeManager contents] characterAtIndex:currentRange.location];
            
            if ([validSet characterIsMember:characterAtCursorStart]) {
                [self selectWord];
            } else {
                [self selectPreviousWord];
            }
        });
    }
}

- (void)selectWordBelow
{
    if (![self validResponder]) return;
    
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 125, true);
    CGEventSetFlags(event, 0);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self selectWord];
    });
}

- (void)selectPreviousWord
{
    if (![self validResponder]) return;

    self.xcodeManager.selectedRange = self.xcodeManager.previousWordRange;
    self.xcodeManager.selectedRange = self.xcodeManager.currentWordRange;
}

- (void)selectNextWord
{
    if (![self validResponder]) return;
    
    [self selectWord];
}

- (void)deleteLine
{
    if (![self validResponder]) return;
    
    [self.xcodeManager replaceCharactersInRange:self.xcodeManager.lineContentsRange withString:@""];
}

- (void)duplicateLine
{
    if (![self validResponder]) return;
    
    NSRange range = [self.xcodeManager lineRange];
    NSString *string = [self.xcodeManager contentsOfRange:range];
    NSRange duplicateRange = NSMakeRange(range.location+range.length, 0);
    [self.xcodeManager replaceCharactersInRange:duplicateRange withString:string];
    NSRange selectRange = NSMakeRange(duplicateRange.location + duplicateRange.length + string.length - 1, 0);
    [self.xcodeManager setSelectedRange:selectRange];
}

- (void)joinLine
{
    if (![self validResponder]) return;
    
    [self.xcodeManager replaceCharactersInRange:self.xcodeManager.joinRange withString:@""];
}

- (void)moveToEOLAndInsertLF
{
    NSRange endOfLineRange = [self.xcodeManager lineContentsRange];
    NSRange lineRange = [self.xcodeManager lineRange];
    unsigned long endOfLine = (unsigned long)endOfLineRange.location+(unsigned long)endOfLineRange.length;
    
    NSString *spacing = [[self.xcodeManager contents] substringWithRange:NSMakeRange(lineRange.location, endOfLineRange.location - lineRange.location)];
    
    unichar lastCharacterInLine = [[self.xcodeManager contents] characterAtIndex:endOfLineRange.location+endOfLineRange.length-1];
    int ascii = lastCharacterInLine;
    
    NSMutableString *additionalSpacing = [NSMutableString string];
    if (ascii == 123) {
        for (int x = 0; x < 0; x++) {
            [additionalSpacing appendString:@" "];
        }
    }
    
    [self.xcodeManager replaceCharactersInRange:NSMakeRange(endOfLine,0) withString:[NSString stringWithFormat:@"\n%@%@", spacing, [additionalSpacing copy]]];
    [self.xcodeManager setSelectedRange:NSMakeRange(endOfLine+1+spacing.length+additionalSpacing.length, 0)];
}

- (void)moveToEOLAndInsertTerminator
{
    NSRange endOfLineRange = [self.xcodeManager lineContentsRange];
    unsigned long endOfLine = (unsigned long)endOfLineRange.location+(unsigned long)endOfLineRange.length;
    unichar characterAtEndOfLine = [[self.xcodeManager contents] characterAtIndex:endOfLine-1];
    
    if ((int)characterAtEndOfLine != 59) {
        [self.xcodeManager replaceCharactersInRange:NSMakeRange(endOfLine,0) withString:@";"];
    }
}

- (void)moveToEOLAndInsertTerminatorPlusLF
{
    [self moveToEOLAndInsertTerminator];
    [self moveToEOLAndInsertLF];
}

@end

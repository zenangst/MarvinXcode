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

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static id shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ shared = [[self alloc] init]; });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];

    if (!self) return nil;

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationDidFinishLaunching:)
     name:NSApplicationDidFinishLaunchingNotification
     object:nil];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];

    if (editMenuItem) {
        NSMenu *marvinMenu = [[NSMenu alloc] initWithTitle:@"Marvin"];

        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Delete Line"
                                                              action:@selector(deleteLineAction)
                                                       keyEquivalent:@"k"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask | NSShiftKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Duplicate Line"
                                                              action:@selector(duplicateLineAction)
                                                       keyEquivalent:@"d"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask | NSShiftKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Join Line"
                                                              action:@selector(joinLineAction)
                                                       keyEquivalent:@"j"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask | NSShiftKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Move To EOL and Insert LF"
                                                              action:@selector(moveToEOLAndInsertLFAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Proper Save"
                                                              action:@selector(save)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Current Word"
                                                              action:@selector(selectWordAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Line Contents"
                                                              action:@selector(selectLineContentsAction)
                                                       keyEquivalent:@"l"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSCommandKeyMask | NSShiftKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Next Word"
                                                              action:@selector(selectNextWordAction)
                                                       keyEquivalent:@"d"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Previous Word"
                                                              action:@selector(selectPreviousWordAction)
                                                       keyEquivalent:@"a"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Word Above"
                                                              action:@selector(selectWordAboveAction)
                                                       keyEquivalent:@"w"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Word Below"
                                                              action:@selector(selectWordBelowAction)
                                                       keyEquivalent:@"s"];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];

        NSString *versionString = [[NSBundle bundleForClass:[self class]] objectForInfoDictionaryKey:@"CFBundleVersion"];
        NSMenuItem *marvinMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Marvin (%@)", versionString]
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
    NSArray *validClasses = @[@"DVTSourceTextView", @"IDEPlaygroundTextView"];

    return ([validClasses containsObject:responderClass]);
}

#pragma mark - Actions

- (void)selectLineContentsAction
{
    if (![self validResponder]) return;

    self.xcodeManager.selectedRange = self.xcodeManager.lineContentsRange;
}

- (void)selectWordAction {
    if (![self validResponder]) return;

    NSRange range = self.xcodeManager.currentWordRange;
    self.xcodeManager.selectedRange = range;
}

- (void)selectWordAboveAction
{
    if (![self validResponder]) return;

    NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_"];
    NSRange currentRange = [self.xcodeManager selectedRange];
    unichar characterAtCursorStart = [[self.xcodeManager contents] characterAtIndex:currentRange.location];
    unichar characterAtCursorEnd = [[self.xcodeManager contents] characterAtIndex:currentRange.location-1];

    if (![self.xcodeManager selectedRange].length && [validSet characterIsMember:characterAtCursorStart]) {
        [self selectWordAction];
    } else if (![self.xcodeManager selectedRange].length && [validSet characterIsMember:characterAtCursorEnd]) {
        [self selectPreviousWordAction];
    } else {
        CGEventRef event = CGEventCreateKeyboardEvent(NULL, 126, true);
        CGEventSetFlags(event, 0);
        CGEventPost(kCGHIDEventTap, event);
        CFRelease(event);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            NSRange currentRange = [self.xcodeManager selectedRange];
            unichar characterAtCursorStart = [[self.xcodeManager contents] characterAtIndex:currentRange.location];

            if ([validSet characterIsMember:characterAtCursorStart]) {
                [self selectWordAction];
            } else {
                [self selectPreviousWordAction];
            }
        });
    }
}

- (void)selectWordBelowAction
{
    if (![self validResponder]) return;

    CGEventRef event = CGEventCreateKeyboardEvent(NULL, 125, true);
    CGEventSetFlags(event, 0);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self selectWordAction];
    });
}

- (void)selectPreviousWordAction
{
    if (![self validResponder]) return;

    self.xcodeManager.selectedRange = self.xcodeManager.previousWordRange;
    self.xcodeManager.selectedRange = self.xcodeManager.currentWordRange;
}

- (void)selectNextWordAction
{
    if (![self validResponder]) return;

    [self selectWordAction];
}

- (void)deleteLineAction
{
    if (![self validResponder]) return;

    [self.xcodeManager replaceCharactersInRange:self.xcodeManager.lineRange withString:@""];
}

- (void)duplicateLineAction
{
    if (![self validResponder]) return;

    NSRange range = [self.xcodeManager lineRange];
    NSString *string = [self.xcodeManager contentsOfRange:range];
    NSRange duplicateRange = NSMakeRange(range.location+range.length, 0);
    [self.xcodeManager replaceCharactersInRange:duplicateRange withString:string];
    NSRange selectRange = NSMakeRange(duplicateRange.location + duplicateRange.length + string.length - 1, 0);
    [self.xcodeManager setSelectedRange:selectRange];
}

- (void)joinLineAction
{
    if (![self validResponder]) return;

    [self.xcodeManager replaceCharactersInRange:self.xcodeManager.joinRange withString:@""];
}

- (void)moveToEOLAndInsertLFAction
{
    NSRange lineContentsRange = self.xcodeManager.lineContentsRange;
    NSRange lineRange = [self.xcodeManager lineRange];

    if (lineContentsRange.location == NSNotFound) {
        lineContentsRange.location = self.xcodeManager.contents.length;
        lineContentsRange.length = 0;

        [self.xcodeManager replaceCharactersInRange:lineContentsRange withString:@"\n"];
        self.xcodeManager.selectedRange = NSMakeRange(lineContentsRange.location+1, 0);

        return;
    }

    unsigned long endOfLine = (unsigned long)lineContentsRange.location+(unsigned long)lineContentsRange.length;

    NSString *spacing = [[self.xcodeManager contents] substringWithRange:NSMakeRange(lineRange.location, lineContentsRange.location - lineRange.location)];

    unichar lastCharacterInLine = [[self.xcodeManager contents] characterAtIndex:lineContentsRange.location+lineContentsRange.length-1];
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

- (void)save
{
    [self removeTrailingWhitespace:^{
        [self addNewlineAtEOF];
        [self.xcodeManager save];
    }];
}

#pragma mark - Private methods

- (void)addNewlineAtEOF
{
    if (![self validResponder]) return;

    NSString *documentText = self.xcodeManager.contents;
    int eof = [documentText characterAtIndex:[documentText length]-1];
    int lastAscii = [documentText characterAtIndex:[documentText length]-2];

    if (lastAscii != 100 && eof != 10) {
        NSRange selectedRange = self.xcodeManager.selectedRange;
        NSRange replaceRange = NSMakeRange(self.xcodeManager.contents.length, 0);
        NSString *replaceString = [NSString stringWithFormat:@"%c", 10];

        [self.xcodeManager replaceCharactersInRange:replaceRange withString:replaceString];
        self.xcodeManager.selectedRange = selectedRange;
    }
}

- (void)removeTrailingWhitespace:(void (^)())block;
{
    if (![self validResponder]) {
        block();
        return;
    }

    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([ \t]+)\r?\n" options:NSRegularExpressionCaseInsensitive error:&error];

    if (error) {
        NSLog(@"Couldn't create regex with given string and options");
    }

    NSString *string = self.xcodeManager.contents;
    NSRange currentRange = self.xcodeManager.selectedRange;
    NSMutableArray *ranges = [NSMutableArray array];

    [regex enumerateMatchesInString:string options:NSMatchingReportProgress range:NSMakeRange(0,[string length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {

        if (result) {
            if (!NSLocationInRange(currentRange.location, result.range))
                [ranges addObject:result];
        }

    }];

    if (![ranges count]) {
        block();
        return;
    }

    NSEnumerator *enumerator = [ranges reverseObjectEnumerator];

    dispatch_async(dispatch_get_main_queue(),^{
        for (NSTextCheckingResult *textResult in enumerator) {
            NSRange range = textResult.range;
            range.length -= 1;
            [self.xcodeManager replaceCharactersInRange:range withString:@""];
        }
        block();
    });
}

@end

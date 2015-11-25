//
// MarvinPlugin.m
// Marvin for Xcode
//
// Created by Christoffer Winterkvist on 17/10/14.
// Copyright (c) 2014 zenangst The MIT License.
//

#import "MarvinPlugin.h"
#import "XcodeManager.h"
#import "NSDocument+ZENProperSave.h"
#import "MarvinSettingsWindowController.h"

static MarvinPlugin *marvinPlugin;

@interface MarvinPlugin ()

@property (nonatomic, strong) XcodeManager *xcodeManager;
@property MarvinSettingsWindowController *settingsWindowController;


@end

@implementation MarvinPlugin

+ (void)pluginDidLoad:(NSBundle *)plugin {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        marvinPlugin = [[self alloc] init];
        if ( !(marvinPlugin.settingsWindowController = [[MarvinSettingsWindowController alloc] initWithBundle:plugin]) ) {
            NSLog( @"MarvinPlugin: nib not loaded exiting" );
            return;
        }
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:NSApplicationDidFinishLaunchingNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(properSave)
                                                 name:@"Save properly"
                                               object:nil];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    NSMenuItem *editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];

    if (editMenuItem) {
        NSMenu *marvinMenu = [[NSMenu alloc] initWithTitle:@"Marvin"];

        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Settings"
                                                              action:@selector(settingsMenuItemSelected:)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];

        [marvinMenu addItem:[NSMenuItem separatorItem]];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Delete Line"
                                                              action:@selector(deleteLineAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Duplicate Line"
                                                              action:@selector(duplicateLineAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Join Line"
                                                              action:@selector(joinLineAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
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
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Current Word"
                                                              action:@selector(selectWordAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Line Contents"
                                                              action:@selector(selectLineContentsAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Next Word"
                                                              action:@selector(selectNextWordAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Previous Word"
                                                              action:@selector(selectPreviousWordAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Word Above"
                                                              action:@selector(selectWordAboveAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Select Word Below"
                                                              action:@selector(selectWordBelowAction)
                                                       keyEquivalent:@""];
            menuItem.target = self;
            menuItem.keyEquivalentModifierMask = NSControlKeyMask;
            menuItem;
        })];

        [marvinMenu addItem:({
            NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:@"Sort Lines"
                                                              action:@selector(sortLines)
                                                       keyEquivalent:@""];
            menuItem.target = self;
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

- (XcodeManager *)xcodeManager {
    if (_xcodeManager) return _xcodeManager;

    _xcodeManager = [[XcodeManager alloc] init];

    return _xcodeManager;
}

- (BOOL)validResponder {
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    NSString *responderClass = NSStringFromClass(firstResponder.class);
    NSArray *validClasses = @[@"DVTSourceTextView", @"IDEPlaygroundTextView"];

    return ([validClasses containsObject:responderClass]);
}

#pragma mark - Actions

- (void)settingsMenuItemSelected:(id)sender {
    [marvinPlugin.settingsWindowController showWindow:self];
}

- (void)selectLineContentsAction {
    if ([self validResponder]) {
        self.xcodeManager.selectedRange = self.xcodeManager.lineContentsRange;
    }
}

- (void)selectWordAction {
    if ([self validResponder]) {
        self.xcodeManager.selectedRange = self.xcodeManager.currentWordRange;
    }
}

- (void)selectWordAboveAction {
    if ([self validResponder]) {
        NSCharacterSet *validSet = [NSCharacterSet characterSetWithCharactersInString:kMarvinValidSetWordString];
        NSRange currentRange = [self.xcodeManager selectedRange];
        unichar characterAtCursorStart = [[self.xcodeManager contents]
                                          characterAtIndex:currentRange.location];
        unichar characterAtCursorEnd = [[self.xcodeManager contents]
                                        characterAtIndex:currentRange.location-1];

        if (![self.xcodeManager selectedRange].length &&
            [validSet characterIsMember:characterAtCursorStart]) {
            [self selectWordAction];
        } else if (![self.xcodeManager selectedRange].length &&
                   [validSet characterIsMember:characterAtCursorEnd]) {
            [self selectPreviousWordAction];
        } else {
            [self performKeyboardEvent:126];

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.025 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

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
}

- (void)selectWordBelowAction {
    if ([self validResponder]) {
        [self performKeyboardEvent:125];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.025 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self selectWordAction];
        });
    }
}

- (void)selectPreviousWordAction {
    if ([self validResponder]) {
        self.xcodeManager.selectedRange = self.xcodeManager.previousWordRange;
        self.xcodeManager.selectedRange = self.xcodeManager.currentWordRange;
    }
}

- (void)selectNextWordAction {
    if ([self validResponder]) {
        [self selectWordAction];
    }
}

- (void)deleteLineAction {
    if ([self validResponder]) {
        [self.xcodeManager replaceCharactersInRange:self.xcodeManager.lineRange
                                         withString:@""];
    }
}

- (void)duplicateLineAction {
    if ([self validResponder]) {
        NSRange range = [self.xcodeManager lineRange];
        NSMutableString *string = [[self.xcodeManager contentsOfRange:range] mutableCopy];
        NSRange duplicateRange = NSMakeRange(range.location+range.length, 0);
        NSUInteger offset = 0;

        if (duplicateRange.location >= [[self.xcodeManager contents] length]) {
            [string insertString:@"\n" atIndex:0];
            offset += 1;
        }

        [self.xcodeManager replaceCharactersInRange:duplicateRange
                                         withString:[string copy]];
        NSRange selectRange = NSMakeRange(duplicateRange.location + duplicateRange.length + string.length - 1 + offset, 0);
        [self.xcodeManager setSelectedRange:selectRange];
    }
}

- (void)joinLineAction {
    if ([self validResponder]) {
        if ([self.xcodeManager lineContentsRange].length > 0) {
            [self.xcodeManager replaceCharactersInRange:self.xcodeManager.joinRange
                                             withString:@" "];
        } else {
            [self.xcodeManager replaceCharactersInRange:self.xcodeManager.joinRange
                                             withString:@""];
        }
    }
}

- (void)moveToEOLAndInsertLFAction {
    NSRange lineContentsRange = self.xcodeManager.lineContentsRange;
    NSRange lineRange = [self.xcodeManager lineRange];

    if (lineContentsRange.location == NSNotFound) {
        lineContentsRange.location = self.xcodeManager.contents.length;
        lineContentsRange.length = 0;

        [self.xcodeManager replaceCharactersInRange:lineContentsRange
                                         withString:@"\n"];
        self.xcodeManager.selectedRange = NSMakeRange(lineContentsRange.location+1, 0);

        return;
    }

    unsigned long endOfLine = (unsigned long)lineContentsRange.location+(unsigned long)lineContentsRange.length;

    NSString *spacing = [[self.xcodeManager contents] substringWithRange:NSMakeRange(lineRange.location, lineContentsRange.location - lineRange.location)];

    unichar lastCharacterInLine = [[self.xcodeManager contents] characterAtIndex:lineContentsRange.location+lineContentsRange.length-1];
    int ascii = lastCharacterInLine;

    NSMutableString *additionalSpacing = [NSMutableString new];
    if (ascii == 123) {
        for (int x = 0; x < 0; x++) {
            [additionalSpacing appendString:@" "];
        }
    }

    [self.xcodeManager replaceCharactersInRange:NSMakeRange(endOfLine,0)
                                     withString:[NSString stringWithFormat:@"\n%@%@", spacing, [additionalSpacing copy]]];
    [self.xcodeManager setSelectedRange:NSMakeRange(endOfLine+1+spacing.length+additionalSpacing.length, 0)];
}

- (void)properSave {
    [self removeTrailingWhitespace:^{
        [self addNewlineAtEOF];
        [self.xcodeManager save];
    }];
}

- (void)sortLines {
    NSRange lineRange = [self.xcodeManager lineRange];
    NSString *selectedContent = [self.xcodeManager contentsOfRange:lineRange];
    NSArray *lines = [selectedContent componentsSeparatedByString:@"\n"];
    NSArray *sortedLinesArray = [lines sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *sortedLinesString = [sortedLinesArray componentsJoinedByString:@"\n"];

    BOOL shouldSortDescending = ([[selectedContent substringToIndex:selectedContent.length-1] isEqualToString:[sortedLinesString substringFromIndex:1]]);
    if (shouldSortDescending) {
        NSSortDescriptor *sortOrder = [NSSortDescriptor sortDescriptorWithKey:@"self"
                                                                    ascending:NO];
        sortedLinesArray = [sortedLinesArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortOrder]];
        sortedLinesString = [sortedLinesArray componentsJoinedByString:@"\n"];
        [self.xcodeManager replaceCharactersInRange:lineRange
                                         withString:sortedLinesString];
    } else {
        if (lineRange.location > 0) { lineRange.location -= 1; }
        if ((lineRange.location + lineRange.length) >= [[self.xcodeManager contents] length]) {
            lineRange = NSMakeRange(0, [[self.xcodeManager contents] length]);
        }
        [self.xcodeManager replaceCharactersInRange:lineRange
                                         withString:sortedLinesString];
    }
}

#pragma mark - Private methods

- (void)addNewlineAtEOF {
    if ([self validResponder]) {

        NSString *documentText = self.xcodeManager.contents;

        if (self.xcodeManager.contents.length) {
            int eof = [documentText characterAtIndex:[documentText length]-1];
            int lastASCII = [documentText characterAtIndex:[documentText length]-2];

            if (lastASCII != 100 && eof != 10) {
                NSRange selectedRange = self.xcodeManager.selectedRange;
                NSRange replaceRange = NSMakeRange(self.xcodeManager.contents.length, 0);
                NSString *replaceString = [NSString stringWithFormat:@"%c", 10];

                [self.xcodeManager replaceCharactersInRange:replaceRange
                                                 withString:replaceString];
                self.xcodeManager.selectedRange = selectedRange;
            }
        }
    }
}

- (void)removeTrailingWhitespace:(void (^)())block {
    if (![self validResponder]) {
        block();
        return;
    }

    NSString *key = @"MarvinRemoveWhitespace";
    BOOL shouldRemoveWhitespace = [[NSUserDefaults standardUserDefaults] boolForKey:key];

    if (shouldRemoveWhitespace) {
        block();
        return;
    }


    if (!marvinPlugin.settingsWindowController.shouldRemoveWhitespace.state) {
        block();
        return;
    }

    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"([ \t]+)\r?\n"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];

    if (error) {
        NSLog(@"Couldn't create regex with given string and options");
    }

    NSString *string = self.xcodeManager.contents;
    NSRange currentRange = self.xcodeManager.selectedRange;
    NSMutableArray *ranges = [NSMutableArray new];

    [regex enumerateMatchesInString:string options:NSMatchingReportProgress
                              range:NSMakeRange(0,[string length])
                         usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {

                             if (result && !NSLocationInRange(currentRange.location, result.range)) {
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

- (void)performKeyboardEvent:(CGKeyCode)virtualKey {
    CGEventRef event = CGEventCreateKeyboardEvent(NULL, virtualKey, true);
    CGEventSetFlags(event, 0);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}

@end

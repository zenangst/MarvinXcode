//
//  XcodeManager.h
//  MarvinPlugin
//
//  Created by Christoffer Winterkvist on 17/09/14.
//  Copyright (c) 2014 zenangst. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *const kMarvinValidSetWordString = @"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_";
static NSString *const kMarvinSpaceSet = @"#-<>/(){}[],;:. \n`*\"'	";
static NSString *const kMarvinValidLineRange = @"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_!\"#€%&/()=?`<>@£$∞§|[]≈±´¡”¥¢‰¶\{}≠¿`~^*+-;";

@interface XcodeManager : NSObject

@property (nonatomic) NSRange selectedRange;

- (id)currentEditor;
- (NSTextView *)textView;
- (IDESourceCodeDocument *)currentSourceCodeDocument;
- (void)save;
- (NSString *)contents;
- (NSUInteger)documentLength;
- (NSRange)currentWordRange;
- (NSRange)previousWordRange;
- (NSRange)lineContentsRange;
- (NSRange)lineRange;
- (NSString *)contentsOfRange:(NSRange)range;
- (NSRange)joinRange;
- (NSString *)selectedText;
- (NSLayoutManager *)layoutManager;
- (void)needsDisplay;

- (void)insertText:(NSString *)string;
- (void)replaceCharactersInRange:(NSRange)range
                      withString:(NSString *)string;

@end

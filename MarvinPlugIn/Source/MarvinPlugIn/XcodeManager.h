//
//  XcodeManager.h
//  MarvinPlugIn
//
//  Created by Christoffer Winterkvist on 17/09/14.
//  Copyright (c) 2014 Octalord Information Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XcodeManager : NSObject

@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic) NSRange selectedRange;

- (id)currentEditor;
- (IDESourceCodeDocument *)currentSourceCodeDocument;

- (NSString *)contents;
- (NSUInteger)documentLength;
- (NSRange)currentWordRange;
- (NSRange)previousWordRange;
- (NSRange)lineContentsRange;
- (NSRange)lineRange;
- (NSString *)contentsOfRange:(NSRange)range;
- (NSRange)joinRange;
- (NSString *)selectedText;

- (void)insertText:(NSString *)string;
- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)string;

@end

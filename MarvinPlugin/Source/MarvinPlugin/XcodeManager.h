#import <Foundation/Foundation.h>

@interface XcodeManager : NSObject

@property (nonatomic) NSRange selectedRange;

- (id)currentEditor;
- (IDESourceCodeDocument *)currentSourceCodeDocument;
- (IDEEditorDocument *)currentDocument;
- (void)save;

@end

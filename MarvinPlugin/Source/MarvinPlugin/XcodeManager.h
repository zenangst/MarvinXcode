#import <Foundation/Foundation.h>

@interface XcodeManager : NSObject

- (id)currentEditor;
- (IDESourceCodeDocument *)currentSourceCodeDocument;
- (IDEEditorDocument *)currentDocument;
- (void)save;

@end

#import <Foundation/Foundation.h>

@interface LegacyXcodeManager : NSObject

- (id)currentEditor;
- (IDESourceCodeDocument *)currentSourceCodeDocument;
- (IDEEditorDocument *)currentDocument;
- (void)save;

@end

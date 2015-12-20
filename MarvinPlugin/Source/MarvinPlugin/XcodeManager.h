#import <Foundation/Foundation.h>

static NSString *const kMarvinValidSetWordString = @"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_";
static NSString *const kMarvinSpaceSet = @"#-<>/(){}[],;:. \n`*\"'	";
static NSString *const kMarvinValidLineRange = @"0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_!\"#€%&/()=?`<>@£$∞§|[]≈±´¡”¥¢‰¶\{}≠¿`~^*+-;.";

@interface XcodeManager : NSObject

@property (nonatomic) NSRange selectedRange;

- (id)currentEditor;
- (IDESourceCodeDocument *)currentSourceCodeDocument;
- (IDEEditorDocument *)currentDocument;
- (void)save;

@end

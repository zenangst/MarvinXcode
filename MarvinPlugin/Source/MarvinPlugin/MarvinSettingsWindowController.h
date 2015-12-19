#import <Cocoa/Cocoa.h>

@interface MarvinSettingsWindowController : NSWindowController

@property (weak) IBOutlet NSButton *shouldRemoveWhitespace;

- (instancetype)initWithBundle:(NSBundle *)bundle;

@end

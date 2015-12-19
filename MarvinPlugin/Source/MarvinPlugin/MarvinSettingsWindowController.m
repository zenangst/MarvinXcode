#import "MarvinSettingsWindowController.h"

@interface MarvinSettingsWindowController () {}

@end

@implementation MarvinSettingsWindowController

- (id)initWithBundle:(NSBundle *)bundle
{
    NSString *nibPath = [bundle pathForResource:@"Settings" ofType:@"nib"];
    self = [super initWithWindowNibPath:nibPath owner:self];
    return self;
}

@end

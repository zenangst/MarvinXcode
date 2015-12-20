#import "LegacyXcodeManager.h"

@implementation LegacyXcodeManager

#pragma mark - Getters

- (id)currentEditor {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];

    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        IDEEditorArea *editorArea = [workspaceController editorArea];
        IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
        return [editorContext editor];
    }

    return nil;
}

- (IDESourceCodeDocument *)currentSourceCodeDocument {
    if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
        IDESourceCodeEditor *editor = [self currentEditor];
        return editor.sourceCodeDocument;
    }

    if ([[self currentEditor] isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
        IDESourceCodeComparisonEditor *editor = [self currentEditor];
        if ([[editor primaryDocument] isKindOfClass:NSClassFromString(@"IDESourceCodeDocument")]) {
            IDESourceCodeDocument *document = (IDESourceCodeDocument *)editor.primaryDocument;
            return document;
        }
    }

    return nil;
}

- (IDEEditorDocument *)currentDocument {
    NSWindowController *currentWindowController = [[NSApp keyWindow] windowController];

    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)currentWindowController;
        IDEEditorArea *editorArea = [workspaceController editorArea];
        return editorArea.primaryEditorDocument;
    }

    return nil;
}

- (void)save {
    if ([[self currentSourceCodeDocument] isEqualTo:[self currentDocument]]) {
        [[self currentDocument] saveDocument:nil];
    } else {
        [[self currentSourceCodeDocument] saveDocument:nil];
    }
}

@end

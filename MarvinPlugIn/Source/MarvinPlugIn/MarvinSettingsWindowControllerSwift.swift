import Foundation

class MarvinSettingsWindowController: NSWindowController {

  @IBOutlet weak var shouldRemoveWhitespace: NSButton?

  convenience init(bundle: NSBundle) {
    self.init(window: nil)

    bundle.loadNibNamed("Settings", owner: self, topLevelObjects: nil)
  }
}

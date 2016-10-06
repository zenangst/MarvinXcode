import Foundation

class MarvinSettingsWindowController: NSWindowController {

  var bundle: Bundle?
  @IBOutlet weak var shouldRemoveWhitespace: NSButton?

  convenience init(bundle: Bundle) {
    self.init(window: nil)
    self.bundle = bundle
  }

  func openWindow() {
    guard let bundle = bundle else { return }
    bundle.loadNibNamed("Settings", owner: self, topLevelObjects: nil)
    showWindow(self)
  }
}

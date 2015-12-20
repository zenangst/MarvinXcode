import Foundation

class MarvinSettingsWindowController: NSWindowController {

  var bundle: NSBundle?
  @IBOutlet weak var shouldRemoveWhitespace: NSButton?

  convenience init(bundle: NSBundle) {
    self.init(window: nil)
    self.bundle = bundle
  }

  func openWindow() {
    guard let bundle = bundle else { return }
    bundle.loadNibNamed("Settings", owner: self, topLevelObjects: nil)
    showWindow(self)
  }
}

import Cocoa

var marvinPlugin: MarvinPlugin? = nil

extension NSObject {

  class func pluginDidLoad(_ bundle: Bundle) {
    guard let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String
      , marvinPlugin == nil && appName == "Xcode" else {
        return
    }

    marvinPlugin = MarvinPlugin()
    marvinPlugin?.settingsController = MarvinSettingsWindowController(bundle: bundle)
    SaveSwizzler.swizzle()
  }
}

class MarvinPlugin: NSObject {

  lazy var xcode = XcodeManager()
  var settingsController: MarvinSettingsWindowController?

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override init() {
    super.init()

    NotificationCenter.default.addObserver(self, selector: #selector(NSApplicationDelegate.applicationDidFinishLaunching(_:)), name: NSNotification.Name.NSApplicationDidFinishLaunching, object: nil)

    NotificationCenter.default.addObserver(self, selector: #selector(MarvinPlugin.properSave), name: NSNotification.Name(rawValue: "Save properly"), object: nil)
  }

  func applicationDidFinishLaunching(_ notification: Notification) {
    guard let mainMenu = NSApp.mainMenu else { return }
    let editMenuItem = mainMenu.item(withTitle: "Edit")

    if let editMenuItem = editMenuItem, let submenu = editMenuItem.submenu {
      let marvinMenu = NSMenu.init(title: "Marvin")
      var items = [NSMenuItem]()

      items.append(NSMenuItem.init(title: "Settings", action: #selector(MarvinPlugin.settingsMenuItemSelected), keyEquivalent: ""))
      items.append(NSMenuItem.separator())
      items.append(NSMenuItem.init(title: "Delete Line", action: #selector(MarvinPlugin.deleteLineAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Duplicate Line", action: #selector(MarvinPlugin.duplicateLineAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Join Line", action: #selector(MarvinPlugin.joinLineAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Move To EOL and Insert LF", action: #selector(MarvinPlugin.moveToEOLAndInsertLFAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Current Word", action: #selector(MarvinPlugin.selectWordAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Line Contents", action: #selector(MarvinPlugin.selectLineContentsAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Next Word", action: #selector(MarvinPlugin.selectNextWordAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Previous Word", action: #selector(MarvinPlugin.selectPreviousWordAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Word Above", action: #selector(MarvinPlugin.selectWordAboveAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Word Below", action: #selector(MarvinPlugin.selectWordBelowAction), keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Sort Lines", action: #selector(MarvinPlugin.sortLines), keyEquivalent: ""))

      items.forEach { $0.target = self; marvinMenu.addItem($0) }

      if let infoDictionary = Bundle(for: type(of: self)).infoDictionary,
        let version = infoDictionary["CFBundleVersion"] {
          let marvinMenuItem = NSMenuItem.init(title: "Marvin \(version)", action: nil, keyEquivalent: "")
          marvinMenuItem.submenu = marvinMenu

          submenu.addItem(NSMenuItem.separator())
          submenu.addItem(marvinMenuItem)
      }
    }
  }

  func validResponder() -> Bool {
    guard let window = NSApp.keyWindow else { return false }
    let firstResponder = window.firstResponder
    let responderClass = NSStringFromClass(type(of: firstResponder))

    return ["NSKVONotifying_DVTSourceTextView", "NSKVONotifying_IDEPlaygroundTextView"].contains(responderClass) && xcode.documentLength() > 1
  }

  func settingsMenuItemSelected() {
    marvinPlugin?.settingsController?.openWindow()
  }

  func selectLineContentsAction() {
    guard validResponder() else { return }
    xcode.selectedRange = xcode.lineContentsRange()
  }

  func selectWordAction() {
    guard validResponder() else { return }
    xcode.selectedRange = xcode.currentWordRange()
  }

  func selectWordAboveAction() {
    guard validResponder() && xcode.selectedRange.location > 0 else { return }

    let validSet = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_")
    var currentRange = xcode.selectedRange

    if currentRange.location >= xcode.contents().characters.count {
      currentRange.location -= 1
    }

    let characterAtCursorStart: Character = xcode.contents()[xcode.contents().characters.index(xcode.contents().startIndex, offsetBy: currentRange.location)]
    let characterAtCursorEnd: Character = xcode.contents()[xcode.contents().characters.index(xcode.contents().startIndex, offsetBy: currentRange.location-1)]

    if xcode.selectedRange.length == 0 && isChar(characterAtCursorStart, inSet: validSet) {
      selectWordAction()
    } else if xcode.selectedRange.length == 0 && isChar(characterAtCursorEnd, inSet: validSet) {
      selectPreviousWordAction()
    } else {
      perform(keyboardEvent: 126)

      let delayTime = DispatchTime.now() + 0.025
      DispatchQueue.main.asyncAfter(deadline: delayTime) { [unowned self] in
        let currentRange = self.xcode.selectedRange

        let characterAtCursorStart: Character = self.xcode.contents()[self.xcode.contents().characters.index(self.xcode.contents().startIndex, offsetBy: currentRange.location)]

        if self.isChar(characterAtCursorStart, inSet: validSet) {
          self.selectWordAction()
        } else {
          self.selectPreviousWordAction()
        }
      }
    }
  }

  func selectWordBelowAction() {
    guard validResponder() else { return }

    perform(keyboardEvent: 125)

    let delayTime = DispatchTime.now() + 0.025
    DispatchQueue.main.asyncAfter(deadline: delayTime) { [unowned self] in
      self.selectWordAction()
    }
  }

  func selectPreviousWordAction() {
    guard validResponder() else { return }
    xcode.selectedRange = xcode.previousWordRange()
    xcode.selectedRange = xcode.currentWordRange()
  }

  func selectNextWordAction() {
    guard validResponder() else { return }
    selectWordAction()
  }

  func deleteLineAction() {
    guard validResponder() else { return }
    xcode.replaceCharactersInRange(xcode.lineRange(), withString: "")
  }

  func duplicateLineAction() {
    guard validResponder() else { return }

    let range = xcode.lineRange()
    var string = self.xcode.contentsOfRange(range)
    let duplicateRange = NSMakeRange(range.location+range.length, 0)
    var offset = 0

    if duplicateRange.location >= xcode.contents().characters.count &&
      xcode.selectedRange.location == xcode.contents().characters.count {
        string = "\n\(string)"
        offset = 1
    }

    xcode.replaceCharactersInRange(duplicateRange, withString: string)
    xcode.selectedRange = NSMakeRange(duplicateRange.location + duplicateRange.length + string.characters.count - 1 + offset, 0)
  }

  func joinLineAction() {
    guard validResponder() else { return }

    let range = xcode.joinRange()

    guard range.location != NSNotFound &&
      range.location + range.length < xcode.contents().characters.count
      else { return }

    xcode.replaceCharactersInRange(range,
      withString: xcode.lineContentsRange().length > 0 ? " " : "")
  }

  func moveToEOLAndInsertLFAction() {
    guard validResponder() else { return }

    let lineRange = xcode.lineRange()
    let endOfLine = lineRange.location + lineRange.length - 1
    let currentLine = (xcode.contents() as NSString).substring(with: lineRange)
    let trimmedString = currentLine.trimmingCharacters(in: CharacterSet.whitespaces)
    let spacing = currentLine.replacingOccurrences(of: trimmedString, with: "")

    xcode.replaceCharactersInRange(NSMakeRange(endOfLine, 0), withString: "\n\(spacing)")
    xcode.selectedRange = NSMakeRange(endOfLine + spacing.characters.count + 1, 0)
  }

  func sortLines() {
    guard validResponder() else { return }

    var lineRange = xcode.lineRange()
    lineRange.length -= 1
    let selectedContent = xcode.contentsOfRange(lineRange)
    let lines = selectedContent.components(separatedBy: "\n")

    var sortedLines = lines.sorted { $0 > $1 }
    var sortedLinesString = (sortedLines as NSArray).componentsJoined(by: "\n")

    let shouldSortDescending = (selectedContent as NSString).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == (sortedLinesString as NSString).substring(from: 1).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

    if shouldSortDescending {
      sortedLines = lines.sorted { $0 < $1 }
      sortedLinesString = (sortedLines as NSArray).componentsJoined(by: "\n")
    }

    xcode.replaceCharactersInRange(lineRange, withString: sortedLinesString)
    xcode.selectedRange = lineRange
  }

  func properSave() {
    removeTrailingWhitespace { [unowned self] in
      self.addNewlineAtEOF()
      self.xcode.save()
    }
  }

  // MARK: - Private methods

  fileprivate func addNewlineAtEOF() {
    guard validResponder() else { return }

    if let eof = xcode.contents().characters.last
      , eof != "\n" {
        let selectedRange = xcode.selectedRange
        let replaceRange = NSMakeRange(xcode.contents().characters.count, 0)
        let replaceString = "\n"

        xcode.replaceCharactersInRange(replaceRange, withString: replaceString)
        xcode.selectedRange = selectedRange
    }
  }

  fileprivate func removeTrailingWhitespace(_ closure: @escaping () -> Void) {
    guard validResponder() else { closure(); return }

    let key = "MarvinRemoveWhitespace"
    let shouldRemoveWhitespace = UserDefaults.standard.bool(forKey: key)

    if !shouldRemoveWhitespace {
      closure()
      return
    }

    let regex = try! NSRegularExpression(pattern: "([ \t]+)\r?\n", options: .caseInsensitive)
    let currentRange = xcode.selectedRange
    let string = xcode.contents()

    var results = [NSTextCheckingResult]()

    regex.enumerateMatches(in: string, options: .reportProgress, range: NSMakeRange(0, string.characters.count)) { (result, flags, stop) -> Void in
      if let result = result , !NSLocationInRange(currentRange.location, result.range) {
        results.append(result)
      }
    }

    if results.isEmpty { closure(); return }

    let enumerator = results.reversed()

    DispatchQueue.main.async { [unowned self] in
      enumerator.forEach { textResult in
        var range = textResult.range
        range.length -= 1
        self.xcode.replaceCharactersInRange(range, withString: "")
      }
      closure()
    }
  }

  fileprivate func perform(keyboardEvent virtualKey: CGKeyCode) {
    let event = CGEvent(keyboardEventSource: nil, virtualKey: virtualKey, keyDown: true)
    event?.flags = CGEventFlags(rawValue: 0)
    event?.post(tap: .cghidEventTap)
  }

  fileprivate func isChar(_ char: Character, inSet set: CharacterSet) -> Bool {
    var found = false
    for ch in String(char).utf16 {
      if set.contains(UnicodeScalar(ch)!) { found = true; break }
    }
    return found
  }
}

import Cocoa

var marvinPlugin: MarvinPlugin? = nil

extension NSObject {

  class func pluginDidLoad(bundle: NSBundle) {
    guard let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String
      where marvinPlugin == nil && appName == "Xcode" else {
        return
    }

    marvinPlugin = MarvinPlugin()
    marvinPlugin?.settingsController = MarvinSettingsWindowController(bundle: bundle)
  }
}

class MarvinPlugin: NSObject {

  lazy var xcode = XcodeManager()
  var settingsController: MarvinSettingsWindowController?

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override init() {
    super.init()

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidFinishLaunching:", name: NSApplicationDidFinishLaunchingNotification, object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "properSave", name: "Save properly", object: nil)
  }

  func applicationDidFinishLaunching(notification: NSNotification) {
    guard let mainMenu = NSApp.mainMenu else { return }
    let editMenuItem = mainMenu.itemWithTitle("Edit")

    if let editMenuItem = editMenuItem, submenu = editMenuItem.submenu {
      let marvinMenu = NSMenu.init(title: "Marvin")
      var items = [NSMenuItem]()

      items.append(NSMenuItem.init(title: "Settings", action: "settingsMenuItemSelected", keyEquivalent: ""))
      items.append(NSMenuItem.separatorItem())
      items.append(NSMenuItem.init(title: "Delete Line", action: "deleteLineAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Duplicate Line", action: "duplicateLineAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Join Line", action: "joinLineAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Move To EOL and Insert LF", action: "moveToEOLAndInsertLFAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Current Word", action: "selectWordAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Line Contents", action: "selectLineContentsAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Next Word", action: "selectNextWordAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Previous Word", action: "selectPreviousWordAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Word Above", action: "selectWordAboveAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Select Word Below", action: "selectWordBelowAction", keyEquivalent: ""))
      items.append(NSMenuItem.init(title: "Sort Lines", action: "sortLines", keyEquivalent: ""))

      items.forEach { $0.target = self; marvinMenu.addItem($0) }

      if let infoDictionary = NSBundle(forClass: self.dynamicType).infoDictionary,
        version = infoDictionary["CFBundleVersion"] {
          let marvinMenuItem = NSMenuItem.init(title: "Marvin \(version)", action: nil, keyEquivalent: "")
          marvinMenuItem.submenu = marvinMenu

          submenu.addItem(NSMenuItem.separatorItem())
          submenu.addItem(marvinMenuItem)
      }
    }
  }

  func validResponder() -> Bool {
    guard let window = NSApp.keyWindow else { return false }
    let firstResponder = window.firstResponder
    let responderClass = NSStringFromClass(firstResponder.dynamicType)

    return ["NSKVONotifying_DVTSourceTextView", "NSKVONotifying_IDEPlaygroundTextView"].contains(responderClass)
  }

  func settingsMenuItemSelected() {
    marvinPlugin?.settingsController?.showWindow(self)
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
    guard validResponder() else { return }

    let validSet = NSCharacterSet(charactersInString: "0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_")
    let currentRange = xcode.selectedRange
    let characterAtCursorStart: Character = xcode.contents()[xcode.contents().startIndex.advancedBy(currentRange.location)]
    let characterAtCursorEnd: Character = xcode.contents()[xcode.contents().startIndex.advancedBy(currentRange.location-1)]

    if xcode.selectedRange.length == 0 && isChar(characterAtCursorStart, inSet: validSet) {
      selectWordAction()
    } else if xcode.selectedRange.length == 0 && isChar(characterAtCursorEnd, inSet: validSet) {
      selectPreviousWordAction()
    } else {
      perform(keyboardEvent: 126)

      let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.025 * Double(NSEC_PER_SEC)))
      dispatch_after(delayTime, dispatch_get_main_queue()) { [unowned self] in
        let currentRange = self.xcode.selectedRange
        let characterAtCursorStart: Character = self.xcode.contents()[self.xcode.contents().startIndex.advancedBy(currentRange.location)]

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

    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.025 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) { [unowned self] in
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

    if xcode.lineContentsRange().length > 0 {
      xcode.replaceCharactersInRange(xcode.joinRange(), withString: " ")
    } else {
      xcode.replaceCharactersInRange(xcode.joinRange(), withString: "")
    }
  }

  func moveToEOLAndInsertLFAction() {
    guard validResponder() else { return }

    let lineRange = xcode.lineRange()
    let endOfLine = lineRange.location + lineRange.length - 1
    let currentLine = (xcode.contents() as NSString).substringWithRange(lineRange)
    let trimmedString = currentLine.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    let spacing = currentLine.stringByReplacingOccurrencesOfString(trimmedString, withString: "")

    xcode.replaceCharactersInRange(NSMakeRange(endOfLine, 0), withString: "\n\(spacing)")
    xcode.selectedRange = NSMakeRange(endOfLine + spacing.characters.count + 1, 0)
  }

  func sortLines() {
    guard validResponder() else { return }

    let lineRange = xcode.lineRange()
    let selectedContent = xcode.contentsOfRange(lineRange)
    let lines = selectedContent.componentsSeparatedByString("\n")
    var sortedLines = lines.sort { $0 > $1 }
    var sortedLinesString = (sortedLines as NSArray).componentsJoinedByString("\n")

    let shouldSortDescending = (selectedContent as NSString).substringToIndex(selectedContent.characters.count - 1) == (sortedLinesString as NSString).substringFromIndex(1)

    if shouldSortDescending {
      sortedLines = lines.sort { $0 < $1 }
      sortedLinesString = (sortedLines as NSArray).componentsJoinedByString("\n")
      xcode.replaceCharactersInRange(lineRange, withString: sortedLinesString)
    } else {
      xcode.replaceCharactersInRange(lineRange, withString: sortedLinesString)
    }
  }

  func properSave() {
    removeTrailingWhitespace { [unowned self] in
      self.addNewlineAtEOF()
      self.xcode.save()
    }
  }

  // MARK: - Private methods

  private func addNewlineAtEOF() {
    guard validResponder() else { return }

    if let eof = xcode.contents().characters.last
      where eof != "\n" {
        let selectedRange = xcode.selectedRange
        let replaceRange = NSMakeRange(xcode.contents().characters.count, 0)
        let replaceString = "\n"

        xcode.replaceCharactersInRange(replaceRange, withString: replaceString)
        xcode.selectedRange = selectedRange
    }
  }

  private func removeTrailingWhitespace(closure: () -> Void) {
    guard validResponder() else { closure(); return }

    let key = "MarvinRemoveWhitespace"
    let shouldRemoveWhitespace = NSUserDefaults.standardUserDefaults().boolForKey(key)

    if !shouldRemoveWhitespace {
      closure()
      return
    }

    let regex = try! NSRegularExpression(pattern: "([ \t]+)\r?\n", options: .CaseInsensitive)
    let currentRange = xcode.selectedRange
    let string = xcode.contents()

    var results = [NSTextCheckingResult]()

    regex.enumerateMatchesInString(string, options: .ReportProgress, range: NSMakeRange(0, string.characters.count)) { (result, flags, stop) -> Void in
      if let result = result where !NSLocationInRange(currentRange.location, result.range) {
        results.append(result)
      }
    }

    if results.isEmpty { closure(); return }

    let enumerator = results.reverse()

    dispatch_async(dispatch_get_main_queue()) { [unowned self] in
      enumerator.forEach { textResult in
        var range = textResult.range
        range.length -= 1
        self.xcode.replaceCharactersInRange(range, withString: "")
      }
      closure()
    }
  }

  private func perform(keyboardEvent virtualKey: CGKeyCode) {
    let event = CGEventCreateKeyboardEvent(nil, virtualKey, true)
    CGEventSetFlags(event, CGEventFlags(rawValue: 0)!)
    CGEventPost(.CGHIDEventTap, event)
  }

  private func isChar(char: Character, inSet set: NSCharacterSet) -> Bool {
    var found = false
    for ch in String(char).utf16 {
      if set.characterIsMember(ch) { found = true; break }
    }
    return found
  }
}

import Foundation

class XcodeManagerSwift: NSObject {

  var textView: NSTextView? {
    get {
      if let currentEditor = XcodeManager().currentEditor(),
        className = NSClassFromString("IDESourceCodeEditor")
        where currentEditor.isKindOfClass(className) {
          return currentEditor.textView
      }

      if let currentEditor = XcodeManager().currentEditor(),
        className = NSClassFromString("IDESourceCodeComparisonEditor")
        where currentEditor.isKindOfClass(className) {
          return currentEditor.keyTextView
      }

      return nil
    }
  }

  var selectedRange: NSRange {
    set(value) {
      guard value.location != NSNotFound else { return }

      if value.location + value.length > self.contents().characters.count {
        var value = value
        value.length = self.contents().characters.count - value.location
      }

      textView?.selectedRange = value
    }
    get {
      return textView?.selectedRange ?? NSRange(location: 0, length: 0)
    }
  }

  func save() {
    XcodeManager().save()
  }
  func needsDisplay() {
    textView?.needsDisplay = true
  }

  func contents() -> String {
    return textView?.string ?? ""
  }

  func documentLength() -> Int {
    return (textView?.string?.characters.count ?? 0) - 1
  }

  func currentWordRange() -> NSRange {
    let validSet = NSCharacterSet(charactersInString: "0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_")
    let spaceSet = NSCharacterSet(charactersInString: "#-<>/(){}[],;:. \n`*\"' ")
    var selectedRange = self.selectedRange

    guard selectedRange.location + selectedRange.length < contents().characters.count else { return selectedRange }

    var character: Character
    if self.hasSelection() {
      character = self.contents()[self.contents().startIndex.advancedBy(selectedRange.location+selectedRange.length)]
    } else {
      character = self.contents()[self.contents().startIndex.advancedBy(selectedRange.location)]
    }

    if !isChar(character, inSet:validSet) {
      selectedRange.location = selectedRange.location + selectedRange.length
    }

    let scanner = NSScanner(string: self.contents())
    scanner.scanLocation = selectedRange.location

    var length = selectedRange.location

    while !scanner.atEnd {
      if scanner.scanCharactersFromSet(validSet, intoString: nil) {
        length = scanner.scanLocation
        break
      }

      scanner.scanLocation = scanner.scanLocation + 1
    }

    let whitespaceRange = (self.contents() as NSString).rangeOfCharacterFromSet(spaceSet,
      options: .BackwardsSearch,
      range: NSRange(location: 0, length: length))

    let location = whitespaceRange.location != NSNotFound ? whitespaceRange.location + 1 : 0

    if length - location > self.documentLength() {
      length = 0
    }

    var range = NSRange(location: 0, length: 0)
    if location >= 0 {
      range = NSRange(location: location, length: length - location)
      return range
    } else if location == 0 && range.location != selectedRange.location && range.length != selectedRange.length {
      scanner.scanLocation = 0
      while !scanner.atEnd {
        if scanner.scanCharactersFromSet(validSet, intoString: nil) {
          length = scanner.scanLocation
          break
        }
        scanner.scanLocation = scanner.scanLocation + 1

        range.location = location
        range.length = length - location
      }

      if range.location == NSNotFound { range.location = 0 }

      if range.length > self.contents().characters.count {
        range.length = self.contents().characters.count
      }

      return range
    }

    return selectedRange
  }

  func previousWordRange() -> NSRange {
    let selectedRange = self.selectedRange
    let validSet = NSCharacterSet(charactersInString: "0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_")
    var location = (self.contents() as NSString).rangeOfCharacterFromSet(validSet, options: .BackwardsSearch, range: NSMakeRange(0,selectedRange.location)).location

    if location == NSNotFound {
      location = 0
    }

    return NSRange(location: location, length: 0)
  }

  func lineContentsRange() -> NSRange {
    let lineRange = self.lineRange()
    let currentLine = (self.contents() as NSString).substringWithRange(lineRange)
    let trimmedString = currentLine.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    let spacing = currentLine.stringByReplacingOccurrencesOfString(trimmedString, withString: "")

    return NSRange(location: lineRange.location + spacing.characters.count, length: lineRange.length - spacing.characters.count - 1)
  }

  func lineRange() -> NSRange {
    let selectedRange = self.selectedRange
    let newLineSet = NSCharacterSet(charactersInString: "\n")

    var location = (self.contents() as NSString).rangeOfCharacterFromSet(newLineSet, options: .BackwardsSearch, range: NSRange(location: 0, length: selectedRange.location)).location
    var length = (self.contents() as NSString).rangeOfCharacterFromSet(newLineSet, options: .CaseInsensitiveSearch, range: NSRange(location: selectedRange.location+selectedRange.length, length: self.contents().characters.count - selectedRange.location - selectedRange.length)).location

    location = location == NSNotFound ? 0 : location + 1
    length = location == 0 ? length + 1 : length + 1 - location

    if length > self.contents().characters.count {
      length = self.contents().characters.count - location
    }

    return NSRange(location: location, length: length)
  }

  func contentsOfRange(range: NSRange) -> String {
    guard let textView = self.textView, contents = textView.string else { return "" }
    return (contents as NSString).substringWithRange(range)
  }

  func joinRange() -> NSRange {
    let lineRange = self.lineRange()
    let joinRange = NSRange(location: lineRange.location + lineRange.length - 1, length: 0)
    let validSet = NSCharacterSet(charactersInString: "0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_")
    let length = (self.contents() as NSString).rangeOfCharacterFromSet(validSet, options: .CaseInsensitiveSearch, range: NSRange(location: joinRange.location, length: self.contents().characters.count - joinRange.location)).location

    return NSRange(location: joinRange.location, length: length - joinRange.location)
  }

  func selectedText() -> String {
    guard let textView = self.textView else { return "" }
    return contentsOfRange(textView.selectedRange)
  }

  func hasSelection() -> Bool {
    return self.textView?.selectedRange.length ?? 0 > 0
  }

  func emptySelection() -> Bool {
    return self.hasSelection() == false
  }

  func layoutManager() -> NSLayoutManager? {
    return self.textView?.layoutManager
  }

  func insertText(string: String) {
    self.textView?.insertText(string)

    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.025 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      NSNotificationCenter.defaultCenter().postNotificationName("Add change mark", object: string)
    }
  }

  func replaceCharactersInRange(range: NSRange, withString string: String) {
    if range.location + range.length > self.contents().characters.count {
      var range = range
      range.length = self.contents().characters.count - range.location
    }

    let document = XcodeManager().currentSourceCodeDocument()
    let textStorage = document.textStorage()

    textStorage.replaceCharactersInRange(range, withString: string, withUndoManager: document.undoManager)

    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.025 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      NSNotificationCenter.defaultCenter().postNotificationName("Add change mark", object: string)
    }
  }

  private func isChar(char: Character, inSet set: NSCharacterSet) -> Bool {
    var found = false
    for ch in String(char).utf16 {
      if set.characterIsMember(ch) { found = true; break }
    }
    return found
  }
}

import Foundation

class XcodeManager: NSObject {

  var textView: NSTextView? {
    get {
      if let currentEditor = LegacyXcodeManager().currentEditor(),
        let className = NSClassFromString("IDESourceCodeEditor")
        , (currentEditor as AnyObject).isKind(of: className) {
          return (currentEditor as AnyObject).textView
      }

      if let currentEditor = LegacyXcodeManager().currentEditor(),
        let className = NSClassFromString("IDESourceCodeComparisonEditor")
        , (currentEditor as AnyObject).isKind(of: className) {
          return (currentEditor as AnyObject).keyTextView
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
    LegacyXcodeManager().save()
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
    let validSet = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_")
    let spaceSet = CharacterSet(charactersIn: "#-<>/(){}[],;:. \n`*\"' ")
    var selectedRange = self.selectedRange

    guard selectedRange.location + selectedRange.length < contents().characters.count else { return selectedRange }

    var character: Character
    if self.hasSelection() {
      character = self.contents()[self.contents().characters.index(self.contents().startIndex, offsetBy: selectedRange.location+selectedRange.length)]
    } else {
      character = self.contents()[self.contents().characters.index(self.contents().startIndex, offsetBy: selectedRange.location)]
    }

    if !isChar(character, inSet:validSet) {
      selectedRange.location = selectedRange.location + selectedRange.length
    }

    let scanner = Scanner(string: self.contents())
    scanner.scanLocation = selectedRange.location

    var length = selectedRange.location

    while !scanner.isAtEnd {
      if scanner.scanCharacters(from: validSet, into: nil) {
        length = scanner.scanLocation
        break
      }

      scanner.scanLocation = scanner.scanLocation + 1
    }

    let whitespaceRange = (self.contents() as NSString).rangeOfCharacter(from: spaceSet,
      options: .backwards,
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
      while !scanner.isAtEnd {
        if scanner.scanCharacters(from: validSet, into: nil) {
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
    let validSet = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_")
    var location = (self.contents() as NSString).rangeOfCharacter(from: validSet, options: .backwards, range: NSMakeRange(0,selectedRange.location)).location

    if location == NSNotFound {
      location = 0
    }

    return NSRange(location: location, length: 0)
  }

  func lineContentsRange() -> NSRange {
    let lineRange = self.lineRange()
    let currentLine = (self.contents() as NSString).substring(with: lineRange)
    let trimmedString = currentLine.trimmingCharacters(in: CharacterSet.whitespaces)
    let spacing = currentLine.replacingOccurrences(of: trimmedString, with: "")

    return NSRange(location: lineRange.location + spacing.characters.count, length: lineRange.length - spacing.characters.count - 1)
  }

  func lineRange() -> NSRange {
    var selectedRange = self.selectedRange

    if selectedRange.location == self.contents().characters.count {
      selectedRange.location -= 1
    }

    let newLineSet = CharacterSet(charactersIn: "\n")

    var location = (self.contents() as NSString).rangeOfCharacter(from: newLineSet, options: .backwards, range: NSRange(location: 0, length: selectedRange.location)).location
    var length = (self.contents() as NSString)
      .rangeOfCharacter(from: newLineSet,
        options: .caseInsensitive,
        range: NSRange(location: selectedRange.location + selectedRange.length,
          length: self.contents().characters.count - (selectedRange.location + selectedRange.length)))
      .location

    if length == NSNotFound {
      length = self.contents().characters.count - location
      return NSRange(location: location, length: length)
    }

    location = location == NSNotFound ? 0 : location + 1
    length = location == 0 ? length + 1 : length + 1 - location

    if length > self.contents().characters.count {
      length = self.contents().characters.count - location
    }

    return NSRange(location: location, length: length)
  }

  func contentsOfRange(_ range: NSRange) -> String {
    guard let textView = self.textView, let contents = textView.string else { return "" }
    return (contents as NSString).substring(with: range)
  }

  func joinRange() -> NSRange {
    let lineRange = self.lineRange()
    let joinRange = NSRange(location: lineRange.location + lineRange.length - 1, length: 0)
    let validSet = CharacterSet(charactersIn: "0123456789ABCDEFGHIJKOLMNOPQRSTUVWXYZÅÄÆÖØabcdefghijkolmnopqrstuvwxyzåäæöø_{}().$[]")
    let length = (self.contents() as NSString).rangeOfCharacter(from: validSet, options: .caseInsensitive, range: NSRange(location: joinRange.location, length: self.contents().characters.count - joinRange.location)).location

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

  func insertText(_ string: String) {
    self.textView?.insertText(string)

    let delayTime = DispatchTime.now() + 0.025
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      NotificationCenter.default.post(name: Notification.Name(rawValue: "Add change mark"), object: string)
    }
  }

  func replaceCharactersInRange(_ range: NSRange, withString string: String) {
    if range.location + range.length > self.contents().characters.count {
      var range = range
      range.length = self.contents().characters.count - range.location
    }

    let document = LegacyXcodeManager().currentSourceCodeDocument()
    let textStorage = document?.textStorage()

    textStorage?.replaceCharacters(in: range, with: string, withUndoManager: document?.undoManager)

    let delayTime = DispatchTime.now() + 0.025
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      NotificationCenter.default.post(name: Notification.Name(rawValue: "Add change mark"), object: string)
    }
  }

  fileprivate func isChar(_ char: Character, inSet set: CharacterSet) -> Bool {
    var found = false
    for ch in String(char).utf16 {
      if set.contains(UnicodeScalar(ch)!) { found = true; break }
    }
    return found
  }
}

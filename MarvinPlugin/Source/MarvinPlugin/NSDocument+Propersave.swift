import Foundation
import Cocoa

final class SaveSwizzler {

  private static var swizzled = false

  private init() {
    fatalError()
  }

  class func swizzle() {
    if swizzled { return }
    swizzled = true

    var original, swizzle: Method

    original = class_getInstanceMethod(NSDocument.self, #selector(NSDocument.saveDocumentWithDelegate(_:didSaveSelector:contextInfo:)))
    swizzle = class_getInstanceMethod(NSDocument.self, #selector(NSDocument.zen_saveDocumentWithDelegate(_:didSaveSelector:contextInfo:)))

    method_exchangeImplementations(original, swizzle)
  }
}

extension NSDocument {

  dynamic func zen_saveDocumentWithDelegate(delegate: AnyObject?, didSaveSelector: Selector, contextInfo: UnsafeMutablePointer<Void>) {
    if shouldFormat() {
      NSNotificationCenter.defaultCenter().postNotificationName("Save properly", object: nil)
    }

    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.25 * Double(NSEC_PER_SEC)))
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.zen_saveDocumentWithDelegate(delegate, didSaveSelector: didSaveSelector, contextInfo: contextInfo)
    }
  }

  func shouldFormat() -> Bool {
    guard let fileURL = fileURL,
      pathExtension = fileURL.pathExtension
      else { return false }

    return [
      "",
      "c",
      "cc",
      "cpp",
      "h",
      "hpp",
      "ipp",
      "m", "mm",
      "plist",
      "rb",
      "strings",
      "swift",
      "playground",
      "md",
      "yml"
      ]
      .contains(pathExtension.lowercaseString)
  }
}

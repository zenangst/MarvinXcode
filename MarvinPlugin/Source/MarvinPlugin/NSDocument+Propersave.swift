import Foundation
import Cocoa

extension NSDocument {

  public override class func initialize() {
    guard self !== NSDocument.self else { return }

    struct Static {
      static var token: dispatch_once_t = 0
    }

    dispatch_once(&Static.token) {
      var original, swizzle: Method

      original = class_getInstanceMethod(self, "saveDocumentWithDelegate:didSaveSelector:contextInfo:")
      swizzle = class_getInstanceMethod(self, "zen_saveDocumentWithDelegate:didSaveSelector:contextInfo:")

      method_exchangeImplementations(original, swizzle)
    }
  }

  func zen_saveDocumentWithDelegate(delegate: AnyObject?, didSaveSelector: Selector, contextInfo: UnsafeMutablePointer<Void>) {

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
      "md"
      ]
      .contains(pathExtension.lowercaseString)
  }
}

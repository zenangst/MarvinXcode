import Foundation
import Cocoa

final class SaveSwizzler {

  fileprivate static var swizzled = false

  fileprivate init() {
    fatalError()
  }

  class func swizzle() {
    if swizzled { return }
    swizzled = true

    var original, swizzle: Method

    original = class_getInstanceMethod(NSDocument.self, #selector(NSDocument.save(withDelegate:didSave:contextInfo:)))
    swizzle = class_getInstanceMethod(NSDocument.self, #selector(NSDocument.zen_saveDocumentWithDelegate(_:didSaveSelector:contextInfo:)))

    method_exchangeImplementations(original, swizzle)
  }
}

extension NSDocument {

  dynamic func zen_saveDocumentWithDelegate(_ delegate: AnyObject?, didSaveSelector: Selector, contextInfo: UnsafeMutableRawPointer) {
    if shouldFormat() {
      NotificationCenter.default.post(name: Notification.Name(rawValue: "Save properly"), object: nil)
    }

    let delayTime = DispatchTime.now() + Double(Int64(0.25 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: delayTime) {
      self.zen_saveDocumentWithDelegate(delegate, didSaveSelector: didSaveSelector, contextInfo: contextInfo)
    }
  }

  func shouldFormat() -> Bool {
    guard let fileURL = fileURL
      else { return false }

    let pathExtension = fileURL.pathExtension

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
      .contains(pathExtension.lowercased())
  }
}

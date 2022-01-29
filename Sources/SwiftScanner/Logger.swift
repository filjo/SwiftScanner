import Foundation

struct Logger {

  static func info(_ text: String) {
    print("🚀 | SWIFT SCANNER INFO | \(text)")
  }

  static func failure(_ text: String) {
    print("⛔ | SWIFT SCANNER ERROR | \(text)")
  }
}

import Foundation
import SwiftUI
import Swift

public struct ScannerView: UIViewControllerRepresentable {

  public weak var scannerDelegate: ScannerDelegate?

  public var restartSession: Bool

  let viewController = UIViewController()

  public init(scannerDelegate: ScannerDelegate?, restartSession: Bool) {
    self.scannerDelegate = scannerDelegate
    self.restartSession = restartSession
  }

  // MARK: UIViewControllerRepresentable

  public func makeUIViewController(context: Context) -> UIViewController {
    viewController
  }

  public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    if context.coordinator.isInitialSession {
      context.coordinator.isInitialSession = false
      return
    }

    if restartSession {
      print("Session restarted")
      context.coordinator.scanner.startCaptureSession()
    } else {
      print("Session closed")
      context.coordinator.scanner.stopCaptureSession()
    }
  }

  public func makeCoordinator() -> Coordinator {
    Coordinator(self, viewController: viewController)
  }

  // MARK: Coordinator

  public class Coordinator: NSObject {

    var parent: ScannerView

    var viewController: UIViewController

    var scanner: Scanner

    var isInitialSession = true

    init(_ parent: ScannerView, viewController: UIViewController) {
      self.parent = parent
      self.viewController = viewController

      self.scanner = Scanner(from: viewController)
      self.scanner.delegate = parent.scannerDelegate
      self.scanner.createAndStartSession()
    }
  }
}

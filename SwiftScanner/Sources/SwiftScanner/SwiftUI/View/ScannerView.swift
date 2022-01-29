import Foundation
import SwiftUI
import Swift
import AVFoundation

public struct ScannerView: UIViewControllerRepresentable {

  public weak var scannerDelegate: ScannerDelegate?

  public var restartSession: Bool

  public var metadataObjectTypes: [AVMetadataObject.ObjectType]

  let viewController = UIViewController()

  public init(scannerDelegate: ScannerDelegate?,
              restartSession: Bool,
              metadataObjectTypes: [AVMetadataObject.ObjectType] = MetadataObjectTypes.default) {
    self.scannerDelegate = scannerDelegate
    self.restartSession = restartSession
    self.metadataObjectTypes = metadataObjectTypes
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
      context.coordinator.scanner.startCaptureSession()
    } else {
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

      self.scanner = Scanner(from: viewController, metadataObjectTypes: parent.metadataObjectTypes)
      self.scanner.delegate = parent.scannerDelegate
      self.scanner.createAndStartSession()
    }
  }
}

import AVFoundation
import UIKit

final class Scanner: NSObject {

  // MARK: Private

  private var viewController: UIViewController
  private var capturedSession: AVCaptureSession?
  private var metadataObjectTypes: [AVMetadataObject.ObjectType] = []

  static let defaultMetadataObjectTypes: [AVMetadataObject.ObjectType] = [
    .qr, .ean8, .ean13, .pdf417
  ]

  // MARK: Public Methods

  public init(from viewController: UIViewController, metadataObjectTypes: [AVMetadataObject.ObjectType] = defaultMetadataObjectTypes) {
    self.viewController = viewController
    self.metadataObjectTypes = metadataObjectTypes
    self.capturedSession = AVCaptureSession()
  }

  public func startCaptureSession() {
    guard let capturedSession = capturedSession else {
      return
    }

    if capturedSession.isRunning == false {
      capturedSession.startRunning()
    }
  }

  public func stopCaptureSession() {
    guard let capturedSession = capturedSession else {
      return
    }

    if capturedSession.isRunning == true {
      capturedSession.stopRunning()
    }
  }
}

// MARK: Private Methods

private extension Scanner {

  func runSession() {
    guard let session = capturedSession else { return }
    guard let capturedDevice = AVCaptureDevice.default(for: .video) else { return }
    do {
      let capturedDeviceInput = try AVCaptureDeviceInput(device: capturedDevice)

      // AVCaptureDeviceInput
      if session.canAddInput(capturedDeviceInput) {
        session.addInput(capturedDeviceInput)
      } else {
        return
      }

      // AVCaptureMetadataOutput
      let metadataOutput = AVCaptureMetadataOutput()
      if session.canAddOutput(metadataOutput) {
        session.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = metadataObjectTypes
        
      } else {
        assertionFailure()
        return
      }

      // AVCaptureVideoPreviewLayer
      let previewControllerLayer = AVCaptureVideoPreviewLayer(session: session)
      previewControllerLayer.frame = viewController.view.bounds
      previewControllerLayer.videoGravity = .resizeAspectFill
      viewController.view.layer.addSublayer(previewControllerLayer)

    } catch {
      assertionFailure()
      return
    }

    // Start session
    session.startRunning()
  }

  private func codeFounded(code: String) {
    print("Code \(code)")
  }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension Scanner: AVCaptureMetadataOutputObjectsDelegate {

  func metadataOutput(_ output: AVCaptureMetadataOutput,
                      didOutput metadataObjects: [AVMetadataObject],
                      from connection: AVCaptureConnection) {

    capturedSession?.stopRunning()

    guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
          let string = readableObject.stringValue else {
            return
          }

    codeFounded(code: string)
  }
}

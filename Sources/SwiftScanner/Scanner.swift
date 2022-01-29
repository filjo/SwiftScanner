import AVFoundation
import UIKit
import SwiftUI

final public class Scanner: NSObject {

  // MARK: Private Properties

  private var viewController: UIViewController
  private var capturedSession: AVCaptureSession?
  private var metadataObjectTypes: [AVMetadataObject.ObjectType] = []

  // MARK: Public Properties

  public weak var delegate: ScannerDelegate?

  // MARK: Init

  public init(from viewController: UIViewController,
              metadataObjectTypes: [AVMetadataObject.ObjectType] = MetadataObjectTypes.default,
              delegate: ScannerDelegate? = nil) {
    self.viewController = viewController
    self.metadataObjectTypes = metadataObjectTypes
    self.delegate = delegate
    self.capturedSession = AVCaptureSession()
  }
}

// MARK: Public Methods

extension Scanner {

  public func startCaptureSession() {
    guard let capturedSession = capturedSession else {
      return
    }

    if capturedSession.isRunning == false {
      capturedSession.startRunning()
      Logger.info("Session started......")
    }
  }

  public func stopCaptureSession() {
    guard let capturedSession = capturedSession else {
      return
    }

    if capturedSession.isRunning == true {
      capturedSession.stopRunning()
      Logger.info("Session ended......")
    }
  }

  public func createAndStartSession() {
    guard let session = capturedSession else {
      Logger.failure("No session has been initialized")
      return
    }

    guard let capturedDevice = AVCaptureDevice.default(for: .video) else {
      Logger.failure("No captured device for default type .video")
      return
    }

    do {
      let capturedDeviceInput = try AVCaptureDeviceInput(device: capturedDevice)

      // AVCaptureDeviceInput
      if session.canAddInput(capturedDeviceInput) {
        session.addInput(capturedDeviceInput)
      } else {
        Logger.failure("Failed adding capturedDevice input")
        return
      }

      // AVCaptureMetadataOutput
      let metadataOutput = AVCaptureMetadataOutput()
      if session.canAddOutput(metadataOutput) {
        session.addOutput(metadataOutput)

        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        
      } else {
        Logger.failure("Failed adding metadata output")
        return
      }

      // AVCaptureVideoPreviewLayer
      let previewControllerLayer = AVCaptureVideoPreviewLayer(session: session)
      previewControllerLayer.frame = viewController.view.layer.bounds
      previewControllerLayer.videoGravity = .resizeAspectFill
      viewController.view.layer.addSublayer(previewControllerLayer)

      // Start session
      session.startRunning()
      
    } catch {
      Logger.failure(error.localizedDescription)
      return
    }
  }
}

// MARK: Private Methods

private extension Scanner {

  func found(code: String) {
    Logger.info("Code found. Code = \(code)")
  }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension Scanner: AVCaptureMetadataOutputObjectsDelegate {

  public func metadataOutput(_ output: AVCaptureMetadataOutput,
                      didOutput metadataObjects: [AVMetadataObject],
                      from connection: AVCaptureConnection) {

    capturedSession?.stopRunning()

    self.delegate?.metadataOutput(output, didOutput: metadataObjects, from: connection)
    guard let readableObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
          let string = readableObject.stringValue else {
            Logger.failure("Can't read metadata object.")
            return
          }

    found(code: string)
    delegate?.metadataOutput(string)
  }
}

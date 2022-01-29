import AVFoundation

public protocol ScannerDelegate: AnyObject {
  func metadataOutput(_ output: AVCaptureMetadataOutput,
                      didOutput metadataObjects: [AVMetadataObject],
                      from connection: AVCaptureConnection)
  func metadataOutput(_ string: String)
}

extension ScannerDelegate {
  public func metadataOutput(_ output: AVCaptureMetadataOutput,
                      didOutput metadataObjects: [AVMetadataObject],
                             from connection: AVCaptureConnection) {}
  func metadataOutput(_ string: String) {}
}

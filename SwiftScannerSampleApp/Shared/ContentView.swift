import SwiftUI
import SwiftScanner
import AVFoundation

class ViewModel: ObservableObject, ScannerDelegate {

  @Published var restartSession: Bool = false
  @Published var code: String = ""

  func metadataOutput(_ string: String) {
    print("ViewModel outuput \(string)")
    restartSession = false
    code = string
  }

  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    print("Metadata output")
  }

  func performRestarSession() {
    code = ""
    restartSession = true
  }
}

struct ContentView: View {

  @ObservedObject var viewModel: ViewModel = ViewModel()
  
  var body: some View {
    NavigationView {
      ZStack(alignment: .center) {
        ScannerView(scannerDelegate: viewModel,
                    restartSession: viewModel.restartSession)
        if !viewModel.code.isEmpty {
          VStack(spacing: 10) {
            Text("Code is:")
              .font(.body)
              .padding()
              .cornerRadius(8)
              .foregroundColor(.black)
            Text(viewModel.code)
              .font(.title)
              .foregroundColor(.black)
            Button("Scan again") {
              viewModel.performRestarSession()
            }
            .padding(10)
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(8)
          }
          .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
          .background(Color.white)
          .cornerRadius(8)
        }
      }
      .navigationTitle("Scan")
      .navigationBarTitleDisplayMode(.inline)
      .foregroundColor(.white)
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

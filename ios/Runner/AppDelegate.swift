import UIKit
import Flutter
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  var flutterResult: FlutterResult?
  var imagePicker: UIImagePickerController!

  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    // ✅ Register all Flutter plugins (path_provider, cbl_flutter, etc.)
    GeneratedPluginRegistrant.register(with: self)

    // ✅ Setup your custom platform channel after registration
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let cameraChannel = FlutterMethodChannel(
      name: "samples.flutter.dev/camera",
      binaryMessenger: controller.binaryMessenger
    )

    cameraChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
      guard call.method == "takePicture" else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.flutterResult = result
      self?.openCamera()
    }

    // ✅ Return super after plugin registration and setup
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func openCamera() {
    // Check camera availability
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
      flutterResult?(FlutterError(code: "no_camera", message: "No camera available", details: nil))
      flutterResult = nil
      return
    }

    // Ask camera permission
    AVCaptureDevice.requestAccess(for: .video) { granted in
      DispatchQueue.main.async {
        if granted {
          self.imagePicker = UIImagePickerController()
          self.imagePicker.sourceType = .camera
          self.imagePicker.delegate = self
          self.imagePicker.allowsEditing = false
          self.window?.rootViewController?.present(self.imagePicker, animated: true)
        } else {
          self.flutterResult?(FlutterError(code: "permission_denied", message: "Camera permission denied", details: nil))
          self.flutterResult = nil
        }
      }
    }
  }

  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

    picker.dismiss(animated: true, completion: nil)

    guard let image = info[.originalImage] as? UIImage else {
      flutterResult?(FlutterError(code: "no_image", message: "Failed to capture image", details: nil))
      flutterResult = nil
      return
    }

    let fileName = "IMG_\(Int(Date().timeIntervalSince1970)).jpg"
    let tempDir = NSTemporaryDirectory()
    let fileURL = URL(fileURLWithPath: tempDir).appendingPathComponent(fileName)

    if let imageData = image.jpegData(compressionQuality: 1.0) {
      try? imageData.write(to: fileURL)
      flutterResult?(fileURL.path)
    } else {
      flutterResult?(FlutterError(code: "save_error", message: "Could not save image", details: nil))
    }
    flutterResult = nil
  }

  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion: nil)
    flutterResult?(FlutterError(code: "cancelled", message: "User cancelled camera", details: nil))
    flutterResult = nil
  }
}

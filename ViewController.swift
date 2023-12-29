import UIKit
import AVFoundation

class ViewController: UIViewController {

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var distanceLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCamera()
        setupUI()
    }

    private func setupCamera() {
        guard let device = AVCaptureDevice.default(.builtInLiDARScanner, for: .depthData, position: .back) else {
            print("LiDAR sensor not available.")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)

            let metadataOutput = AVCaptureMetadataOutput()
            if captureSession!.canAddOutput(metadataOutput) {
                captureSession?.addOutput(metadataOutput)
            }

            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            previewLayer?.frame = view.layer.bounds
            previewLayer?.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer!)

            captureSession?.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }

    private func setupUI() {
        distanceLabel = UILabel(frame: CGRect(x: 20, y: 20, width: view.frame.width - 40, height: 40))
        distanceLabel.textColor = .white
        distanceLabel.textAlignment = .center
        distanceLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(distanceLabel)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

extension ViewController: AVCaptureDepthDataOutputDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput depthData: AVDepthData, timestamp: CMTime, connection: AVCaptureConnection) {

        if let depthDataMap = depthData.depthDataMap {

            let depth = depthDataMap.distance(from: CGPoint(x: 0.5, y: 0.5))
            let distanceInCentimeters = depth * 100

            DispatchQueue.main.async {
                self.distanceLabel.text = String(format: "Distance: %.2f cm", distanceInCentimeters)
            }
        }
    }
}

let depthOutput = AVCaptureDepthDataOutput()
if captureSession!.canAddOutput(depthOutput) {
    captureSession?.addOutput(depthOutput)
    depthOutput.setDelegate(self, callbackQueue: DispatchQueue.global(qos: .userInteractive))
}

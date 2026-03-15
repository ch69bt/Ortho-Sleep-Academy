import AVFoundation
import Flutter
import UIKit

/// AVFoundationのカメラからISO・シャッタースピードを取得し、照度(lux)を算出するプラグイン
///
/// 算出式:
///   EV100 = log2(N² / t) - log2(ISO / 100)  ≡  log2(100 × N² / (ISO × t))
///   lux   ≈ 2.5 × 2^EV100
///
/// N: Fナンバー（iPhoneの標準カメラ: f/1.8 ≒ 1.78）
/// t: 露出時間（秒）
/// ISO: 感度
final class LuxMeasurementPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    // MARK: - Constants

    private static let methodChannelName = "com.ortholutxmeter/lux"
    private static let eventChannelName  = "com.ortholutxmeter/lux_stream"

    private static let maxLux: Double  = 300_000
    private static let minLux: Double  = 0

    // MARK: - Properties

    private var captureSession: AVCaptureSession?
    private var videoOutput: AVCaptureVideoDataOutput?
    private var eventSink: FlutterEventSink?

    private let sessionQueue = DispatchQueue(label: "com.ortholutxmeter.session")

    // MARK: - FlutterPlugin Registration

    static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger()

        let instance = LuxMeasurementPlugin()

        let methodChannel = FlutterMethodChannel(
            name: methodChannelName,
            binaryMessenger: messenger
        )
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let eventChannel = FlutterEventChannel(
            name: eventChannelName,
            binaryMessenger: messenger
        )
        eventChannel.setStreamHandler(instance)
    }

    // MARK: - FlutterPlugin (MethodChannel)

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startMeasurement":
            requestCameraPermissionAndStart(result: result)
        case "stopMeasurement":
            stopCapture()
            result(nil)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - FlutterStreamHandler (EventChannel)

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        stopCapture()
        return nil
    }

    // MARK: - Camera Permission

    private func requestCameraPermissionAndStart(result: @escaping FlutterResult) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCapture()
            result(nil)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.startCapture()
                    result(nil)
                } else {
                    result(FlutterError(
                        code: "PERMISSION_DENIED",
                        message: "カメラの許可がありません",
                        details: nil
                    ))
                }
            }
        default:
            result(FlutterError(
                code: "PERMISSION_DENIED",
                message: "カメラの許可がありません。設定から許可してください。",
                details: nil
            ))
        }
    }

    // MARK: - AVCaptureSession

    private func startCapture() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }

            if self.captureSession?.isRunning == true { return }

            let session = AVCaptureSession()
            session.sessionPreset = .low  // 最低解像度で十分（露出値のみ取得）

            guard let device = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .back
            ) else {
                DispatchQueue.main.async {
                    self.eventSink?(FlutterError(
                        code: "NO_CAMERA",
                        message: "カメラが見つかりません",
                        details: nil
                    ))
                }
                return
            }

            do {
                // 自動露出を有効にする
                try device.lockForConfiguration()
                if device.isExposureModeSupported(.continuousAutoExposure) {
                    device.exposureMode = .continuousAutoExposure
                }
                device.unlockForConfiguration()

                let input = try AVCaptureDeviceInput(device: device)
                guard session.canAddInput(input) else { return }
                session.addInput(input)

                let output = AVCaptureVideoDataOutput()
                output.videoSettings = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
                ]
                output.setSampleBufferDelegate(self, queue: self.sessionQueue)
                output.alwaysDiscardsLateVideoFrames = true

                guard session.canAddOutput(output) else { return }
                session.addOutput(output)

                self.captureSession = session
                self.videoOutput = output
                session.startRunning()

            } catch {
                DispatchQueue.main.async {
                    self.eventSink?(FlutterError(
                        code: "CAMERA_ERROR",
                        message: error.localizedDescription,
                        details: nil
                    ))
                }
            }
        }
    }

    private func stopCapture() {
        sessionQueue.async { [weak self] in
            self?.captureSession?.stopRunning()
            self?.captureSession = nil
            self?.videoOutput = nil
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension LuxMeasurementPlugin: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let device = (captureSession?.inputs.first as? AVCaptureDeviceInput)?.device else {
            return
        }

        let iso = Double(device.iso)
        let exposureDuration = device.exposureDuration
        let t = CMTimeGetSeconds(exposureDuration)  // 露出時間（秒）
        let n = Double(device.lensAperture)         // 実機のFナンバーを取得

        guard t > 0, iso > 0, n > 0 else { return }

        let lux = calculateLux(iso: iso, exposureTime: t, fNumber: n)

        DispatchQueue.main.async { [weak self] in
            self?.eventSink?(lux)
        }
    }

    /// ISO・露出時間・Fナンバーから照度(lux)を近似算出
    ///
    /// EV100 = log2(N² / t) - log2(ISO / 100)  ≡  log2(100 × N² / (ISO × t))
    /// lux   = 2.5 × 2^EV100
    private func calculateLux(iso: Double, exposureTime t: Double, fNumber n: Double) -> Double {
        let ev100 = log2((n * n) / t) - log2(iso / 100.0)
        let lux = 2.5 * pow(2.0, ev100)
        return min(max(lux, LuxMeasurementPlugin.minLux), LuxMeasurementPlugin.maxLux)
    }
}

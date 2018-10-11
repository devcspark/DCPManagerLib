//
//  DCPCamaraView.swift
//  Pods
//
//  Created by ChunsooPark on 11/10/2018.
//

import UIKit
import AVKit

public extension AVCaptureVideoOrientation {
    var uiInterfaceOrientation: UIInterfaceOrientation {
        get {
            switch self {
            case .landscapeLeft:        return .landscapeLeft
            case .landscapeRight:       return .landscapeRight
            case .portrait:             return .portrait
            case .portraitUpsideDown:   return .portraitUpsideDown
            }
        }
    }
    
    init(ui:UIInterfaceOrientation) {
        switch ui {
        case .landscapeRight:       self = .landscapeRight
        case .landscapeLeft:        self = .landscapeLeft
        case .portrait:             self = .portrait
        case .portraitUpsideDown:   self = .portraitUpsideDown
        default:                    self = .portrait
        }
    }
}

public class DCPCamaraView: UIView, AVCaptureFileOutputRecordingDelegate {

    private var localVideoPath = ""
    
    private var cameraPosition = AVCaptureDevice.Position.front
    
    private var _deviceDiscoverySession : AVCaptureDevice.DiscoverySession?
    private var deviceDiscoverySession : AVCaptureDevice.DiscoverySession! {
        get{
            return _deviceDiscoverySession ?? { () -> AVCaptureDevice.DiscoverySession? in
                _deviceDiscoverySession = .init(deviceTypes: [.builtInWideAngleCamera, .builtInMicrophone],
                                                mediaType: AVMediaType.video,
                                                position: .unspecified)
                return _deviceDiscoverySession
                }()
        }
    }
    
    private var _session : AVCaptureSession?
    private var session : AVCaptureSession! {
        get{
            return _session ?? { () -> AVCaptureSession? in
                _session = .init()
                if _session!.canSetSessionPreset(.high) {
                    _session!.sessionPreset = .high
                }
                return _session
                }()
        }
    }
    
    private var videoDeviceInput:AVCaptureDeviceInput?
    private var audioDeviceInput:AVCaptureDeviceInput?
    private var fileOutput:AVCaptureMovieFileOutput!
    
    private var _previewLayer:AVCaptureVideoPreviewLayer?
    private var previewLayer:AVCaptureVideoPreviewLayer! {
        get{
            return _previewLayer ?? { () -> AVCaptureVideoPreviewLayer? in
                _previewLayer = .init(session: session)
                _previewLayer?.videoGravity = .resizeAspectFill
                _previewLayer?.frame = self.bounds
                self.layer.addSublayer(_previewLayer!)
                return _previewLayer
                }()
        }
    }
    
    private var isInitCarmera = false
    
    public func openCamera(initPosition:AVCaptureDevice.Position, completeHandler:@escaping((Bool)->Void)) {
        
        cameraPosition = initPosition
        
        if(!isInitCarmera){
            DCPPermissionManager.shared().CheckPermission(permission: [.Camera, .Microphone]) { (isAccess) in
                if isAccess {
                    
                    let devices = self.deviceDiscoverySession.devices
                    var videoDeviceInput:AVCaptureDeviceInput? = nil
                    var audioDeviceInput:AVCaptureDeviceInput? = nil
                    
                    for device in devices {
                        do {
                            try device.lockForConfiguration()
                            // set to 20 frame.
                            device.activeVideoMinFrameDuration = CMTimeMake(1, 30)
                            device.activeVideoMaxFrameDuration = CMTimeMake(1, 30)
                            device.unlockForConfiguration()
                            
                            if device.position == self.cameraPosition { // default is front.
                                videoDeviceInput = try AVCaptureDeviceInput.init(device: device)
                            }
                        } catch {
                            continue
                        }
                    }
                    
                    if let audioDevice = AVCaptureDevice.default(for: .audio) {
                        audioDeviceInput = try? AVCaptureDeviceInput.init(device: audioDevice)
                    }
                    
                    if videoDeviceInput != nil {
                        self.session.beginConfiguration()
                        
                        self.videoDeviceInput = videoDeviceInput
                        self.session.addInput(self.videoDeviceInput!)
                        
                        if audioDeviceInput != nil {
                            self.audioDeviceInput = audioDeviceInput
                            self.session.addInput(self.audioDeviceInput!)
                        }
                        
                        self.fileOutput = .init()
                        self.fileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(60, 30)
                        self.fileOutput.minFreeDiskSpaceLimit = 1024 * 1024
                        
                        if self.session.canAddOutput(self.fileOutput) {
                            self.session.addOutput(self.fileOutput)
                        }
                        
                        if let captureConnection = self.fileOutput.connection(with: .video) {
                            if captureConnection.isVideoOrientationSupported {
                                captureConnection.videoOrientation = AVCaptureVideoOrientation.init(ui: UIApplication.shared.statusBarOrientation)
                            }
                        }
                        
                        self.session.commitConfiguration()
                        self.session.startRunning()
                    }
                    
                    self.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.init(ui: UIApplication.shared.statusBarOrientation)
                    try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryMultiRoute, with: .mixWithOthers)
                    
                    self.isInitCarmera = true
                    completeHandler(true)
                }else{
                    completeHandler(false)
                }
            }
        }else{
            
            self.session.stopRunning()
            self.session.removeInput(self.videoDeviceInput!)
            self.videoDeviceInput = nil
            let devices = self.deviceDiscoverySession.devices
            for device in devices {
                do {
                    try device.lockForConfiguration()
                    // set to 20 frame.
                    device.activeVideoMinFrameDuration = CMTimeMake(1, 30)
                    device.activeVideoMaxFrameDuration = CMTimeMake(1, 30)
                    device.unlockForConfiguration()
                    
                    if device.position == cameraPosition { // default is front.
                        self.videoDeviceInput = try AVCaptureDeviceInput.init(device: device)
                    }
                } catch {
                    continue
                }
            }
            self.session.addInput(self.videoDeviceInput!)
            self.session.startRunning()
        }
    }
    
    public var isRecording = false
    
    private var completeHandler:((String)->Void)?
    
    public func changeCamera() {
        openCamera(initPosition: (cameraPosition == .front) ? AVCaptureDevice.Position.back : .front ) { (_) in }
    }
    
    public func startRecord(fileName:String) {
        localVideoPath = NSTemporaryDirectory() + fileName
        try? FileManager.default.removeItem(atPath: localVideoPath)
        
        fileOutput.startRecording(to: URL(fileURLWithPath: localVideoPath), recordingDelegate: self)
        isRecording = true
    }
    
    public func stopRecord(handler:@escaping((String)->Void)) {
        if(isRecording){
            completeHandler = handler
            fileOutput.stopRecording()
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if(completeHandler != nil) {
            completeHandler!(outputFileURL.path)
            completeHandler = nil
        }
    }
}

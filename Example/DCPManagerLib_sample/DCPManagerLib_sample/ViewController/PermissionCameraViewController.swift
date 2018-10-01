//
//  PermissionCameraViewController.swift
//  DCPManagerLib_sample
//
//  Created by ChunsooPark on 2018. 9. 21..
//  Copyright © 2018년 devcspark. All rights reserved.
//

import UIKit
import AVKit

extension AVCaptureVideoOrientation {
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

class PermissionCameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    @IBOutlet weak var viewCameraPreview: UIView!
    
    private var _deviceDiscoverySession : AVCaptureDevice.DiscoverySession?
    private var deviceDiscoverySession : AVCaptureDevice.DiscoverySession! {
        get{
            return _deviceDiscoverySession ?? { () -> AVCaptureDevice.DiscoverySession? in
                _deviceDiscoverySession = .init(deviceTypes: [.builtInWideAngleCamera, .builtInMicrophone],
                                                mediaType: AVMediaType.video,
                                                position: .front)
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
                _previewLayer?.frame = viewCameraPreview.bounds
                viewCameraPreview.layer.addSublayer(_previewLayer!)
                return _previewLayer
            }()
        }
    }
    
    private var localVideoPath = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
                        
                        if device.position == .front { // default is front.
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
                
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Button action
    @IBAction func pressedBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedRecord(_ sender: UIButton) {
        if sender.isSelected {
            // stop record
            sender.isSelected = false
            
            fileOutput.stopRecording()
        }else{
            // start record
            sender.isSelected = true
            
            localVideoPath = NSTemporaryDirectory() + "tempVideoPath.mp4"
            try? FileManager.default.removeItem(atPath: localVideoPath)
            
            fileOutput.startRecording(to: URL(fileURLWithPath: localVideoPath), recordingDelegate: self)
        }
    }
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.path) {  // surpported file format?
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(finishedSaveAlbum(_:error:contextInfo:)), nil)
        }
    }

    @objc func finishedSaveAlbum(_ videoPath:String, error:NSError?, contextInfo:UnsafeMutableRawPointer) {
        let okMessage =  UIAlertController(title: "save", message: "saveed video!", preferredStyle: .alert)
        okMessage.addAction(UIAlertAction.init(title: "ok", style: .default, handler: { (action) in
            okMessage.dismiss(animated: true, completion: nil)
        }))
        self.present(okMessage, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

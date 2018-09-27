//
//  PermissionCameraViewController.swift
//  DCPManagerLib_sample
//
//  Created by ChunsooPark on 2018. 9. 21..
//  Copyright © 2018년 devcspark. All rights reserved.
//

import UIKit
import AVKit

class PermissionCameraViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DCPPermissionManager.shared().CheckPermission(permission: [.Camera, .Microphone]) { (isAccess) in
            if isAccess {
                
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

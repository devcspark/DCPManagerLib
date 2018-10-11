//
//  PermissionCameraViewController.swift
//  DCPManagerLib_sample
//
//  Created by ChunsooPark on 2018. 9. 21..
//  Copyright © 2018년 devcspark. All rights reserved.
//

import UIKit
import AVKit
import DCPManagerLib

class PermissionCameraViewController: UIViewController {
    
    @IBOutlet weak var viewCameraPreview: DCPCamaraView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        viewCameraPreview.openCamera(initPosition: .front) { (isSuccess) in
            if(!isSuccess){
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
            
            viewCameraPreview.stopRecord { (outputFilePath) in
                if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFilePath) {  // surpported file format?
                    UISaveVideoAtPathToSavedPhotosAlbum(outputFilePath, self, #selector(self.finishedSaveAlbum(_:error:contextInfo:)), nil)
                }
            }
        }else{
            // start record
            sender.isSelected = true

            viewCameraPreview.startRecord(fileName: "tempVideoPath.mp4")
        }
    }
    
    @IBAction func pressedChange(_ sender: UIButton) {
        viewCameraPreview.changeCamera()
    }
    
    @objc func finishedSaveAlbum(_ videoPath:String, error:NSError?, contextInfo:UnsafeMutableRawPointer) {
        let okMessage =  UIAlertController(title: "save", message: "saveed video!", preferredStyle: .alert)
        okMessage.addAction(UIAlertAction.init(title: "ok", style: .default, handler: { (action) in
            okMessage.dismiss(animated: true, completion: nil)
        }))
        self.present(okMessage, animated: true, completion: nil)
    }

}

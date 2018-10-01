//
//  PermissionManager.swift
//  VKinnyPersonal
//
//  Created by ChunsooPark on 2018. 8. 29..
//  Copyright © 2018년 V.CAMP. All rights reserved.
//

import UIKit
import AVKit
import Photos

// supported permission is photo, camera, microphone
enum DCPPermissionNeed: Int {
    case Photo = 1
    case Camera
    case Microphone
}


class DCPPermissionManager: NSObject {

    private enum ResultPermission: Int {
        case need_Permission = 1
        case Denied
        case Authorized
    }
    
    private var completeHandler : ((Bool)->Void)?       // 완료시 실행하게될 클로져
    private var photoAuthorizeResult : ResultPermission = ResultPermission.Authorized
    private var cameraAuthorizeResult : ResultPermission = ResultPermission.Authorized
    private var micAuthorizeResult : ResultPermission = ResultPermission.Authorized
    
    private static var sharedManager : DCPPermissionManager = {
        let pManager = DCPPermissionManager()
        // 각종 초기화
        return pManager
    }()

    class func shared() -> DCPPermissionManager {
        return sharedManager
    }
    
    func CheckPermission(permission:[DCPPermissionNeed], complete:@escaping(Bool)->Void ) -> Void {
                
        self.completeHandler = complete
        
        for permissionTemp in permission {
            if (permissionTemp == .Photo ) {
                photoAuthorizeResult = .need_Permission
            }
            
            if (permissionTemp == .Camera ) {
                cameraAuthorizeResult = .need_Permission
            }
            
            if (permissionTemp == .Microphone ) {
                micAuthorizeResult = .need_Permission
            }            
        }
        
        RecursiveRequestAuthorization()
    }
    
    private func RecursiveRequestAuthorization() {
        
        if photoAuthorizeResult == .need_Permission {
            PHPhotoLibrary.requestAuthorization { [weak self](status) in
                if(status == PHAuthorizationStatus.authorized){
                    self?.photoAuthorizeResult = .Authorized
                }else{
                    self?.photoAuthorizeResult = .Denied
                }
                self?.RecursiveRequestAuthorization()
            }
            return
        }
        
        if cameraAuthorizeResult == .need_Permission {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { [weak self](isAccess) in
                if (isAccess) {
                    self?.cameraAuthorizeResult = .Authorized
                }else{
                    self?.cameraAuthorizeResult = .Denied
                }
                self?.RecursiveRequestAuthorization()
            }
            return
        }
        
        if micAuthorizeResult == .need_Permission {
            AVCaptureDevice.requestAccess(for: AVMediaType.audio) { [weak self](isAccess) in
                if (isAccess) {
                    self?.micAuthorizeResult = .Authorized
                }else{
                    self?.micAuthorizeResult = .Denied
                }
                self?.RecursiveRequestAuthorization()
            }
            
            return
        }
        
        DispatchQueue.main.async {
            if( self.photoAuthorizeResult == .Authorized &&
                self.cameraAuthorizeResult == .Authorized &&
                self.micAuthorizeResult == .Authorized ){
                self.completeHandler!(true)
            }else{
                self.completeHandler!(false)
            }
        }
    }
}

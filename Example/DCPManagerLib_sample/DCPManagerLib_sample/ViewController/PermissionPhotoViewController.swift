//
//  PermissionPhotoViewController.swift
//  DCPManagerLib_sample
//
//  Created by ChunsooPark on 2018. 9. 21..
//  Copyright © 2018년 devcspark. All rights reserved.
//

import UIKit

class PermissionPhotoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        DCPPermissionManager.shared().CheckPermission(permission: [.Photo]) { (isAccess) in
            
        }
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

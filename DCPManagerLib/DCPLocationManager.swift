//
//  DCPLocationManager.swift
//  DCPManagerLib_sample
//
//  Created by ChunsooPark on 2018. 9. 19..
//  Copyright © 2018년 devcspark. All rights reserved.
//

import UIKit
import CoreLocation

class DCPLocationManager: NSObject, CLLocationManagerDelegate {

    private static var _saredInstance : DCPLocationManager = {
        let pManager = DCPLocationManager()
        // 각종 초기화
        
        pManager.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        pManager.locationManager.delegate = pManager
        
        return pManager
    }()
    
    class func shared() -> DCPLocationManager {
        return _saredInstance
    }
    
    private var locationManager = CLLocationManager()
    private var location:CLLocation!

    private var isLocationSearch = false
    
    func getLocation() {
        if !isLocationSearch {
            
        }
    }
}

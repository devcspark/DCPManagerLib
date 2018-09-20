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

    private var updateLocation : ((CLLocation)->Void)?
    
    private static var _saredInstance : DCPLocationManager = {
        let pManager = DCPLocationManager()
        // 각종 초기화
        
        pManager.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        pManager.locationManager.distanceFilter = kCLDistanceFilterNone
        pManager.locationManager.delegate = pManager
        
        return pManager
    }()
    
    class func shared() -> DCPLocationManager {
        return _saredInstance
    }
    
    private var locationManager = CLLocationManager()
    private var location:CLLocation!
    
    private var _isLocationSearch = false
    var isLocationSearch : Bool {
        get {
            return _isLocationSearch
        }
        set(newValue){
            _isLocationSearch = newValue
            if newValue {
                locationManager.startUpdatingLocation()
            }else{
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    func getLocation(updateHandle:@escaping((CLLocation)->Void)) {
        updateLocation = updateHandle
        locationManager.requestWhenInUseAuthorization()
    }
    
    // CLLocationManagerDelegate 델리게이트 함수
    // Region start
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if updateLocation != nil {
            updateLocation!(locations.last!)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("GPS Error => \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // 애플리케이션의 위치 추적 허가 상태가 변경될 경우 호출
        if(status == .authorizedWhenInUse){
            isLocationSearch = true
        }
    }
    // Region end
}

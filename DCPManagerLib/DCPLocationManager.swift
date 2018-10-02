//
//  DCPLocationManager.swift
//  DCPManagerLib_sample
//
//  Created by ChunsooPark on 2018. 9. 19..
//  Copyright © 2018년 devcspark. All rights reserved.
//

import UIKit
import CoreLocation

public class DCPLocationManager: NSObject, CLLocationManagerDelegate {

    private var updateLocation : ((CLLocation)->Void)?
    
    private static var _saredInstance : DCPLocationManager = {
        let pManager = DCPLocationManager()

        pManager.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        pManager.locationManager.distanceFilter = kCLDistanceFilterNone
        pManager.locationManager.delegate = pManager
        
        return pManager
    }()
    
    public class func shared() -> DCPLocationManager {
        return _saredInstance
    }
    
    private var locationManager = CLLocationManager()
    private var location:CLLocation!
    
    private var _isLocationSearch = false
    public var isLocationSearch : Bool {
        get {
            return _isLocationSearch
        }
        set(newValue){
            _isLocationSearch = newValue
            if newValue {
                locationManager.startUpdatingLocation()
                if updateLocation != nil {
                    updateLocation!(locationManager.location!)
                }
            }else{
                locationManager.stopUpdatingLocation()
            }
        }
    }
    
    public func changeSetting(accuracy:CLLocationAccuracy, distance:CLLocationDistance) {
        isLocationSearch = false
        locationManager.desiredAccuracy = accuracy
        locationManager.distanceFilter = distance
        isLocationSearch = true
    }
    
    public func getLocation(updateHandle:@escaping((CLLocation)->Void)) {
        updateLocation = updateHandle
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            isLocationSearch = true
        }else{
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    // CLLocationManagerDelegate
    // Region start
    private func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if updateLocation != nil {
            updateLocation!(locations.last!)
        }
    }
    
    private func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error : [\(error.localizedDescription)]")
    }
    
    private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // It is called when using authentication.
        if(status == .authorizedWhenInUse){
            isLocationSearch = true
        }
    }
    // Region end
}

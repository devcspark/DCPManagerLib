//
//  LocationViewController.swift
//  DCPManagerLib_sample
//
//  Created by ChunsooPark on 2018. 9. 20..
//  Copyright © 2018년 devcspark. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    private var information:MKPointAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        map.delegate = self
        
        DCPLocationManager.shared().getLocation { [weak self](location) in
            
            if let region = self?.map.regionThatFits(MKCoordinateRegionMakeWithDistance(location.coordinate, 500.0, 500.0)) {
                self?.map.setRegion(region, animated: true)
                
                // insert pin
                if(self?.information == nil){
                    self?.information = MKPointAnnotation()
                    self?.information!.coordinate = location.coordinate
                    self?.map.addAnnotation((self?.information)!)
                }else{
                    self?.information?.coordinate = location.coordinate
                }
            }
        }
    }
    
    deinit {
        print("deinit")
    }
    
    @IBAction func pressedBack(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressedMoveToMe(_ sender: UIButton) {
        DCPLocationManager.shared().isLocationSearch = true
    }
    
    // MKMapViewDelegate
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        // stop update
        DCPLocationManager.shared().isLocationSearch = false
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

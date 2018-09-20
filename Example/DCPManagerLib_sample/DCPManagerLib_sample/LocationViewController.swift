//
//  LocationViewController.swift
//  DCPManagerLib_sample
//
//  Created by ChunsooPark on 2018. 9. 20..
//  Copyright © 2018년 devcspark. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController {

    private var location:DCPLocationManager!
    
    @IBOutlet weak var map: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func pressedBack(_ sender: UIButton) {
        
    }
    
    @IBAction func pressedMoveToMe(_ sender: UIButton) {
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

//
//  ViewController.swift
//  teleporter
//
//  Created by Nadia Barbosa on 3/18/17.
//  Copyright © 2017 Nadia Barbosa. All rights reserved.
//
import Mapbox
import UIKit

class ViewController: UIViewController, MGLMapViewDelegate {

    @IBOutlet var mapView: MGLMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func teleportToLocation(_ sender: UIButton) {
        print("HI")
    }

    //var center = CLLocationCoordinate2D(latitude: 38.897435, longitude: -77.039679)
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        
//        func test() {
//            let camera = MGLMapCamera(lookingAtCenter: center, fromDistance: 200000, pitch: 0, heading: 0)
//            
//            mapView.fly(to: camera, withDuration: 4,
//                        peakAltitude: 3000, completionHandler: nil)
//            
//        }
    }
    
    
}


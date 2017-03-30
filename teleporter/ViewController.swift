//
//  ViewController.swift
//  teleporter
//
//  Created by Nadia Barbosa on 3/18/17.
//  Copyright © 2017 Nadia Barbosa. All rights reserved.
//
import Mapbox
import MapboxGeocoder
import UIKit

class ViewController: UIViewController, MGLMapViewDelegate {
    let geocoder = Geocoder.shared

    @IBOutlet var mapView: MGLMapView!
    @IBOutlet weak var placeName: UILabel!
    
    var mapDidFinishLoading: Bool = false
    
    var optionalAnnotation: MGLPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func teleportToLocation(_ sender: UIButton) {
        guard mapDidFinishLoading == true else { return }
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: 38.897435, longitude: -77.039679)
        mapView.addAnnotation(annotation)
        
        let camera = mapView.camera
        
        camera.centerCoordinate = annotation.coordinate
        camera.altitude = 20000
        mapView.setCamera(camera, animated: true)
        
        let options = ReverseGeocodeOptions(coordinate: annotation.coordinate)
        
        _ = geocoder.geocode(options) { [weak self] (placemarks, attribution, error) in
            guard let strongSelf = self else { return }
            guard let placemark = placemarks?.first else {
                return
            }
            
            strongSelf.placeName.text = placemark.administrativeRegion?.name ?? "Not found"
        }

    }
    
    
   

    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        mapDidFinishLoading = true
    }
    
    
}


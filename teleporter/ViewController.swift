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

extension CLLocationCoordinate2D {
    init(random _: Any?) {
        // arc4random_uniform() takes UInt32, so it's necessary to convert to positive numbers, then subtract when we're done to get back where we started.
        let offsetLatitude = abs(-90) // effectively the minimum latitude
        let maximumLatitude = 90 + offsetLatitude
        
        let offsetLongitude = abs(-180) // effectively the minimum longitude
        let maximumLongitude = 180 + offsetLongitude // 180 + offset
        
        let latitude = Int(arc4random_uniform(UInt32(maximumLatitude))) - offsetLatitude
        let longitude = Int(arc4random_uniform(UInt32(maximumLongitude))) - offsetLongitude
        
        self.latitude = Double(latitude)
        self.longitude = Double(longitude)
    }
}

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
        
        let randomCoordinate = CLLocationCoordinate2D(random: true)
        
        guard mapDidFinishLoading == true else { return }
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = randomCoordinate
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


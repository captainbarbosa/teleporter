//
//  ViewController.swift
//  teleporter
//
//  Created by Nadia Barbosa on 3/18/17.
//  Copyright © 2017 Nadia Barbosa. All rights reserved.
//
import Mapbox
import MapboxGeocoder
import MapboxDirections
import MapboxNavigation
import UIKit

class ViewController: UIViewController, MGLMapViewDelegate {
    
    let geocoder = Geocoder.shared
    var route: Route?
    @IBOutlet var mapView: MGLMapView!
    @IBOutlet weak var placeName: UILabel!
    
    var mapDidFinishLoading: Bool = false
    
    var optionalAnnotation: MGLPointAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        mapView.addGestureRecognizer(recognizer)
    }
    
    // Set up a long press gesture reconizer that creates and annotation
    // and reverse geocodes the point at which the long press occurs
    // on the map view
    func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        let point = sender.location(in: mapView)
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        
        //reverseGeocode(coordinate: annotation.coordinate)
        reverseGeocode(coordinate: annotation.coordinate) { (postalAddress) in
            let formatter = CNPostalAddressFormatter()
            guard let postalAddress = postalAddress else {
                self.placeName.text = "Not found"
                //completion(nil)
                return
            }
            
            self.placeName.text = formatter.string(from: postalAddress)
    
        }
    }
    
    @IBAction func removeAnnotations(_ sender: UIButton) {
        guard mapDidFinishLoading == true else { return }
        
        guard let annotations = mapView.annotations else { return }
        mapView.removeAnnotations(annotations)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        mapDidFinishLoading = true
        // call reverGeocode
    }
    
    func test() {
        
    }
    // Reverse geocode
    func reverseGeocode(coordinate: CLLocationCoordinate2D,
                        completion: @escaping (CNPostalAddress?) -> ()) {
        let options = ReverseGeocodeOptions(coordinate: coordinate) // 1 main thread
        
        _ = geocoder.geocode(options) {(placemarks, attribution, error) in // 2 background thread
            // 4
            guard let placemark = placemarks?.first else {
                print("Couldn't find this place")
                completion(nil)
                return
            }
            completion(placemark.postalAddress)
            
        }
        print("")
        // 3
    }
}

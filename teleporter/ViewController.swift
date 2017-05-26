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
        
        mapView.showsUserLocation = true
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
        annotation.title = "New location"
        
        mapView.addAnnotation(annotation)
        
        // Reverse geocode the point at which the long press occurs
        reverseGeocode(coordinate: annotation.coordinate) { (postalAddress) in
            let formatter = CNPostalAddressFormatter()
            guard let postalAddress = postalAddress else {
                self.placeName.text = "Not found"
                return
            }
            
            self.placeName.text = formatter.string(from: postalAddress)
        }
    }
    
    // Clear annotations from the map view if button is pressed
    @IBAction func removeAnnotations(_ sender: UIButton) {
        guard mapDidFinishLoading == true else { return }
        
        guard let annotations = mapView.annotations else { return }
        mapView.removeAnnotations(annotations)
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        mapDidFinishLoading = true
    }
    
    // Ensure annotations can show callouts
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    // Customize annotation callout
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        let bundle = Bundle(for: NavigationViewController.self)
        let image = UIImage(named: "recenter", in: bundle, compatibleWith: nil)
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.sizeToFit()
        return button
    }
    
    // Delegate method for custom annotation callout
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        
        calculateRoute(from: mapView.userLocation!.coordinate, to: annotation.coordinate) { [unowned self] (route, error) in
            //  Present navigation with route
            if let error = error {
              // Add alert view controller here
            }
            guard let route = route else {
                return
            }
            self.presentNavigation(along: route)
        }
    }
    
    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D,
                        to destination: CLLocationCoordinate2D,
                        completion: @escaping (Route?, Error?) -> ()) {
        // origin CLLocatuinCoordinate2D
        let originWaypoint = Waypoint(coordinate: origin, name: "Mapbox")
        // origin Waypoint
        let destinationWaypoint = Waypoint(coordinate: destination)
        
        
        let options = RouteOptions(waypoints: [originWaypoint, destinationWaypoint], profileIdentifier: .automobileAvoidingTraffic)
        options.routeShapeResolution = .full
        options.includesSteps = true
        
        _ = Directions.shared.calculate(options) { (waypoints, routes, error) in
            
            guard let route = routes?.first else {
                completion(nil, error)
                return
            }
            completion(route, error)
        }
    }
    
    // Present the navigation view controller
    func presentNavigation(along route: Route) {
      let viewController = NavigationViewController(for: route)
      viewController.simulatesLocationUpdates = true
      self.present(viewController, animated: true, completion: nil)
    }
    
    // Reverse geocode sequence
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

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
    
    var mapView: MGLMapView!
    var route: Route?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true

        view.addSubview(mapView)
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        mapView.addGestureRecognizer(recognizer)
        
        // Make sure to set the map view's delegate so we can use delegate methods
        mapView.delegate = self
    }
    

    func didLongPress(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == .began else { return }
        
        // Converts point where user did a long press to map coordinates
        let point = sender.location(in: mapView)
        
        let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
        
        // Create a basic point annotation and add it to the map
        let annotation = MGLPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Start navigation"
        mapView.addAnnotation(annotation)
        
        calculateRoute(from: mapView.userLocation!.coordinate, to: annotation.coordinate) { [unowned self] (route, error) in
            if let error = error {
                // Handle error here, such as
                // displaying an alert
            }
            guard let route = route else {
                // Bail if theres a problem generating the route
                return
            }
            // drawRoute(route: route)
        }
        
    }
    
    // Delegate method: Ensure annotations can show callouts
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    // Customize annotation callout
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        // This pulls an icon from the Mapbox Navigation SDK to be used as a buttin within the callout
        let bundle = Bundle(for: NavigationViewController.self)
        let image = UIImage(named: "recenter", in: bundle, compatibleWith: nil)
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.sizeToFit()
        return button
    }
    
    // Handle the callout accessory (in this case the button added
    // in the rightCalloutAccessoryViewFor delegate method)
    // interaction to start navigation sequence when tapped
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        
        self.presentNavigation(along: route)
    }
    
    // Calculate route to be used for navigation
    func calculateRoute(from origin: CLLocationCoordinate2D,
                        to destination: CLLocationCoordinate2D,
                        completion: @escaping (Route?, Error?) -> ()) {

        let originWaypoint = Waypoint(coordinate: origin, name: "Mapbox")
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
    
    func drawRoute(route: Route) {
        // Here's where you'd add code to draw the route
    }
    
    // Present the navigation view controller
    func presentNavigation(along route: Route) {
      let viewController = NavigationViewController(for: route)
      self.present(viewController, animated: true, completion: nil)
    }

}

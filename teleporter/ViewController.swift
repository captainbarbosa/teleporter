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
    var directionsRoute: Route?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.userTrackingMode = .follow
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
        mapView.selectAnnotation(annotation, animated: true)
        
        calculateRoute(from: mapView.userLocation!.coordinate, to: annotation.coordinate) { [unowned self] (route, error) in
            if let error = error {
                // Handle API / network related errors here
                let alert = UIAlertController(title: "Error:", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            guard let directionsRoute = route else {
                // Handle route generation errors
                return
            }
            self.drawRoute(route: directionsRoute)
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
    
    // Handle action that occurs when a callout is tapped
    func mapView(_ mapView: MGLMapView, tapOnCalloutFor annotation: MGLAnnotation) {
        self.presentNavigation(along: directionsRoute!)
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
            guard let route = routes?.first else { return }
            self.directionsRoute = route
            self.drawRoute(route: self.directionsRoute!)
        }
    }
    
    func drawRoute(route: Route) {
        if route.coordinateCount > 0 {
            // Convert the route’s coordinates into a polyline.
            var routeCoordinates = route.coordinates!
            let polyline = MGLPolylineFeature(coordinates: &routeCoordinates, count: route.coordinateCount)
            
            // If there's already a route line on the map, reset its shape to the new route
            if let source = mapView.style?.source(withIdentifier: "route-source") as? MGLShapeSource {
                source.shape = polyline
            } else {
                let source = MGLShapeSource(identifier: "route-source", features: [polyline], options: nil)
                let lineStyle = MGLLineStyleLayer(identifier: "route-style", source: source)
                lineStyle.lineColor = MGLStyleValue(rawValue: .red)
                lineStyle.lineWidth = MGLStyleValue(rawValue: 3)
                
                mapView.style?.addSource(source)
                mapView.style?.addLayer(lineStyle)
                
            }
        }
    }
    
    // Present the navigation view controller
    func presentNavigation(along route: Route) {
      let viewController = NavigationViewController(for: route)
      self.present(viewController, animated: true, completion: nil)
    }
}

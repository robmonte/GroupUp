//
//  MapViewController.swift
//  GroupUp
//
//  Created by Victor Yang on 3/20/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications


protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class MapViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var locationSearchController: UISearchController?
    var selectedPin:MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if(CLLocationManager.locationServicesEnabled()) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.requestLocation()
        }
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationTableViewController") as! LocationTableViewController
        locationSearchController = UISearchController(searchResultsController: locationSearchTable)
        locationSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = locationSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = locationSearchController?.searchBar
        
        locationSearchController?.hidesNavigationBarDuringPresentation = false
        locationSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        locationSearchTable.mapView = mapView
        
        locationSearchTable.handleMapSearchDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            let location = locations.last
        
            let center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
            self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed with error")
    }
    
    func getDirections(){
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let dirRequest = MKDirectionsRequest()
            
            dirRequest.destination = mapItem
            let src = MKMapItem.forCurrentLocation()
            dirRequest.source = src
            let directions = MKDirections(request: dirRequest)
            
            directions.calculate() { response, error in
                if error == nil {
                    if response != nil {
                        let route = response?.routes[0]
                        self.mapView.add((route?.polyline)!)
                        print(route?.expectedTravelTime ?? 0)
                        
                    }
                }
                else {
                    print(error?.localizedDescription ?? "Error unable to be described")
                }
            }
        }
    }
    
    func setRoute() {
        if let selectedPin = selectedPin {
            let mapItem = MKMapItem(placemark: selectedPin)
            let dirRequest = MKDirectionsRequest()
            dirRequest.destination = mapItem
            let src = MKMapItem.forCurrentLocation()
            dirRequest.source = src
            let directions = MKDirections(request: dirRequest)
            directions.calculate() {response, error in
                if error == nil {
                    if response != nil {
                        let route = response?.routes[0]
                        self.mapView.add((route?.polyline)!)
                        
                        let addressDict = selectedPin.addressDictionary
                        let street = addressDict?["Street"] ?? ""
                        let city = addressDict?["City"] ?? ""
                        let state = addressDict?["State"] ?? ""
                        let zip = addressDict?["ZIP"] ?? ""
                        let address = "\(street) \(city) \(state) \(zip)"
                        
                        let etaInfoDict: [String: Any] = ["ETA": (route?.expectedTravelTime)! , "Address": address]
                        
                        
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "setRoute"), object: nil, userInfo: etaInfoDict)
                        
                        let alertController = UIAlertController(title: "Destination Set", message: "Destination has been set", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let OK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                        }
                        
                        alertController.addAction(OK)
                        
                        self.present(alertController, animated: true)
                        
                    }
                }
                else {
                    print(error?.localizedDescription ?? "Error unable to be described")
                }
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        
        self.mapView.removeOverlays(self.mapView.overlays)

        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}

extension MapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        pinView?.pinTintColor = UIColor.orange
        pinView?.canShowCallout = true
        
        let smallSquare = CGSize(width: 30, height: 30)
        //let button = UIButton(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: smallSquare))
        //button.backgroundColor = UIColor.blue
        //button.addTarget(self, action: #selector(MapViewController.getDirections), for: .touchUpInside)
        //pinView?.leftCalloutAccessoryView = button
        
        let setButton = UIButton(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: smallSquare))
        setButton.setTitle("Set", for: UIControlState.normal)
        setButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        setButton.setTitleColor(UIColor.cyan, for: UIControlState.highlighted)
        setButton.addTarget(self, action: #selector(MapViewController.setRoute), for: .touchUpInside)
        pinView?.rightCalloutAccessoryView = setButton
        
        
        
        
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3
        return renderer
    }
}

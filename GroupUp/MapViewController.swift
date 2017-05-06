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
    
    private var setAddress:String = ""
    private var destLat:Double = 0.0
    private var destLong:Double = 0.0
    
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
            let src = MKMapItem.forCurrentLocation()
            
            dirRequest.destination = mapItem
            dirRequest.source = src
            
            destLat = (mapItem.placemark.location?.coordinate.latitude)!
            destLong = (mapItem.placemark.location?.coordinate.longitude)!
            
            let directions = MKDirections(request: dirRequest)
            directions.calculate() { response, error in
                if error == nil {
                    if response != nil {
                        let route = response?.routes[0]
                        self.mapView.add((route?.polyline)!)
                        
                        let addressDict = selectedPin.addressDictionary
                        let street = addressDict?["Street"] ?? ""
                        let city = addressDict?["City"] ?? ""
                        let state = addressDict?["State"] ?? ""
                        let zip = addressDict?["ZIP"] ?? ""
                        let address = "\(street)\n\(city), \(state) \(zip)"

                        self.setAddress = address
                        let alertController = UIAlertController(title: "Destination Set", message: "Destination has been set.", preferredStyle: UIAlertControllerStyle.alert)
                        
                        let OK = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                            (action:UIAlertAction) in
                        }
                        
                        alertController.addAction(OK)
                        self.present(alertController, animated: true)
                        
                        if let first = self.mapView.overlays.first {
                            let rect = self.mapView.overlays.reduce(first.boundingMapRect, { MKMapRectUnion($0, $1.boundingMapRect) })
                            self.mapView.setVisibleMapRect(rect, edgePadding: UIEdgeInsets(top: 100.0, left: 100.0, bottom: 100.0, right: 100.0), animated: true)
                        }
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
    
    override func viewWillDisappear(_ animated: Bool) {
        let views = self.navigationController?.viewControllers
        if let create = views?[views!.count-1] as? CreateGroupViewController
        {
            create.setAddress = setAddress
            create.destLat = destLat
            create.destLong = destLong
        }
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
        selectedPin = placemark
        
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
        pinView?.pinTintColor = UIColor.red
        pinView?.canShowCallout = true
        
        let smallSquare = CGSize(width: 50, height: 35)
        let setButton = UIButton(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: smallSquare))
        setButton.layer.borderWidth = 1.5
        setButton.layer.cornerRadius = 5
        setButton.layer.borderColor = UIColor.blue.cgColor
        
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

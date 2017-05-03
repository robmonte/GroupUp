//
//  MapViewController.swift
//  GroupUp
//
//  Created by Victor Yang on 3/21/17.
//  Copyright © 2017 GroupUp. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import UserNotifications

protocol HandleMapView {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ViewDirectionsViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    private var setAddress:String = ""
    private var mapItem:MKMapItem?
    public var destLat:Double = 0.0
    public var destLong:Double = 0.0
    
    var locationManager: CLLocationManager!
    var locationSearchController: UISearchController?
    var selectedPin:MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        let destCoordinates = CLLocationCoordinate2DMake(destLat, destLong)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        mapItem = MKMapItem(placemark: destPlacemark)
        let dirRequest = MKDirectionsRequest()
        let src = MKMapItem.forCurrentLocation()
        
        dirRequest.destination = mapItem
        dirRequest.source = src
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Open Navigation:"

        if let location = destPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }

        self.mapView.showAnnotations([destinationAnnotation], animated: true )
        
        print("trying let directions")
        
        let directions = MKDirections(request: dirRequest)
        directions.calculate() { response, error in
            if error == nil {
                if response != nil {
                    print("at mapview.add route")
                    let route = response?.routes[0]
                    self.mapView.add((route?.polyline)!)
                    print(route?.expectedTravelTime ?? 0)
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
    
    override func viewDidAppear(_ animated: Bool) {
        //getDirections()
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
    
    func getDirections() {
        let destCoordinates = CLLocationCoordinate2DMake(destLat, destLong)
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        let mapItem = MKMapItem(placemark: destPlacemark)
        let dirRequest = MKDirectionsRequest()
        let src = MKMapItem.forCurrentLocation()
        
        dirRequest.destination = mapItem
        dirRequest.source = src
        
        print("trying let directions")
        
        let directions = MKDirections(request: dirRequest)
        directions.calculate() { response, error in
            if error == nil {
                if response != nil {
                    print("at mapview.add route")
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
    
    func openNavigation() {
        let coordinates = CLLocationCoordinate2DMake(destLat, destLong)
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapitem = MKMapItem(placemark: placemark)
        let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
        
        mapitem.openInMaps(launchOptions: options)
    }
    
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
        
        let smallSquare = CGSize(width: 50, height: 35)
        let navButton = UIButton(frame: CGRect(origin: CGPoint(x: 0,y: 0), size: smallSquare))
        navButton.layer.borderWidth = 1.5
        navButton.layer.cornerRadius = 5
        navButton.layer.borderColor = UIColor.blue.cgColor
        
        navButton.setTitle("Go", for: UIControlState.normal)
        navButton.setTitleColor(UIColor.blue, for: UIControlState.normal)
        navButton.setTitleColor(UIColor.cyan, for: UIControlState.highlighted)
        navButton.addTarget(self, action: #selector(ViewDirectionsViewController.openNavigation), for: .touchUpInside)
        pinView?.rightCalloutAccessoryView = navButton
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3
        
        return renderer
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
